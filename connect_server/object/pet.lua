local Unit = require "object.unit"

Pet = Unit:New()

function Pet:New(o)
    o = o or Unit:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function Pet:LoadRes()
    LOG_INFO("Pet:LoadRes")
end

return Pet