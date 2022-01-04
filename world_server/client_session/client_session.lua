local common = require "common"
local util = require "util"
local Player = require "object.player"

ClientSession = {}

-- 未创建
ClientSession.SS_NONE			= 0
-- 刚创建
ClientSession.SS_CREATED		= 1
-- 登录中
ClientSession.SS_LOGIN_DOING	= 2
-- 登录成功
ClientSession.SS_LOGIN_OK		= 3
-- 已进入SS，游戏中
ClientSession.SS_INGAME			= 4
-- 登出中
ClientSession.SS_LOGOUT			= 5

function ClientSession:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.client_uid_ = 0
	o.platform_idx_ = 0
	o.client_ip_ = ""
	o.account_idx_ = 0
	o.account_name_ = ""
	o.logout_over_time_ = 0
	
	o.status_ = ClientSession.SS_CREATED
	o.at_ms_ = nil
	o.at_cs_ = nil
	o.player_ = Player:New()

    return o
end

function ClientSession:Init(client_uid)
	self.client_uid_ = client_uid
	self.player_.set_owner(self)
end

function ClientSession:get_status()
	return self.status_
end

function ClientSession:set_status(status)
	self.status_ = status
end

function ClientSession:get_client_uid()
	return self.client_uid_
end

function ClientSession:get_account_name()
	return self.account_name_
end

function ClientSession:set_account_name(account_name)
	self.account_name_ = account_name
end

function ClientSession:get_account_idx()
	return self.account_idx_
end

function ClientSession:set_account_idx(account_idx)
	self.account_idx_ = account_idx
end

function ClientSession:get_client_ip()
	return self.client_ip_
end

function ClientSession:set_logout_over_time(logout_over_time)
	logout_over_time_ = logout_over_time
end

function ClientSession:SendToCS(cmd, data)
	if self.at_cs_ then
		self.at_cs_:Send(cmd, data)
	end
end

function ClientSession:SendToClient(cmd, data)
	if self.at_cs_ then
		proxy_msg = {}
		proxy_msg.client_uid = self:get_client_uid()
		proxy_msg.proxy_cmd = cmd
		proxy_msg.proxy_data = data
		
		self.at_cs_:Send(ws2cs.ProxyWsMsg, proxy_msg)
	end
end

function ClientSession:get_player()
	return self.player_
end

return ClientSession