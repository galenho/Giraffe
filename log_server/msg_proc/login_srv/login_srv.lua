local Peer = require "peer"
local ws_hander = require "msg_proc.world_srv.ws_handler"
local util = require "util"

WorldServer = Peer:New()

function WorldServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
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
	self:RegisterMessage(ws2ds.ReqClientLogin, ws_hander.HandleReqClientLogin)
    self:RegisterMessage(ws2ds.ReqCharacterList, ws_hander.HandleReqCharacterList)
    self:RegisterMessage(ws2ds.ReqCreateCharacter, ws_hander.HandleReqCreateCharacter)
    self:RegisterMessage(ws2ds.ReqDeleteCharacter, ws_hander.HandleReqDeleteCharacter)
end

return WorldServer