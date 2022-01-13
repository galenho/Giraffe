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

	o.accept_kickout_session_ = {}
	o.ping_kickout_session_ = {}
	o.offline_kickout_session_ = {}

	o.logout_session_map_ = {}
	o.waitting_logout_sessions_ = {}
    return o
end

function ClientSessionMgr:AddAcceptSession(conn_idx)
	self.accept_session_map_[conn_idx] = os.time()
end

function ClientSessionMgr:CleanupAcceptSession(conn_idx)
	self.accept_session_map_[conn_idx] = nil
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

function ClientSessionMgr:OnMSClosed(ss_uid)
	
end

function ClientSessionMgr:OnWSClosed(ws_uid)
	
end

function ClientSessionMgr:CloseAllClient()
	for key, value in pairs(self.client_session_by_conn_idx_map_) do
        session = value
		self.waitting_logout_sessions_[session:get_client_uid()] = session
    end

	-- 第一次尝试关闭客户端
	self:TryContinueCloseOtherClient()
end

function ClientSessionMgr:TryContinueCloseOtherClient()
	count = #self.logout_session_map_
	have_session_count = 50 - count
	
	for key, value in pairs(self.logout_session_map_) do
		if have_session_count > 0 then
			session = value
			have_session_count = have_session_count - 1
			self.logout_session_map_[key] = nil
			
			self.logout_session_map_[session:get_client_uid()]= session
			global.net_for_client:DoConnClosed(session:get_conn_idx(), true)
			global.net_for_client:DisconnectClient(session:get_conn_idx())
		else
			break
		end
    end
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