local common = require "common"
local util = require "util"
local global = require "global"

CSMHandler = {}

function CSMHandler.HandleRepEnterGame(peer, msg)
    
    local session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
    if not session then
        return
    end
    
    if session:get_status() ~= ClientSession.SS_CSM_VERIFY then
        return
    end
    
    if msg.result then
        --��Ҫ��db_server��ȡ�������
		global.connect_server:SendToDS(cs2ds.ReqCharacterData, {pid = msg.pid, account_idx = msg.account_idx, client_uid = msg.client_uid})
    else
        --ֱ�Ӵֱ��ر�����
		global.net_for_client:DisconnectClient(session:get_conn_idx())
    end   

	session:set_status(ClientSession.SS_REQUEST_CHARINFO)

end

return CSMHandler