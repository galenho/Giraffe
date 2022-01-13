local Peer = require "peer"
local ls_hander = require "msg_proc.login_srv.ls_handler"
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
	self:RegisterMessage(ls2ds.ReqClientLogin,     ls_hander.HandleReqClientLogin)
    self:RegisterMessage(ls2ds.ReqCharacterList,   ls_hander.HandleReqCharacterList)
    self:RegisterMessage(ls2ds.ReqCreateCharacter, ls_hander.HandleReqCreateCharacter)
end

return WorldServer