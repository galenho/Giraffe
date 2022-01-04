local Peer = require "peer"
local global = require "global"

ConnectServerMgr = Peer:New()

function ConnectServerMgr:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
    return o
end

function ConnectServerMgr:InitMsgHandle()
    
end

return ConnectServerMgr