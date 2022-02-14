local common = require "common"
local util = require "util"
local global = require "global"

CSHandler = {}

function CSHandler.HandleNotifyCsInfo(peer, msg)
    local conn_srv_area = global.conn_srv_area_map[msg.area_idx]
    if conn_srv_area then
        conn_srv_area.ip = msg.ip
        conn_srv_area.port = msg.port
        conn_srv_area.player_amount = msg.player_amount
    else
        conn_srv_area = {ip = msg.ip, port = msg.port, player_amount = msg.player_amount, area_idx = msg.area_idx}
        global.conn_srv_area_map[msg.area_idx] = conn_srv_area
    end
end

function CSHandler.HandleReqEnterGame(peer, msg)
    
    local session_key_map = global.session_key_map
    
    local rep_msg = {}
    rep_msg.client_uid = msg.client_uid
    rep_msg.pid = msg.pid
    rep_msg.account_idx = msg.account_idx
    
    if session_key_map[msg.session_key] then
        if session_key_map[msg.session_key] == msg.account_idx then
            rep_msg.result = 1
            session_key_map[msg.session_key] = nil --验证成功后就移除session_key
        else
            rep_msg.result = 0
        end
    else
        rep_msg.result = 0
    end

    peer:Send(csm2cs.RepEnterGame, rep_msg)
end

return CSHandler