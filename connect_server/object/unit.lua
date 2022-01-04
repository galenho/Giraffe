Unit = {}

function Unit:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function Unit:LoadRes()
    LOG_INFO("Unit:LoadRes")
end

return Unit