local global = require "global"
local util = require "util"

local protoc = require "protoc"
local serpent = require "serpent"

require "netdefines"

local ClientMsgProcHandler = require "msg_proc.client.client_msg_proc_handler"

NetForClient = {}

---------------------------------------------------------------------------------------------------------------------------
-- 模块函数
---------------------------------------------------------------------------------------------------------------------------
function NetForClient.OnConnCreated(conn_idx, is_success, param)
	global.net_for_client:DoConnCreated(conn_idx, is_success, param)
end

function NetForClient.OnConnClosed(conn_idx)
	global.net_for_client:DoConnClosed(conn_idx, false)
end

function NetForClient.OnDataReceived(conn_idx, data, len)
	global.net_for_client:DoDataReceived(conn_idx, data, len)
end

---------------------------------------------------------------------------------------------------------------------------
-- 对象函数
---------------------------------------------------------------------------------------------------------------------------
function NetForClient:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.tcp_server_ = tcpserver.new()
	o.msg_handler_ = ClientMsgProcHandler:New()
	o.enable_connect_ = true

    return o
end

function NetForClient:Init()
    self.msg_handler_:InitMsgHandle()
end

function NetForClient:Start()
    self.tcp_server_:start(global.config.ip_for_client, global.config.port_for_client, 
			NetForClient.OnConnCreated, NetForClient.OnConnClosed, NetForClient.OnDataReceived, 
			8192, 8192)
end

function NetForClient:Stop()
    self.tcp_server_:close()
end

function NetForClient:DoConnCreated(conn_idx, is_success, param)
	if not self.enable_connect_ then
		self.tcp_server_:disconnect(conn_idx)
		return
	end
	
	-- 创建各个玩家的session 会话对象
	global.client_session_mgr:AddAcceptSession(conn_idx)
end

function NetForClient:DoConnClosed(conn_idx, is_kickout)
	
	now_time = os.time
	global.client_session_mgr:CleanupAcceptSession(conn_idx)

	session = global.client_session_mgr:get_session_by_conn_idx(conn_idx)
	if session then
		-- 清除连接
		global.client_session_mgr:CleanupSession(session:get_conn_idx())
	end
	return
	
	--[[
	session = global.client_session_mgr:get_session_by_conn_idx(conn_idx)
	if session then
		session:set_offline_time(now_time)
		src_status = session:get_status()

		-----------------------------------------------------------------------------------
		if src_status == ClientSession.SS_LOGOUT then
			return
		end

		if src_status == ClientSession.SS_TRANSFERING then --等传送完后再处理LOGOUT, 而且这里is_kickout = false也作强行退出
			session.is_transfer_delay_logout_ = true
			return
		end

		if is_kickout then
			session:set_status(ClientSession.SS_LOGOUT) --截杀所有回来的消息
		else
			if src_status == ClientSession.SS_OFFLINEING then
				return
			else
				session:set_status(ClientSession.SS_OFFLINEING)
			end
		end
		----------------------------------------------------------------------------

		if src_status == ClientSession.SS_CREATED then
			-- 清除连接
			global.client_session_mgr:CleanupSession(session:get_conn_idx())

		elseif src_status == ClientSession.SS_LOGIN_DOING or src_status == ClientSession.SS_LOGIN_OK then
			-- 说明有可能已经发送给ws去验证了, 即可能在ws上已经创建了Session, 这时候要强制清除
			req_msg = {}
			req_msg.client_uid = session:get_client_uid()
			global.connect_server:SendToWS(cs2ws.ReqClientLogOut, req_msg)
			
			-- 清除连接
			global.client_session_mgr:CleanupSession(session:get_conn_idx())
			
		elseif ClientSession.SS_REQUEST_CHARINFO or ClientSession.SS_REQUEST_CREATE_PLAYER then
			session:set_status(ClientSession.SS_LOGOUT)

		elseif ClientSession.SS_INGAME or ClientSession.SS_OFFLINEING then
			req_msg = {}
			req_msg.client_uid = session:get_client_uid()
			req_msg.is_kickout = is_kickout;
			session:SendToMS(cs2ms.ReqClientLogOut, req_msg)
		else
			LOG_ERROR("client_session status is fail")
		end
	
	end--]]
end

function NetForClient:DoDataReceived(conn_idx, data, len)
	if not self.enable_connect_ then
		self.tcp_server_:disconnect(conn_idx)
		return
	end

	cmd = GetCmd(data)
	cmd_name = c2s_array[cmd]
	msg = pb.decode_cmd(cmd_name, data)
	msg.cmd = cmd
	
	self.msg_handler_:OnNetworkClient(conn_idx, msg)
end

function NetForClient:SendToClient(conn_idx, cmd, data)
	if self.tcp_server_ then
		cmd_name = s2c_array[cmd]
		bytes = pb.encode_cmd(cmd_name, data, cmd)
		len = #bytes
		self.tcp_server_:send_msg(conn_idx, bytes, len)
	end
end

function NetForClient:DisconnectClient(conn_idx)
	if self.tcp_server_ then
		self.tcp_server_:disconnect(conn_idx)
	end
end

function NetForClient:switch_client_connect(enable_connect)
	enable_connect_ = enable_connect
end


return NetForClient
