local Peer = require "peer"

LogServer = Peer:New()

function LogServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	o.a = 5
	
    return o
end

function LogServer:InitMsgHandle()
    
end

return LogServer