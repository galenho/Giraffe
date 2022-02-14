local common = require "common"
local util = require "util"
local global = require "global"
local client_hander = require "msg_proc.client.client_handler"

ClientMsgProcHandler = {}

function ClientMsgProcHandler:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
    o.handlers_ = {}
    return o
end

function ClientMsgProcHandler:RegisterMessage(cmd, handler)
    if self.handlers_[cmd] then
        LOG_ERROR("insert failed. cmd:" .. cmd)
        return false
    end
	
    self.handlers_[cmd] = handler

    return true
end

function ClientMsgProcHandler:InitMsgHandle()
    ----------------------------------------------------------------------
    -- ls
    ----------------------------------------------------------------------
    self:RegisterMessage(c2s.C2SReqCharacterList,   client_hander.HandleReqCharacterList)
    self:RegisterMessage(c2s.C2SReqCreateCharacter, client_hander.HandleReqCreateCharacter)
    self:RegisterMessage(c2s.C2SReqDeleteCharacter, client_hander.HandleReqDeleteCharacter)
end

function ClientMsgProcHandler:OnNetworkClient(conn_idx, msg)
   
    if msg.cmd == c2s.C2SReqClientLogin then
        client_hander.HandleReqClientLogin(conn_idx, msg)
    else
        session = global.client_session_mgr:get_session_by_conn_idx(conn_idx)
        
		if self.handlers_[msg.cmd] then
            self.handlers_[msg.cmd](session, msg)
        else
            LOG_ERROR("recv invalid msg idx:" .. msg.cmd)
        end
    end
end

return ClientMsgProcHandler