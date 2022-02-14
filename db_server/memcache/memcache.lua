local util = require "util"
local global = require "global"

Memcache = {}

function Memcache:New(o)
    o = o or {}
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
    o.character_data_ = {}
    o.gamedb_worker_thread_ = 0
    o.pid_ = 0
    o.account_idx_ = 0
    o.loaded_ = false
    
    return o
end

return Memcache