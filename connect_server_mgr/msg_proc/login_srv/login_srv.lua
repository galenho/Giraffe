local Peer = require "peer"
local ls_hander = require "msg_proc.login_srv.ls_handler"

LoginServer = Peer:New()

function LoginServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function LoginServer:RegisterMessage(cmd, handler)
	if self.handlers_[cmd] then
		LOG_ERROR("insert failed. cmd:" .. cmd)
		return false
	end

	self.handlers_[cmd] = handler

	return true
end

function LoginServer:InitMsgHandle()
    
    self:RegisterMessage(ls2csm.ReqCreateSession, ls_hander.HandleReqCreateSession)
    
end

return LoginServer