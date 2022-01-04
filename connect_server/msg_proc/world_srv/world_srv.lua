local Peer = require "peer"
local ws_hander = require "msg_proc.world_srv.ws_handler"

WorldServer = Peer:New()

function WorldServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.handlers_ = {}
	
    return o
end

function WorldServer:RegisterMessage(cmd, handler)
	if self.handlers_[cmd] then
		LOG_ERROR("insert failed. cmd:" .. cmd)
		return false
	end

	self.handlers_[cmd] = handler

	return true
end

function WorldServer:InitMsgHandle()
	
	self:RegisterMessage(ws2cs.RepClientLogin, ws_hander.HandleRepClientLogin)
	self:RegisterMessage(ws2cs.RepClientLogout, ws_hander.HandleRepClientLogout)
	self:RegisterMessage(ws2cs.KickOutAccount, ws_hander.HandleKickoutAccount)
	self:RegisterMessage(ws2cs.ProxyWsMsg, ws_hander.HandleProxyWsMsg)

end

return WorldServer