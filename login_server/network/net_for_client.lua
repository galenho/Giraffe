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
    self.tcp_server_:start(global.config.ip_for_client, global.config.port_for_client, NetForClient.OnConnCreated, NetForClient.OnConnClosed, NetForClient.OnDataReceived, 8192, 8192)
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
	
	local now_time = os.time
	global.client_session_mgr:CleanupAcceptSession(conn_idx)

	local session = global.client_session_mgr:get_session_by_conn_idx(conn_idx)
	if session then
		-- 清除连接
		global.client_session_mgr:CleanupSession(session:get_conn_idx())
	end
end

function NetForClient:DoDataReceived(conn_idx, data, len)
	if not self.enable_connect_ then
		self.tcp_server_:disconnect(conn_idx)
		return
	end

	local cmd = GetCmd(data)
	local cmd_name = c2s_array[cmd]
	local msg = pb.decode_cmd(cmd_name, data)
	msg.cmd = cmd
	
	self.msg_handler_:OnNetworkClient(conn_idx, msg)
end

function NetForClient:SendToClient(conn_idx, cmd, data)
	if self.tcp_server_ then
		local cmd_name = s2c_array[cmd]
		local bytes = pb.encode_cmd(cmd_name, data, cmd)
		local len = #bytes
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
