ServerRunInfo = {}

function ServerRunInfo:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	o.a = 5
	
    return o
end

function ServerRunInfo:OnMsEnter(peer)
	
	
end

return ServerRunInfo