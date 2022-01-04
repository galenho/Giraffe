local Peer = require "peer"

WorldServer = Peer:New()

function WorldServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function WorldServer:InitMsgHandle()
    
end

return WorldServer