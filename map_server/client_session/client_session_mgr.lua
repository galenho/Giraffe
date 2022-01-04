local common = require "common"

ClientSessionMgr = {}

function ClientSessionMgr:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	
    return o
end


return ClientSessionMgr