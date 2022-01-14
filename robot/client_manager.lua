local luaxml = require "luaxml"
local util = require "util"
local common = require "common"
local global = require "global"
local ClientSession = require "client_session"

require "protocol"

ClientManager = {}


---------------------------------------------------------------------------------------------------------------------------
-- 对象函数
---------------------------------------------------------------------------------------------------------------------------
function ClientManager:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.client_session_map_ = {}
	o.client_conn_map_ = {}

    return o
end

function ClientManager:Init()
    
end

function ClientManager:Start()
	for i=1, 100, 1 do
		account_idx = i
		client_session = ClientSession:New()
		client_session:InitMsgHandle()
		client_session.account_idx_ = account_idx
		client_session.account_name_ = "test" .. i
		client_session.password_ = "1"
		
		self.client_session_map_[account_idx] = client_session
		client_session:Start()
	end
end

function ClientManager:Stop()
    
end

return ClientManager