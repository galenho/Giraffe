local common = require "common"
local global = require "global"
local util = require "util"
local ClientSession = require "client_session.client_session"

ClientSessionMgr = {}

function ClientSessionMgr:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.client_session_by_conn_idx_map_ = {}
	o.client_session_by_uid_map_ = {}
	
	o.accept_session_map_ = {}

    return o
end

function ClientSessionMgr:AddAcceptSession(conn_idx)
	self.accept_session_map_[conn_idx] = os.time()
end

function ClientSessionMgr:CleanupAcceptSession(conn_idx)
	self.accept_session_map_[conn_idx] = nil
end

function ClientSessionMgr:has_accept_session(conn_idx)
    if self.accept_session_map_[conn_idx] then
        return true
    else
        return false
    end
end

function ClientSessionMgr:AddSession(conn_idx)
	session = ClientSession:New()
	session:Init(conn_idx)
	
	if self.client_session_by_conn_idx_map_[conn_idx] then
		assert(false)
		return
	end
	
	if self.client_session_by_uid_map_[session:get_client_uid()] then
		assert(false)
		return
	end
	
	self.client_session_by_conn_idx_map_[conn_idx] = session
	self.client_session_by_uid_map_[session:get_client_uid()] = session
    
	return session
end

function ClientSessionMgr:CleanupSession(conn_idx)
	session = self.client_session_by_conn_idx_map_[conn_idx]
	self.client_session_by_uid_map_[session:get_client_uid()] = nil
	self.client_session_by_conn_idx_map_[conn_idx] = nil
end

function ClientSessionMgr:OnWSClosed(ws_uid)
	
end

function ClientSessionMgr:CloseAllClient()
	
end

function ClientSessionMgr:get_session_count()
	return table_len(self.client_session_by_conn_idx_map_)
end

function ClientSessionMgr:get_session_by_conn_idx(conn_idx)
	return self.client_session_by_conn_idx_map_[conn_idx]
end

function ClientSessionMgr:get_session_by_uid(client_uid)
	return self.client_session_by_uid_map_[client_uid]
end

function ClientSessionMgr:Broadcast(cmd, data)
	for key, value in pairs(self.client_session_by_conn_idx_map_) do
        session = value
		if session:get_status() == ClientSession.SS_INGAME or session:get_status() == ClientSession.SS_TRANSFERING then
			session:SendMsg(cmd, data)
		end
    end
end

function ClientSessionMgr:get_enter_game_session_count()
	count = 0
	for key, value in pairs(self.client_session_by_conn_idx_map_) do
        session = value
		if session:get_status() == ClientSession.SS_INGAME or session:get_status() == ClientSession.SS_OFFLINEING then
			count = count + 1
		end
    end

	return count
end

function ClientSessionMgr:get_offline_session_count()
	count = 0
	for key, value in pairs(self.client_session_by_conn_idx_map_) do
        session = value
		if session:get_status() == ClientSession.SS_OFFLINEING then
			count = count + 1
		end
    end

	return count
end

return ClientSessionMgr