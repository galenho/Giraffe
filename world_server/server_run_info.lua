ServerRunInfo = {}

function ServerRunInfo:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function ServerRunInfo:OnMsEnter(peer)
	
	
end

return ServerRunInfo