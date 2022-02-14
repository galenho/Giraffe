local util = require "util"
local global = require "global"
local List = require "list"
local Memcache = require "memcache.memcache"

require "protocol"

MemcacheMgr = {}

function MemcacheMgr.OnCharaterDataCallBack(is_success, rs, param)
    local memcache = global.memcache_mgr:get_memcache(param.pid)
    if not memcache then
        return
    end
    
    if is_success then
        memcache.character_data_ = rs
        memcache.loaded_ = true
        global.memcache_mgr:TriggerRequestCallBack(param.pid, memcache)
    else
        global.memcache_mgr:CleanupMemcache(param.pid)
    end
end

function MemcacheMgr.SaveCharaterDataCallBack(is_success, rs, param)
    if not is_success then
        
    end
end

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

	-- �ȿ�������û������, ���û���ٲ�ѯ���ݿ�
	self:PushRequestMap(pid, account_idx, srv_uid, client_uid)

	local memcache = global.memcache_mgr:get_memcache(pid)
	if memcache and memcache.loaded_ then
		self:TriggerRequestCallBack(pid, memcache)
	else -- ������û�еģ�����sql��ѯ������棬�ٻظ�CS
		self:RequestQuery(pid, account_idx)
    end
end

-- ����cachesΪ��ʱ
function MemcacheMgr:set_caches_over_time(pid)
    
end

function MemcacheMgr:get_memcache(pid)
	return self.memcache_char_map_[pid]
end

function MemcacheMgr:CleanupMemcache(pid)
	self.memcache_char_map_[pid] = nil
end

function MemcacheMgr:SaveToDB(memcache)
	global.gamedb:update_one("player", {pid=memcache.pid_}, {["$set"] = {base_info = memcache.character_data_.base_info}}, SaveCharaterDataCallBack, memcache.gamedb_worker_thread_)
end

function MemcacheMgr:SaveAllToDB()
	for key, memcache in memcache_char_map_ do
		if memcache.loaded_ and memcache.is_dirty_ then
            self:SaveToDB(memcache)
		end	
    end
end

-- ѹ������
function MemcacheMgr:PushRequestMap(pid, account_idx, srv_uid, client_uid)
	local cmd = {pid = pid, srv_uid = srv_uid, client_uid = client_uid}

	local request_cmd_infos = self.query_request_map_[pid]
	if request_cmd_infos then --�����˲�ѯ
		List.pushBack(request_cmd_infos.query_cmds, cmd)
	else --û�˲�ѯ, ����һ���ѯ����
		request_cmd_infos = {}
		request_cmd_infos.query_cmds = List.new()
        List.pushBack(request_cmd_infos.query_cmds, cmd)

		self.query_request_map_[pid] = request_cmd_infos
    end
end

-- �ص��ӿ�
function MemcacheMgr:TriggerRequestCallBack(pid, memcache)
	local request_cmd_infos = self.query_request_map_[pid]
	if request_cmd_infos then
		local rep_msg = {}
		rep_msg.data = memcache.character_data_
        
		while not List.isEmpty(request_cmd_infos.query_cmds) do
            local cmd = List.front(request_cmd_infos.query_cmds)
            
            rep_msg.client_uid = cmd.client_uid
			rep_msg.pid = cmd.pid

			local peer = global.net_for_server:get_peer_by_uid(cmd.srv_uid)
			if peer then
                peer:Send(ds2cs.RepCharacterData, rep_msg)
            end
            
            List.popFront(request_cmd_infos.query_cmds)
        end

		self.query_request_map_[pid] = nil
    end
end

-- ��ѯ����
function MemcacheMgr:RequestQuery(pid, account_idx)
	local memcache = Memcache:New()
    memcache.gamedb_worker_thread_ = global.gamedb:get_free_connect()
	memcache.pid_ = pid
	memcache.account_idx_ = account_idx

	self.memcache_char_map_[pid] = memcache

    global.gamedb:find_one("player", {pid=pid, account_idx=account_idx}, {}, MemcacheMgr.OnCharaterDataCallBack, {pid = pid, account_idx = account_idx})
end

return MemcacheMgr