local util = require "util"
local global = require "global"

Memcache = {}

function Memcache:New(o)
    o = o or {}
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	o.a = 5

    return o
end

return Memcache