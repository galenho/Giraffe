local Unit = require "object.unit"

Player = Unit:New()

function Player:New(o)
    o = o or Unit:New()
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	o.a = 5
	
    return o
end

function Player:LoadRes()
    LOG_INFO("Player:LoadRes")
end

function Player:LoadR2()
    LOG_INFO("Player:LoadRes")
end

function Player:LoadR3()
	LOG_INFO("Player:LoadRes")
end

return Player