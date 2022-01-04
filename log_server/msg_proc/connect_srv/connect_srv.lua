local Peer = require "peer"

ConnectServer = Peer:New()

function ConnectServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function ConnectServer:InitMsgHandle()
    
end

return ConnectServer