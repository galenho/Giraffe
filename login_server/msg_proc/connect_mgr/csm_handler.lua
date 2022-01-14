local common = require "common"
local util = require "util"
local global = require "global"

CSMHandler = {}

function CSMHandler.HandleRepCreateSession(peer, msg)
    session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
    if not session then
        return
    end
    
    if session:get_status() ~= ClientSession.SS_LOGIN_DOING then
        return
    end
    
    client_session:set_status(ClientSession.SS_LOGIN_OK) --设置为登录成功
    
    rep_msg = {}
    rep_msg.login_result = LoginResult.E_LR_SUCCESS
    rep_msg.account_idx = msg.account_idx
    rep_msg.ip = msg.ip
    rep_msg.port = msg.port    
    dump(rep_msg)
    session:SendMsg(s2c.S2CRepClientLogin, rep_msg)
end

return CSMHandler