local luaxml = require "luaxml"
local util = require "util"
local common = require "common"
local global = require "global"

local WorldServer = require "msg_proc.world_srv.world_srv"
local DBServer = require "msg_proc.db_srv.db_srv"
local LogServer = require "msg_proc.log_srv.log_srv"

require "protocol"

MapServer = {}

---------------------------------------------------------------------------------------------------------------------------
-- ???D??
---------------------------------------------------------------------------------------------------------------------------
function MapServer.RetryConnect(timer_id, param)
	crossover.remove_timer(timer_id)
	global.map_server:Connect2Server(param.ip, param.port, param.srv_type, param.srv_uid, param.area_idx);
end

function MapServer.OnConnCreated(conn_idx, is_success, param)
	global.map_server:DoConnCreated(conn_idx, is_success, param)
end

function MapServer.OnConnClosed(conn_idx)
	global.map_server:DoConnClosed(conn_idx)
end

function MapServer.OnDataReceived(conn_idx, data, len)
	global.map_server:DoDataReceived(conn_idx, data, len)
end

---------------------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------------------
function MapServer:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	o.tcp_client_ = tcpclient.new()
	o.app_srv_conn_map_ = {}
	o.app_srv_uid_map_ = {}
	
    o.ws_ = nil
    o.ds_ = nil
    o.log_ = nil
    
    return o
end

function MapServer:Init()
    
end

function MapServer:GetThisSrvUID()
	return GenerateSrvUID(ServerType.SERVERTYPE_MAP, global.config.realm_idx, global.config.area_idx)
end

function MapServer:Connect2Server(ip, port, srv_type, srv_uid, area_idx)
	is_stopping = global.master:is_stopping();
	if is_stopping then
		return
	end

	LOG_INFO("connect to server. at: " .. ip .. ", " .. port .. ", SERVER TYPE = " .. srv_type)
	
	param = {ip = ip, port = port, srv_type = srv_type, srv_uid = srv_uid, area_idx = area_idx}
	self.tcp_client_:connect(ip, port, 
							MapServer.OnConnCreated, MapServer.OnConnClosed, MapServer.OnDataReceived,
							1024 * 1024 * 4, 1024 * 1024 * 4, true, param)
end

function MapServer:Start()
    -- connect ws
	self:Connect2Server(global.config.ws_ip, global.config.ws_port, ServerType.SERVERTYPE_WORLD, 
							GenerateSrvUID(ServerType.SERVERTYPE_WORLD, global.config.realm_idx, 0), global.config.area_idx)
							
	-- connect ds
	self:Connect2Server(global.config.ds_ip, global.config.ds_port, ServerType.SERVERTYPE_DB, 
							GenerateSrvUID(ServerType.SERVERTYPE_DB, global.config.realm_idx, 0), global.config.area_idx)

	-- connect ls
	self:Connect2Server(global.config.log_ip, global.config.log_port, ServerType.SERVERTYPE_LOG, 
							GenerateSrvUID(ServerType.SERVERTYPE_LOG, global.config.realm_idx, 0), global.config.area_idx)

end

function MapServer:Stop()
    self.tcp_client_:close()
end

function MapServer:DoConnCreated(conn_idx, is_success, param)
	if is_success then
		if self.app_srv_conn_map_[conn_idx] then
			return
		end
		
		peer = nil
		if param.srv_type == ServerType.SERVERTYPE_WORLD then
			peer = WorldServer:New()
		elseif param.srv_type == ServerType.SERVERTYPE_DB then
			peer = DBServer:New()
		elseif param.srv_type == ServerType.SERVERTYPE_LOG then
			peer = LogServer:New()
		else
			LOG_INFO("invalid server type, type:"..param.srv_type)
			return
		end
		
		peer:InitMsgHandle()

		self.app_srv_conn_map_[conn_idx] = peer
		self.app_srv_uid_map_[param.srv_uid] = peer
		
		peer.status_ = PeerStatusType.E_PEER_CREATED
		peer.srv_info_.realm_idx = global.config.realm_idx
		peer.srv_info_.srv_type = param.srv_type
		peer.srv_info_.conn_idx = conn_idx
		peer.srv_info_.srv_uid = param.srv_uid
		peer.srv_info_.area_idx = param.area_idx
		peer.srv_info_.ip = param.ip
		peer.srv_info_.port = param.port
		peer.network_ = self.tcp_client_

		request_msg = {}
		request_msg.srv_info = clone(peer.srv_info_) --???????srv_info
		request_msg.srv_info.srv_type = ServerType.SERVERTYPE_MAP
		request_msg.srv_info.srv_uid = self:GetThisSrvUID()
		peer:Send(internal.ReqLogin, request_msg)
		
	else
		crossover.add_timer(RETRY_CONNECT_INTERVAL, MapServer.RetryConnect, param)
	end
