local Peer = require "peer"
local ds_hander = require "msg_proc.db_srv.ds_handler"

DBServer = Peer:New()

function DBServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function DBServer:RegisterMessage(cmd, handler)
    if self.handlers_[cmd] then
        LOG_ERROR("insert failed. cmd:" .. cmd)
        return false
    end
	
    self.handlers_[cmd] = handler
	
    return true
end

function DBServer:InitMsgHandle()
	
end


return DBServer