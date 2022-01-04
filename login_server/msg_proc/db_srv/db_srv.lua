local Peer = require "peer"
local ds_hander = require "msg_proc.db_srv.ds_handler"

DBServer = Peer:New()

function DBServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	
	
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
    self:RegisterMessage(ds2ws.RepClientLogin, ds_hander.HandleRepClientLogin)
    self:RegisterMessage(ds2ws.RepCharacterList, ds_hander.HandleRepCharacterList)
    self:RegisterMessage(ds2ws.RepCreateCharacter, ds_hander.HandleRepCreateCharacter)
    self:RegisterMessage(ds2ws.RepDeleteCharacter, ds_hander.HandleRepDeleteCharacter)
end

return DBServer