end

function MapServer:DoConnClosed(conn_idx)
	peer = self.app_srv_conn_map_[conn_idx]
	if not peer then
		return
	end

	LOG_INFO("server disconnected. srv_type:" .. peer.srv_info_.srv_type .. " server uid:" .. 
		peer.srv_info_.srv_uid .. "  ip:" .. peer.srv_info_.ip .. "  port:" .. peer.srv_info_.port)

	param = {ip = peer.srv_info_.ip, port = peer.srv_info_.port, srv_type = peer.srv_info_.srv_type, srv_uid = peer.srv_info_.srv_uid, area_idx = global.config.area_idx}

	if peer.srv_info_.srv_type == ServerType.SERVERTYPE_WORLD then
		crossover.add_timer(RETRY_CONNECT_INTERVAL, MapServer.RetryConnect, param)
	elseif peer.srv_info_.srv_type == ServerType.SERVERTYPE_DB then
		crossover.add_timer(RETRY_CONNECT_INTERVAL, MapServer.RetryConnect, param)
	elseif peer.srv_info_.srv_type == ServerType.SERVERTYPE_LOG then
		crossover.add_timer(RETRY_CONNECT_INTERVAL, MapServer.RetryConnect, param)
	end

	self.app_srv_uid_map_[peer.srv_info_.srv_uid] = nil
	self.app_srv_conn_map_[conn_idx] = nil
	peer = nil
end

function MapServer:DoDataReceived(conn_idx, data, len)
	msg = seri.unpack(data, len)
	
	peer = self.app_srv_conn_map_[conn_idx]
	if peer == nil then
		return
	end
	
	if peer.status_ == PeerStatusType.E_PEER_CLOSE then
		return
	end
	
	if msg.cmd == internal.ReqLogin then
		if msg.result then
			peer.status_ = PeerStatusType.E_PEER_ALREADY_LOGIN
			peer.srv_info_.area_idx = msg.area_idx
			self:OnAppSrvEnter(peer)

			LOG_INFO("login server success. SERVER UID = " .. peer.srv_info_.srv_uid.."  SERVER TYPE = " .. peer.srv_info_.srv_type)
		else
			LOG_ERROR("login server fail. SERVER UID = " .. peer.srv_info_.srv_uid .. "  SERVER TYPE = " .. peer.srv_info_.srv_type)
		end
	elseif msg.cmd == internal.AppServerList then
		LOG_INFO("internal.AppServerList ")
		
	elseif msg.cmd == internal.AppServerAdd then
		LOG_INFO("internal.AppServerAdd srv_uid = " .. msg.srv_uid)
		
	elseif msg.cmd == internal.AppServerRemove then
		LOG_INFO("internal.AppServerRemove srv_uid = " .. msg.srv_uid)
		
	elseif msg.cmd == internal.AppServerShutdown then
		if peer.srv_info_.srv_type == ServerType.SERVERTYPE_WORLD then
			global.master:Stop()
		end
		
	elseif msg.cmd == internal.RepServerSerial then
		LOG_INFO("-------------------------------------------")
		LOG_INFO("ms serial_idx : " .. msg.serial_idx)
		LOG_INFO("-------------------------------------------")

		global.server_res_mgr:set_serial_idx(msg.serial_idx)
	else
		if peer:HandleMsg(conn_idx, data_ptr, data_len) then
			
		else
			
		end
	end
end

function MapServer:OnAppSrvEnter(peer)
	if peer.srv_info_.srv_type == ServerType.SERVERTYPE_WORLD then
		ws_ = peer
	elseif peer.srv_info_.srv_type == ServerType.SERVERTYPE_MAP then
	
	elseif peer.srv_info_.srv_type == ServerType.SERVERTYPE_DB then
		ds_ = peer

		req_msg = {}
		req_msg.srv_uid = peer.srv_info_.srv_uid
		peer:Send(internal.ReqServerSerial, req_msg)
		
	elseif peer.srv_info_.srv_type == ServerType.SERVERTYPE_LOG then
		log_ = peer
	else
		
	end
end

function MapServer:ShowServer()
	for key, value in pairs(self.app_srv_uid_map_) do
		peer = value
		if peer.status_ ~= PeerStatusType.E_PEER_ALREADY_LOGIN then

		else
			appsrv_name = get_appsrv_name(peer.srv_info_.srv_type)
            str = string.format("%20s, conn_idx = %d, realm_idx = %d, srv_uid = %d, area_idx = %d", appsrv_name, peer.srv_info_.conn_idx, peer.srv_info_.realm_idx, peer.srv_info_.srv_uid, peer.srv_info_.area_idx)
            LOG_INFO(str)
		end
	end
end

return MapServer