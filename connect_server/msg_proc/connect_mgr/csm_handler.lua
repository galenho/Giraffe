local common = require "common"
local util = require "util"
local global = require "global"

CSMHandler = {}

function CSMHandler.HandleRepEnterGame(peer, msg)
    
    session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
    if not session then
        return
    end
    
    if session:get_status() ~= ClientSession.SS_CSM_VERIFY then
        return
    end
    
    if msg.result then
        --需要到db_server读取玩家数据
		global.connect_server:SendToDS(cs2ds.ReqCharacterData, {client_uid = client_uid, pid = msg.pid})
    else
        --直接粗暴关闭连接
		global.net_for_client:DisconnectClient(session:get_conn_idx())
    end   

	session:set_status(ClientSession.SS_REQUEST_CHARINFO)

end

return CSMHandler