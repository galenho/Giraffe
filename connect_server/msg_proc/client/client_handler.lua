local common = require "common"
local util = require "util"
local global = require "global"

ClientHandler = {}

function ClientHandler.HandleReqEnterGame(session, msg)
    -- 只有登陆成功, 才允许请求玩家数据
	if session:get_status() ~= ClientSession.SS_LOGIN_OK and session:get_status() ~= ClientSession.SS_INGAME then
		return
	end

	req_msg = {}
	req_msg.client_uid = session:get_client_uid()
	req_msg.account_idx = session:get_account_idx()
	req_msg.pid = msg.pid
	global.connect_server:SendToDS(cs2ds.ReqCharacterData, req_msg)
	
	session:set_status(ClientSession.SS_REQUEST_CHARINFO)
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