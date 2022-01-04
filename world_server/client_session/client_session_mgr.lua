local common = require "common"
local global = require "global"

local ClientSession = require "client_session.client_session"

ClientSessionMgr = {}

function ClientSessionMgr:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.client_session_map_ = {}
	o.client_session_by_pid_map_ = {}

	o.online_account_map_ = {}
    return o
end

function ClientSessionMgr:get_client_session_by_uid(client_uid)
	return self.client_session_map_[client_uid]
end

function ClientSessionMgr:get_client_session_by_account(account_idx)
	return self.online_account_map_[account_idx]
end

function ClientSessionMgr:AddClient(client_uid)
	new_session = ClientSession:New()
	new_session:Init(client_uid)

	if self.client_session_map_[client_uid] then
		LOG_ERROR("ClientSessionMgr::AddClient: can not insert the new session:" .. client_uid );
		return nil	
	end
	
	self.client_session_map_[client_uid] = new_session
	return new_session
end

function ClientSessionMgr:CleanupClient(client_uid, is_delete_online_list)
	if self.client_session_map_[client_uid] then
		session = self.client_session_map_[client_uid]
		
		if is_delete_online_list then
			-- 也同时删除在线列表(在线的session不一定跟些session是同一session)
			self.online_account_map_[session:get_account_idx()] = nil
		end
		
		-- 如果已经在client_session_by_pid_map_列表中的话要删除它
		if session:get_player():IsLoaded() then
			self.client_session_by_pid_map_[session:get_player():get_pid()] = nil
		end

		self.client_session_map_[client_uid] = nil
		
	end
	
end

function ClientSessionMgr:AddOnlineAccount(session)
	if self.online_account_map_[session:get_account_idx()] then
		return false
	end
	
	self.online_account_map_[session:get_account_idx()] = session
	return true
end

return ClientSessionMgr