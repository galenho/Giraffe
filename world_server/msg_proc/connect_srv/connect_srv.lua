local Peer = require "peer"
local client_hander = require "msg_proc.connect_srv.client_handler"
local cs_hander = require "msg_proc.connect_srv.cs_handler"
local util = require "util"

ConnectServer = Peer:New()

function ConnectServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量

    return o
end

function ConnectServer:RegisterMessage(cmd, handler)
    if self.handlers_[cmd] then
        LOG_ERROR("insert failed. cmd:" .. cmd)
        return false
    end
	
    self.handlers_[cmd] = handler
	
    return true
end

function ConnectServer:RegisterClientMessage(cmd, handler)
    if self.client_handlers_[cmd] then
        LOG_ERROR("insert failed. cmd:" .. cmd)
        return false
    end
	
    self.client_handlers_[cmd] = handler
	
    return true
end

function ConnectServer:InitMsgHandle()

end

return ConnectServer