local util = require "util"
local global = require "global"

MemcacheMgr = {}



--------------------------------------------------------------------------------------------
function MemcacheMgr:New(o)
    o = o or {}
	self.__index = self
	setmetatable(o, self)
	
	-- �����б�
	o.memcache_char_map_ = {}
	
	-- �������
	o.query_request_map_ = {}
	
    return o
end

function MemcacheMgr:Update(srv_time)
	
end

-- ���ýӿ�
function MemcacheMgr:RequestCharacterInfo(pid, account_idx, srv_uid, client_uid)
	
end

-- ����cachesΪ��ʱ
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

-- �ص��ӿ�
function MemcacheMgr:TriggerRequestCallBack(pid, memcache)
	
end

function MemcacheMgr:RequestQuery(pid, account_idx)
	
end


return MemcacheMgr