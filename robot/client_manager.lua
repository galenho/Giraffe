local luaxml = require "luaxml"
local util = require "util"
local common = require "common"
local global = require "global"
local ClientSession = require "client_session"

require "protocol"

ClientManager = {}

---------------------------------------------------------------------------------------------------------------------------
-- 模块函数
---------------------------------------------------------------------------------------------------------------------------
function ClientManager.RetryConnect(timer_id, param)
	crossover.remove_timer(timer_id)
	global.client_manager:Connect2Server(param.ip, param.port, param.account_idx);
end

function ClientManager.OnConnCreated(conn_idx, is_success, param)
	global.client_manager:DoConnCreated(conn_idx, is_success, param)
end

function ClientManager.OnConnClosed(conn_idx)
	global.client_manager:DoConnClosed(conn_idx)
end

function ClientManager.OnDataReceived(conn_idx, data, len)
	global.client_manager:DoDataReceived(conn_idx, data, len)
end


---------------------------------------------------------------------------------------------------------------------------
-- 对象函数
---------------------------------------------------------------------------------------------------------------------------
function ClientManager:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.client_session_map_ = {}
	o.client_conn_map_ = {}

    return o
end

function ClientManager:Init()
    
end

function ClientManager:Start()
	for i=1, 1, 1 do
		account_idx = i
		client_session = ClientSession:New()
		client_session:InitMsgHandle()
		client_session.account_idx_ = account_idx
		client_session.account_name_ = "test" .. i
		client_session.password_ = "1"
		
		self.client_session_map_[account_idx] = client_session
		self:Connect2Server(global.config.ip, global.config.port, account_idx)
	end
end

function ClientManager:Stop()
    
end

function ClientManager:Connect2Server(ip, port, account_idx)
	param = {ip = ip, port = port, account_idx = account_idx}
	global.tcp_client:connect(ip, port, 
							ClientManager.OnConnCreated, ClientManager.OnConnClosed, ClientManager.OnDataReceived,
							1024 * 1024 * 4, 4096, true, param)
end

function ClientManager:DoConnCreated(conn_idx, is_success, param)
	client_session = self.client_session_map_[param.account_idx]
	
	if is_success then
		client_session.conn_idx_ = conn_idx
		self.client_conn_map_[conn_idx] = client_session
		client_session:DoConnCreated()
	else --不成功，进行重连
		crossover.add_timer(RETRY_CONNECT_INTERVAL, ClientManager.RetryConnect, param)
	end
end

function ClientManager:DoConnClosed(conn_idx)
	client_session = self.client_conn_map_[conn_idx]
	client_session:DoConnClosed()
	self.client_conn_map_[conn_idx] = nil
end

function ClientManager:DoDataReceived(conn_idx, data, len)
	client_session = self.client_conn_map_[conn_idx]
	cmd = GetCmd(data)
	cmd_name = s2c_array[cmd]
	msg = pb.decode_cmd(cmd_name, data)
	msg.cmd = cmd

	client_session:HandleMsg(msg)
end

return ClientManager