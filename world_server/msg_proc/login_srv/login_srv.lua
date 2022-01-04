local Peer = require "peer"

LoginServer = Peer:New()

function LoginServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function LoginServer:InitMsgHandle()
    
end

return LoginServer