local luaxml = require "luaxml"
local util   = require "util"
local common = require "common"
local global = require "global"

local protoc = require "protoc"
local serpent = require "serpent"

local client_handler = require "client_handler"

require "netdefines"

ClientSession = {}


-- 未创建
ClientSession.SS_NONE					= 0
-- 刚创建
ClientSession.SS_CREATED				= 1

ClientSession.SS_CONN_CSM				= 2

ClientSession.SS_INIT_CS_INFO			= 3

-- 登录中
ClientSession.SS_LOGIN_DOING			= 4
-- 登录成功
ClientSession.SS_LOGIN_OK				= 5
-- 获取player角色信息
ClientSession.SS_REQUEST_CHARINFO		= 6
-- 已进入MS，游戏中
ClientSession.SS_INGAME					= 7
-- 传送中
ClientSession.SS_TRANSFERING			= 8
-- 登出中
ClientSession.SS_LOGOUT					= 9
-- 断线中
ClientSession.SS_OFFLINEING				= 10

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
	o.conn_idx_ = 0
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

function ClientSession:DoConnCreated()
	data = { account_name = self.account_name_, password = self.password_ }
	self:set_status(ClientSession.SS_LOGIN_DOING)
	
    print("c2s.C2SReqClientLogin")
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

function ClientSession:get_account_idx()
	return self.account_idx_
end

function ClientSession:set_account_idx(account_idx)
	self.account_idx_ = account_idx
end


return ClientSession