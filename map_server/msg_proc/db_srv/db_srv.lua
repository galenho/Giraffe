local Peer = require "peer"

DBServer = Peer:New()

function DBServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	o.a = 5
	
    return o
end

function DBServer:InitMsgHandle()
    
end

return DBServer