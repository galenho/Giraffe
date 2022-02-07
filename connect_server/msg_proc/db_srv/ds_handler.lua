local common = require "common"
local util = require "util"
local global = require "global"

DSHandler = {}

function DSHandler.HandleRepCharacterData(peer, msg)

	session = global.client_session_mgr:get_session_by_uid(msg.client_uid)
    if not session then
        return
    end
	
	if session:get_status() ~= ClientSession.SS_REQUEST_CHARINFO then
        return
    end
	
	rep_msg = {}
    rep_msg.result = msg.result
    rep_msg.pid = msg.pid
    session:SendMsg(s2c.S2CRepEnterGame, rep_msg)
end

return DSHandler