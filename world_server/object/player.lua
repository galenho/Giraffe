local Unit = require "object.unit"

Player = Unit:New()

function Player:New(o)
    o = o or Unit:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.is_loaded_ = false;
	o.client_session_ = nil;

    return o
end

function Player:set_owner(session)
	self.client_session_ = session
end

function Player:LoadRes()
    LOG_INFO("Player:LoadRes")
end

function Player:IsLoaded()
	return self.is_loaded_
end

function Player:get_pid()
	
end

return Player