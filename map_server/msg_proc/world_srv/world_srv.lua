local Peer = require "peer"

WorldServer = Peer:New()

function WorldServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	o.a = 5
	
    return o
end

function WorldServer:InitMsgHandle()
    
end

return WorldServer