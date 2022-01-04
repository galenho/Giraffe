local Peer = require "peer"
local cs_hander = require "msg_proc.connect_srv.cs_handler"

ConnectServer = Peer:New()

function ConnectServer:New(o)
    o = o or Peer:New()
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function ConnectServer:RegisterMessage(cmd, handler)
    if self.handlers_[cmd] then
        LOG_ERROR("insert failed. cmd:" .. cmd)
        return false
    end
	
    self.handlers_[cmd] = handler
	
    return true
end

function ConnectServer:InitMsgHandle()
	self:RegisterMessage(cs2ds.ReqCharacterData, cs_hander.HandleReqCharacterData)
end


return ConnectServer