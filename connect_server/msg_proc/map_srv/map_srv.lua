local Peer = require "peer"
local ms_hander = require "msg_proc.map_srv.ms_handler"

MapServer = Peer:New()

function MapServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function MapServer:RegisterMessage(cmd, handler)
	if self.handlers_[cmd] then
		LOG_ERROR("insert failed. cmd:" .. cmd)
		return false
	end

	self.handlers_[cmd] = handler

	return true
end

function MapServer:InitMsgHandle()
    
end

return MapServer