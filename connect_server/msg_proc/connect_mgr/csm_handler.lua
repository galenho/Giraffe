local common = require "common"
local util = require "util"
local global = require "global"

CSMHandler = {}

function CSMHandler.HandleRepEnterGame(peer, msg)
    
    session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
    if not session then
        return
    end
    
    if session:get_status() ~= ClientSession.SS_REQUEST_CHARINFO then
        return
    end
    
    if msg.result then
        --需要到db_server读取玩家数据
        
    else
        --直接粗暴关闭连接
        
        
    end   

    rep_msg = {}
    rep_msg.result = msg.result
    rep_msg.pid = msg.pid
    session:SendMsg(s2c.S2CRepEnterGame, rep_msg)
end

return CSMHandler