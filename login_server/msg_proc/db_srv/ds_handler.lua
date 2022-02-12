local common = require "common"
local util = require "util"
local global = require "global"

DSHandler = {}

function DSHandler.HandleRepClientLogin(peer, msg)
    
	local client_session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
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
        client_session:set_ping_time(os.time())
        
        -- 产生一个SessionKey, 并选取压力最小的cs, 然后把SessionKey, IP, port发送给客户端，让客户端去登录cs
        -- 客户端会自己断开socket, 服务器超时也会自动断开客户端
        req_msg = {}
        req_msg.client_uid = msg.client_uid
        req_msg.account_idx = msg.account_idx
        global.login_server:SendToCSM(ls2csm.ReqCreateSession, req_msg)
    
	else -- 其他情况
        rep_msg = {}
        rep_msg.login_result = msg.login_result
        
        client_session:set_status(ClientSession.SS_CREATED) --恢复为ClientSession.SS_CREATED状态，可以继续登录
		client_session:SendMsg(s2c.S2CRepClientLogin, rep_msg)
	end
end
	
function DSHandler.HandleRepCharacterList(peer, msg)
    
	local client_session = global.client_session_mgr:get_session_by_uid(msg.client_uid);
	if not client_session then
		LOG_DEBUG("ReqCharacterListEnd: can't get session ptr")
		return
	end

	if client_session:get_status() ~= ClientSession.SS_LOGIN_OK then
		LOG_ERROR("ReqCharacterListEnd: session status error")
		return
	end

	local rep_msg = {}
    rep_msg.char_data = {}
    cursor = 1
    for k,v in pairs(msg.char_data) do
        rep_msg.char_data[cursor] = v
        cursor = cursor + 1
    end

	client_session:SendMsg(s2c.S2CRepCharacterList, rep_msg)
end

function DSHandler.HandleRepCreateCharacter(peer, msg)
    local rep_msg = {}
    rep_msg.result = msg.result
    if msg.result == CreateCharacterResult.E_CCR_SUCCESS then
        rep_msg.char_data = {}
        rep_msg.char_data.pid = msg.pid
        rep_msg.char_data.name = msg.name
        rep_msg.char_data.type_idx = msg.type_idx
        rep_msg.char_data.level = msg.level
        rep_msg.char_data.last_update_time = msg.last_update_time
    end
    
    client_session:SendMsg(s2c.S2CRepCreateCharacter, rep_msg)
end


return DSHandler