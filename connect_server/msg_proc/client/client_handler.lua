local common = require "common"
local util = require "util"
local global = require "global"

ClientHandler = {}

function ClientHandler.HandleReqEnterGame(conn_idx, msg)

    session = global.client_session_mgr:get_session_by_conn_idx(conn_idx)
    if session then
        return
    end
    
    session = global.client_session_mgr:AddSession(conn_idx)
    session:set_status(ClientSession.SS_CSM_VERIFY)
    session:set_account_idx(msg.account_idx)
    
    -- 发SessionKey到csmgr到验证    
	req_msg = {}
	req_msg.client_uid = session:get_client_uid()
	req_msg.account_idx = session:get_account_idx()
	req_msg.pid = msg.pid
    req_msg.session_key = msg.session_key

	global.connect_server:SendToCSM(cs2csm.ReqEnterGame, req_msg)
end

function ClientHandler.HandleProxyMsgToWS(session, msg)
    -- 只有登陆成功才允许直接代理
	if session:get_status() ~= ClientSession.SS_LOGIN_OK and session:get_status() ~= ClientSession.SS_INGAME then
		LOG_ERROR("HandleProxyMsgToWS, invalid session status: " .. session:get_status() .. " when it is proxy msg to ws.msg id:" .. msg.cmd)
		return
	end
	
	proxy_msg = {}
	proxy_msg.client_uid = session:get_client_uid()
	proxy_msg.proxy_data = msg
	session:SendToWS(cs2ws.ProxyClientMsg, proxy_msg)
end

function ClientHandler.HandleProxyMsgToMS(session, msg)
    
end

return ClientHandler