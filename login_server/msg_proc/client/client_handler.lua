local common = require "common"
local util = require "util"
local global = require "global"

ClientHandler = {}

function ClientHandler.HandleReqClientLogin(conn_idx, msg)
    
    session = global.client_session_mgr:get_session_by_conn_idx(conn_idx)
    if not session then
        session = global.client_session_mgr:AddSession(conn_idx)
    end
    
    if session:get_status() ~= ClientSession.SS_CREATED then
        return
    end
    
    req_msg = {}
	req_msg.client_uid = session:get_client_uid()
	req_msg.account_name = msg.account_name
	req_msg.password = msg.password
    req_msg.platform_idx = PlatformType.E_PT_INTERNAL
	req_msg.account_idx = msg.account_idx
    global.login_server:SendToDS(ls2ds.ReqClientLogin, req_msg)
    
    session:set_status(ClientSession.SS_LOGIN_DOING)
    
    global.client_session_mgr:CleanupAcceptSession(conn_idx)  --有登录过就算是合法(防止只连接不登录)，从accpet列表中移除掉这个conn_idx
    
end

function ClientHandler.HandleReqCharacterList(session, msg)

    if session:get_status() ~= ClientSession.SS_LOGIN_OK then
        return
    end
    
    req_msg = {}
	req_msg.client_uid = session:get_client_uid()
	req_msg.account_idx = session:get_account_idx()
    global.login_server:SendToDS(ls2ds.ReqCharacterList, req_msg)
    
end

function ClientHandler.HandleReqCreateCharacter(session, msg)
    
    if session:get_status() ~= ClientSession.SS_LOGIN_OK then
        return
    end
    
    req_msg = {}
	req_msg.client_uid = session:get_client_uid()
	req_msg.account_idx = session:get_account_idx()
    req_msg.pid = global.server_res_mgr:MakeCharacterGeneralID()
    req_msg.name = msg.name
    req_msg.type_idx = msg.type_idx
    global.login_server:SendToDS(ls2ds.ReqCreateCharacter, req_msg)
end

function ClientHandler.HandleReqDeleteCharacter(conn_idx, msg)

    if session:get_status() ~= ClientSession.SS_LOGIN_OK then
        return
    end
    
    req_msg = {}
	req_msg.client_uid = session:get_client_uid()
	req_msg.pid = msg.pid
    global.login_server:SendToDS(ls2ds.ReqDeleteCharacter, req_msg)
end

return ClientHandler