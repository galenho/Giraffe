local common = require "common"
local util = require "util"
local global = require "global"

DSHandler = {}

function DSHandler.HandleRepClientLogin(peer, msg)
    
	client_session = global.client_session_mgr:get_client_session_by_uid(msg.client_uid)
	if not client_session then
		return
	end
	
	if client_session:get_status() ~= ClientSession.SS_LOGIN_DOING then
		LOG_ERROR("HandleRepClientLogin: session status error")
		return
	end
		
	------------------------------------------------------------------------------------------------
    -- 注：排队机制先不做
    ------------------------------------------------------------------------------------------------

	if msg.login_result == LoginResult.E_LR_SUCCESS then
			
		client_session:set_account_idx(msg.account_idx)
		client_session:set_account_name(msg.account_name)
		
        -- 产生一个SessionKey, 并选取压力最小的cs, 然后把SessionKey, IP, port发送给客户端，让客户端去登录cs
        -- 客户端会自己断开socket, 服务器超时也会自动断开客户端
        
	else -- 其他情况
		
	end
end
	
function DSHandler.HandleRepCharacterList(peer, msg)

	client_session = global.client_session_mgr:get_client_session_by_uid(msg.client_uid);
	if not client_session then
		LOG_DEBUG("ReqCharacterListEnd: can't get session ptr")
		return
	end

	if client_session:get_status() ~= ClientSession.SS_LOGIN_OK then
		LOG_ERROR("ReqCharacterListEnd: session status error")
		return
	end

	rep_msg = {}
	rep_msg.last_login_pid = msg.last_login_pid
	rep_msg.char_data = msg.char_data

	client_session:SendToClient(s2c.S2CRepCharacterList, rep_msg)
end

function DSHandler.HandleRepCreateCharacter(peer, msg)
	
end

function DSHandler.HandleRepDeleteCharacter(peer, msg)
	
end

return DSHandler