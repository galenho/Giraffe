local common = require "common"
local global = require "global"

ClientSession = {}

-- 刚创建
ClientSession.SS_CREATED				= 1
-- 请求进入游戏CSM
ClientSession.SS_CSM_VERIFY		= 2
-- 获取player角色信息
ClientSession.SS_REQUEST_CHARINFO		= 3
-- 请求创建角色
ClientSession.SS_REQUEST_CREATE_PLAYER	= 4
-- 已进入MS，游戏中
ClientSession.SS_INGAME					= 5
-- 传送中
ClientSession.SS_TRANSFERING			= 6
-- 登出中
ClientSession.SS_LOGOUT					= 7
-- 断线中
ClientSession.SS_OFFLINEING				= 8

function ClientSession:New(o, conn_idx)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.conn_idx_ = 0
	o.client_uid_ = 0
	
	o.account_idx_ = 0
	o.account_name_ = ""
	o.client_ip_ = ""
	o.platform_idx = 0

	o.status_ = ClientSession.SS_CREATED
	o.is_transfer_delay_logout_ = false
	o.last_offline_time_ = 0
	o.last_ping_time_ = 0
	
	o.at_ms_ = nil
	o.at_ws_ = nil
	o.player_ = nil

    return o
end

function ClientSession:Init(conn_idx)
	self.conn_idx_ = conn_idx
	serial_idx = global.server_res_mgr:get_serial_idx()
	self.client_uid_ = GenerateClientUID(serial_idx, conn_idx)
	
	if self.client_uid_ == 0 then
		print("serial_idx: " .. serial_idx .. " conn_idx: " .. conn_idx)
	end
end

function ClientSession:Update(srv_time)
	
end

function ClientSession:get_conn_idx()
	return self.conn_idx_
end

function ClientSession:set_conn_idx(conn_idx)
	self.conn_idx_ = conn_idx
end

function ClientSession:get_status()
	return self.status_
end

function ClientSession:set_status(status)
	self.status_ = status
end

function ClientSession:get_ping_time()
	return self.last_ping_time_
end

function ClientSession:set_ping_time(time)
	self.last_ping_time_ = time
end

function ClientSession:get_offline_time()
	return self.last_offline_time_
end

function ClientSession:set_offline_time(time)
	self.last_offline_time_ = time
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

function ClientSession:SendMsg(cmd, data)
	if self.conn_idx_ ~= INVALID_INDEX then
		global.net_for_client:SendToClient(self.conn_idx_, cmd, data)
	end
end

function ClientSession:SendToWS(cmd, data)
	if self.at_ws_ then
		self.at_ws_:Send(cmd, data)
	end
end

function ClientSession:SendToMS(cmd, data)
	if self.at_ms_ then
		self.at_ms_:Send(cmd, data)
	end
end

return ClientSession