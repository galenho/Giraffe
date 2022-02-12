local common = require "common"
local util = require "util"
local global = require "global"

WSHandler = {}

function WSHandler.HandleRepClientLogin(peer, msg)
	session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
	if not session then
		return
	end

	if session:get_status() ~= ClientSession.SS_LOGIN_DOING then
		-- 状态不对
		LOG_ERROR("WorldServer::HandleRepLogin : status error.")
		return
	end

	local rep_msg = {}
	rep_msg.login_result = msg.login_result

	-- 登陆成功，进行后续操作
	if msg.login_result == LoginResult.E_LR_SUCCESS then
		session.at_ws_ = peer
		
		session:set_status(ClientSession.SS_LOGIN_OK)
		session:set_account_idx(msg.account_idx)
		session:set_ping_time(os.time())
		session:set_account_name(msg.account_name)
		
		rep_msg.account_idx = session:get_account_idx()
		session:SendMsg(s2c.S2CRepClientLogin, rep_msg)
		--LOG_DEBUG(g_logger, "login success ")
	else
		session:SendMsg(s2c.S2CRepClientLogin, rep_msg)		
	end
end

function WSHandler.HandleRepClientLogout(peer, msg)
	if msg.result then
		session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
		if session then
			global.client_session_mgr:CleanupSession(session:get_conn_idx())
		end
	end
end

function WSHandler.HandleKickoutAccount(peer, msg)
	session = global.client_session_mgr:get_session_by_uid(msg.client_uid);
	if session then
		if session:get_status() == ClientSession.SS_OFFLINEING then --断线重连类型, 因为这时候网络连接已经是关闭了
			global.net_for_client:DoConnClosed(session:get_conn_idx(), true);
		else --普通网络连接断开
			--LOG_DEBUG("DisconnectClient: " .. session:get_conn_idx())
			global.net_for_client:DoConnClosed(session:get_conn_idx(), true)
			global.net_for_client:DisconnectClient(session:get_conn_idx())
		end
	end
end

function WSHandler.HandleProxyWsMsg(peer, msg)

	session = global.client_session_mgr:get_session_by_uid(msg.client_uid);
	if session then
		session:SendMsg(msg.proxy_cmd, msg.proxy_data)	
	end
end

return WSHandler