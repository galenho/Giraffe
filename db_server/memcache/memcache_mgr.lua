local util = require "util"
local global = require "global"

MemcacheMgr = {}



--------------------------------------------------------------------------------------------
function MemcacheMgr:New(o)
    o = o or {}
	self.__index = self
	setmetatable(o, self)
	
	-- 缓存列表
	o.memcache_char_map_ = {}
	
	-- 请求队列
	o.query_request_map_ = {}
	
    return o
end

function MemcacheMgr:Update(srv_time)
	
end

-- 调用接口
function MemcacheMgr:RequestCharacterInfo(pid, account_idx, srv_uid, client_uid)
	
end

-- 设置caches为过时
function MemcacheMgr:set_caches_over_time(pid)
	
end

function MemcacheMgr:get_memcache(pid)
	
end

function MemcacheMgr:CleanupMemcache(pid)
	
end

function MemcacheMgr:SaveToDB(memcache)
	
end

function MemcacheMgr:SaveAllToDB()
	
end

function MemcacheMgr:PushRequestMap(pid, account_idx, srv_uid, client_uid)
	
end

-- 回调接口
function MemcacheMgr:TriggerRequestCallBack(pid, memcache)
	
end

function MemcacheMgr:RequestQuery(pid, account_idx)
	
end


return MemcacheMgr