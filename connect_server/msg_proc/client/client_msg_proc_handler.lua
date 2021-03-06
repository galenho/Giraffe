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
    -- client
    ----------------------------------------------------------------------
    --self:RegisterMessage(c2s.C2SReqPing, client_hander.HandleReqPing)
    --self:RegisterMessage(c2s.C2SReqTransfer, client_hander.HandleReqTransfer)

    ----------------------------------------------------------------------
    -- ws
    ----------------------------------------------------------------------
    

    ----------------------------------------------------------------------
    -- ms
    ----------------------------------------------------------------------
    --self:RegisterMessage(c2s.ReqPingTime, client_hander.HandleProxyMsgToMS)

end

function ClientMsgProcHandler:OnNetworkClient(conn_idx, msg)
    if cmd == c2s.C2SReqEnterGame then

        client_hander.HandleReqEnterGame(conn_idx, msg)
        
    elseif self.handlers_[cmd] then

        session = global.client_session_mgr:get_session_by_conn_idx(conn_idx)
        self.handlers_[cmd](session, msg)

    else
        LOG_ERROR("recv invalid msg idx:" .. msg.cmd)
    end
end

return ClientMsgProcHandler