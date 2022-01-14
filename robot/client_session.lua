local luaxml = require "luaxml"
local util   = require "util"
local common = require "common"
local global = require "global"

local protoc = require "protoc"
local serpent = require "serpent"

local client_handler = require "client_handler"

require "netdefines"

ClientSession = {}

-- 刚创建
ClientSession.SS_CREATED				= 1
-- 登录中
ClientSession.SS_LOGIN_DOING			= 2
-- 登录成功
ClientSession.SS_LOGIN_OK				= 3

-- 获取player角色信息
ClientSession.SS_REQUEST_CHARINFO		= 4
-- 已进入MS，游戏中
ClientSession.SS_INGAME					= 5
-- 传送中
ClientSession.SS_TRANSFERING			= 6
-- 登出中
ClientSession.SS_LOGOUT					= 7
-- 断线中
ClientSession.SS_OFFLINEING				= 8


---------------------------------------------------------------------------------------------------------------------------
-- 模块函数
---------------------------------------------------------------------------------------------------------------------------
function ClientSession.OnConnCreated(conn_idx, is_success, param)
    client_session = global.client_manager.client_session_map_[param.account_idx]
	
	if is_success then
		client_session.conn_idx_ = conn_idx
		global.client_manager.client_conn_map_[conn_idx] = client_session
		client_session:DoConnCreated()
	else --不成功，进行重连
		crossover.add_timer(RETRY_CONNECT_INTERVAL, ClientManager.RetryConnect, param)
	end
end

function ClientSession.OnConnClosed(conn_idx)
    client_session = global.client_manager.client_conn_map_[conn_idx]
	client_session:DoConnClosed()
	global.client_manager.client_conn_map_[conn_idx] = nil
end

function ClientSession.OnDataReceived(conn_idx, data, len)

    client_session = global.client_manager.client_conn_map_[conn_idx]
	cmd = GetCmd(data)
	cmd_name = s2c_array[cmd]
	msg = pb.decode_cmd(cmd_name, data)
	msg.cmd = cmd

	client_session:HandleMsg(msg)
end

function ClientSession.Connect2Server(ip, port, account_idx)
	param = {ip = ip, port = port, account_idx = account_idx}
	global.tcp_client:connect(ip, port, 
							ClientSession.OnConnCreated, ClientSession.OnConnClosed, ClientSession.OnDataReceived,
							1024 * 8, 4096, true, param)
end

function ClientSession.RetryConnect(timer_id, param)
	crossover.remove_timer(timer_id)
	ClientSession.Connect2Server(param.ip, param.port, param.account_idx);
end


---------------------------------------------------------------------------------------------------------------------------
-- 对象函数
---------------------------------------------------------------------------------------------------------------------------
function ClientSession:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.account_idx_ = 0
	o.account_name_ = ""
	o.password_ = ""
	o.conn_idx_ = INVALID_INDEX
	o.handlers_ = {}
	o.status_ = ClientSession.SS_CREATED
	
    return o
end

function ClientSession:RegisterMessage(cmd, handler)
    if self.handlers_[cmd] then
        LOG_ERROR("insert failed. cmd:" .. cmd)
        return false
    end
	
    self.handlers_[cmd] = handler

    return true
end

function ClientSession:InitMsgHandle()
	self:RegisterMessage(s2c.S2CRepClientLogin, client_handler.HandleRepClientLogin)
    self:RegisterMessage(s2c.S2CRepCharacterList, client_handler.HandleRepCharacterList)
    self:RegisterMessage(s2c.S2CRepCreateCharacter, client_handler.HandleRepCreateCharacter)
end

function ClientSession:Start()
    ClientSession.Connect2Server(global.config.ip, global.config.port, self.account_idx_)
end


function ClientSession:DoConnCreated()
	data = { account_name = self.account_name_, password = self.password_ }
	self:set_status(ClientSession.SS_LOGIN_DOING)
	
	self:SendMsg(c2s.C2SReqClientLogin, data)
end

function ClientSession:DoConnClosed()
	
end

function ClientSession:HandleMsg(msg)
	if self.handlers_[msg.cmd] then
		self.handlers_[msg.cmd](self, msg)
	else

	end
end

function ClientSession:SendMsg(cmd, data)
	cmd_name = c2s_array[cmd]
	bytes = pb.encode_cmd(cmd_name, data, cmd)
	len = #bytes

	if self.conn_idx_ then
		global.tcp_client:send_msg(self.conn_idx_, bytes, len)
	end
end

function ClientSession:Disconnect()
	global.tcp_client:disconnect(self.conn_idx_)
    self.conn_idx_ = INVALID_INDEX
end

function ClientSession:get_status()
	return self.status_
end

function ClientSession:set_status(status)
	self.status_ = status
end


function ClientSession:get_account_name()
	return self.account_name_
end

function ClientSession:set_account_name(account_name)
	self.account_name_ = account_name
end

function ClientSession:set_account_idx(account_idx)
	self.account_idx_ = account_idx
end

function ClientSession:get_account_idx()
	return self.account_idx_
end

function ClientSession:set_account_idx(account_idx)
	self.account_idx_ = account_idx
end


return ClientSession