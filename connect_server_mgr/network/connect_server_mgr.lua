local luaxml = require "luaxml"
local util = require "util"
local common = require "common"
local global = require "global"

local WorldServer = require "msg_proc.world_srv.world_srv"

require "protocol"

ConnectServerMgr = {}

---------------------------------------------------------------------------------------------------------------------------
-- 模块函数
---------------------------------------------------------------------------------------------------------------------------
function ConnectServerMgr.RetryConnect(timer_id, param)
	crossover.remove_timer(timer_id)
	global.connect_server_mgr:Connect2Server(param.ip, param.port, param.srv_type, param.srv_uid, param.area_idx);
end

function ConnectServerMgr.OnConnCreated(conn_idx, is_success, param)
	global.connect_server_mgr:DoConnCreated(conn_idx, is_success, param)
end

function ConnectServerMgr.OnConnClosed(conn_idx)
	global.connect_server_mgr:DoConnClosed(conn_idx)
end

function ConnectServerMgr.OnDataReceived(conn_idx, data, len)
	global.connect_server_mgr:DoDataReceived(conn_idx, data, len)
end


---------------------------------------------------------------------------------------------------------------------------
-- 对象函数
---------------------------------------------------------------------------------------------------------------------------
function ConnectServerMgr:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.tcp_client_ = tcpclient.new()
	o.app_srv_conn_map_ = {}
	o.app_srv_uid_map_ = {}
	
    return o
end

function ConnectServerMgr:Init()
    
end

function ConnectServerMgr:GetThisSrvUID()
	return GenerateSrvUID(ServerType.SERVERTYPE_CSM, global.config.realm_idx, 0)
end

function ConnectServerMgr:Connect2Server(ip, port, srv_type, srv_uid, area_idx)
	is_stopping = global.master:is_stopping();
	if is_stopping then
		return
	end

	LOG_INFO("connect to server. at: " .. ip .. ", " .. port .. ", SERVER TYPE = " .. srv_type)
	
	param = {ip = ip, port = port, srv_type = srv_type, srv_uid = srv_uid, area_idx = area_idx}
	self.tcp_client_:connect(ip, port, 
							ConnectServerMgr.OnConnCreated, ConnectServerMgr.OnConnClosed, ConnectServerMgr.OnDataReceived, 
							1024 * 1024 * 4, 1024 * 1024 * 4, true, param)
end

function ConnectServerMgr:Start()
    -- connect ws
	self:Connect2Server(global.config.ws_ip, global.config.ws_port, ServerType.SERVERTYPE_WORLD, 
							GenerateSrvUID(ServerType.SERVERTYPE_WORLD, global.config.realm_idx, 0), 0)
end

function ConnectServerMgr:Stop()
    self.tcp_client_:close()
end

function ConnectServerMgr:DoConnCreated(conn_idx, is_success, param)
	if is_success then
		if self.app_srv_conn_map_[conn_idx] then
			return
		end
		
		peer = nil
		if param.srv_type == ServerType.SERVERTYPE_WORLD then
			peer = WorldServer:New()
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
		peer.srv_info_.area_idx = 0
		peer.srv_info_.ip = param.ip
		peer.srv_info_.port = param.port
		peer.network_ = self.tcp_client_

		--发送登录消息
		request_msg = {}
		request_msg.srv_info = clone(peer.srv_info_) --复制一下srv_info
		request_msg.srv_info.srv_type = ServerType.SERVERTYPE_CSM
		request_msg.srv_info.srv_uid = self:GetThisSrvUID()
		peer:Send(internal.ReqLogin, request_msg)
	else --不成功，进行重连
		crossover.add_timer(RETRY_CONNECT_INTERVAL, ConnectServerMgr.RetryConnect, param)
	end
end

function ConnectServerMgr:DoConnClosed(conn_idx)
	peer = self.app_srv_conn_map_[conn_idx]
	if not peer then
		return
	end

	LOG_INFO("server disconnected. srv_type:" .. peer.srv_info_.srv_type .. " server uid:" .. 
		peer.srv_info_.srv_uid .. "  ip:" .. peer.srv_info_.ip .. "  port:" .. peer.srv_info_.port)

	param = {ip = peer.srv_info_.ip, port = peer.srv_info_.port, srv_type = peer.srv_info_.srv_type, srv_uid = peer.srv_info_.srv_uid, area_idx = global.config.area_idx}

	if peer.srv_info_.srv_type == ServerType.SERVERTYPE_WORLD then
		crossover.add_timer(RETRY_CONNECT_INTERVAL, ConnectServerMgr.RetryConnect, param)
	end

	-- 移除相应的peer
	self.app_srv_uid_map_[peer.srv_info_.srv_uid] = nil
	self.app_srv_conn_map_[conn_idx] = nil
	peer = nil
end

function ConnectServerMgr:DoDataReceived(conn_idx, data, len)
	msg = seri.unpack(data, len)
	
	peer = self.app_srv_conn_map_[conn_idx]
	if peer == nil then
		return
	end
	
	-- 如果连接已关闭, 而由于多线程, 读操作在另外一条线程, 那读过来的消息包直接忽略, 防止是写DB的消息, 用到sql_builder, 但sql_builder已释放
	if peer.status_ == PeerStatusType.E_PEER_CLOSE then
		return
	end
	
	if msg.cmd == internal.ReqLogin then
		if msg.result then
			peer.status_ = PeerStatusType.E_PEER_ALREADY_LOGIN
			peer.srv_info_.area_idx = msg.area_idx --Ms的area_idx
			self:OnAppSrvEnter(peer)

			LOG_INFO("login server success. SERVER UID = " .. peer.srv_info_.srv_uid.."  SERVER TYPE = " .. peer.srv_info_.srv_type)
		else
			LOG_ERROR("login server fail. SERVER UID = " .. peer.srv_info_.srv_uid .. "  SERVER TYPE = " .. peer.srv_info_.srv_type)
		end
	elseif msg.cmd == internal.AppServerShutdown then
		if peer.srv_info_.srv_type == ServerType.SERVERTYPE_WORLD then
			global.master:Stop()
		end
	elseif msg.cmd == internal.AppServerList then
		LOG_INFO("internal.AppServerList ")
		
	elseif msg.cmd == internal.AppServerAdd then
		LOG_INFO("internal.AppServerAdd srv_uid = " .. msg.srv_uid)
		
	elseif msg.cmd == internal.AppServerRemove then
		LOG_INFO("internal.AppServerRemove srv_uid = " .. msg.srv_uid)
		
	else
		if peer.HandleMsg(conn_idx, data_ptr, data_len) then
			
		else
			
		end
	end
end

function ConnectServerMgr:OnAppSrvEnter(peer)
	if peer.srv_info_.srv_type == ServerType.SERVERTYPE_WORLD then
		ws_ = peer
	else
		
	end
end

function ConnectServerMgr:ShowServer()
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

return ConnectServerMgr