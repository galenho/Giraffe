local Peer = require "peer"
local global = require "global"
local csm_hander = require "msg_proc.connect_mgr.csm_handler"

ConnectServerMgr = Peer:New()

function ConnectServerMgr:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
    return o
end

function ConnectServerMgr:RegisterMessage(cmd, handler)
	if self.handlers_[cmd] then
		LOG_ERROR("insert failed. cmd:" .. cmd)
		return false
	end

	self.handlers_[cmd] = handler

	return true
end

function ConnectServerMgr:InitMsgHandle()
    
end

return ConnectServerMgr