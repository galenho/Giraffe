local Peer = require "peer"

MapServer = Peer:New()

function MapServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	o.a = 5
	
    return o
end

function MapServer:InitMsgHandle()
    
end

return MapServer