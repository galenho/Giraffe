local luaxml = require "luaxml"
local util = require "util"
local global = require "global"

local Peer = require "peer"
local MapServer = require "msg_proc.map_srv.map_srv"
local ConnectServer = require "msg_proc.connect_srv.connect_srv"
local WorldServer = require "msg_proc.world_srv.world_srv"
local LoginServer = require "msg_proc.login_srv.login_srv"

require "protocol"

NetForServer = {}

---------------------------------------------------------------------------------------------------------------------------
-- 模块函数
---------------------------------------------------------------------------------------------------------------------------
function NetForServer.RetryConnect(timer_id, param)
	crossover.remove_timer(timer_id)
	global.net_for_server:Connect2Server(param.ip, param.port, param.srv_type, param.srv_uid, param.area_idx)
end

function NetForServer.OnConnCreated(conn_idx, is_success, param)
	global.net_for_server:DoConnCreated(conn_idx, is_success, param)
end

function NetForServer.OnConnClosed(conn_idx)
	global.net_for_server:DoConnClosed(conn_idx)
end

function NetForServer.OnDataReceived(conn_idx, data, len)
	global.net_for_server:DoDataReceived(conn_idx, data, len)
end

---------------------------------------------------------------------------------------------------------------------------
-- 对象函数
---------------------------------------------------------------------------------------------------------------------------
function NetForServer:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.tcp_server_ = tcpserver.new()
	o.app_srv_conn_map_ = {}
	o.app_srv_uid_map_ = {}
	o.ws_ = nil
    o.ls_ = nil
	
    return o
end

function NetForServer:Init()
    
end

function NetForServer:Start()
    self.tcp_server_:start(global.config.ip_for_server, global.config.port_for_server, 
							NetForServer.OnConnCreated, NetForServer.OnConnClosed, NetForServer.OnDataReceived, 
							1024 * 1024 * 4, 1024 * 1024 * 4)
end

function NetForServer:Stop()
    self.tcp_server_:close()
end

function NetForServer:DoConnCreated(conn_idx, is_success, param)
	
end

function NetForServer:DoConnClosed(conn_idx)

end

function NetForServer:DoDataReceived(conn_idx, data, len)
	msg = seri.unpack(data, len)
	peer = self.app_srv_conn_map_[conn_idx]
	
	if msg.cmd == internal.ReqLogin then
		if not peer then
			peer = self:CreatePeer(msg.srv_info.srv_type)
			if not peer then
				return
			end
			
			peer.srv_info_ = msg.srv_info
			peer.srv_info_.conn_idx = conn_idx
			peer.network_ = self.tcp_server_
			
			self.app_srv_conn_map_[conn_idx] = peer
			self.app_srv_uid_map_[peer.srv_info_.srv_uid] = peer
			
			peer.status_ = PeerStatusType.E_PEER_ALREADY_LOGIN			

			--回复登录消息
			response_msg = {}
			response_msg.result = true
			response_msg.area_idx = 0
			peer:Send(internal.ReqLogin, response_msg)

			LOG_INFO("internal.ReqLogin is success :" .. peer.srv_info_.srv_uid)
		else
		
		end
	else
		if not peer then
			LOG_ERROR("this peer is not found")
			return
		end
			
		if msg.cmd == internal.AppServerList then
		
		elseif msg.cmd == internal.AppServerAdd then
		
		elseif msg.cmd == internal.AppServerRemove then
		
		elseif msg.cmd == internal.AppServerShutdown then
        
			if peer.srv_info_.srv_type == ServerType.SERVERTYPE_WORLD then
				global.master:Stop()
			end
            
		elseif msg.cmd == internal.ReqServerSerial then
        
			global.server_res_mgr:HandleReqGetSerialID(msg.req_type, peer.srv_info_.srv_uid)
            
   		elseif msg.cmd == internal.ReqServerRes then
            --dump(msg)
			global.server_res_mgr:HandleReqServerRes(msg.table_name, msg.query, msg.field, msg.is_batch, msg.limit, peer.srv_info_.srv_uid)
            
		else --普通消息
        
			peer:HandleMsg(conn_idx, msg)
            
		end
	end
end

function NetForServer:CreatePeer(srv_type)
	peer = nil

    if srv_type == ServerType.SERVERTYPE_LOGIN then
		peer = LoginServer:New()
		self.ls_ = peer
    elseif srv_type == ServerType.SERVERTYPE_CONNECT then
		peer = ConnectServer:New()
	elseif srv_type == ServerType.SERVERTYPE_MAP then
		peer = MapServer:New()
	elseif srv_type == ServerType.SERVERTYPE_WORLD then
		peer = WorldServer:New()
		self.ws_ = peer
	else
		LOG_ERROR("invalid server type, type:" .. srv_type)
		return peer
	end

	if not peer then
		LOG_ERROR("fetch app server error.")
		return peer
	end

	peer:InitMsgHandle()

	return peer
end

function NetForServer:get_peer_by_uid(srv_uid)
	return self.app_srv_uid_map_[srv_uid]
end

function NetForServer:SendToWS(cmd, data)
	if self.ws_ then
		self.ws_:Send(cmd, data)
	end
end

function NetForServer:ShowServer()
	for key, value in pairs(self.app_srv_uid_map_) do
		peer = value
		if peer.status_ ~= PeerStatusType.E_PEER_ALREADY_LOGIN then

		else
			appsrv_name = get_appsrv_name(peer.srv_info_.srv_type);
			LOG_INFO(appsrv_name .. ", conn_idx = " .. peer.srv_info_.conn_idx .. ", realm_idx = " .. peer.srv_info_.realm_idx ..
				 ", srv_uid = ".. peer.srv_info_.srv_uid ..", area_idx = " .. peer.srv_info_.area_idx)
		end
	end
end

return NetForServer