local Peer = require "peer"
local ds_hander = require "msg_proc.db_srv.ds_handler"

DBServer = Peer:New()

function DBServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- ����д��Ա����
	
	
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
	--self:RegisterMessage(ds2cs.RepClientLogin, ds_hander.HandleRepClientLogin)
end

return DBServer