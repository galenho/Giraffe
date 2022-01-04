local Peer = require "peer"

MapServer = Peer:New()

function MapServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function MapServer:InitMsgHandle()
    
end

return MapServer