local Peer = require "peer"

LogServer = Peer:New()

function LogServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function LogServer:RegisterMessage(cmd, handler)
	if self.handlers_[cmd] then
		LOG_ERROR("insert failed. cmd:" .. cmd)
		return false
	end

	self.handlers_[cmd] = handler

	return true
end

function LogServer:InitMsgHandle()
    
end

return LogServer