local common = require "common"
local util = require "util"
local global = require "global"

LSHandler = {}

function LSHandler.MakeSessionKey(account_idx)
    local session_key_map = global.session_key_map
    
    session_key = ""
    --[[while true do
        session_key = ""
        for i=1, 16, 1 do
            val = math.random(10)
            session_key = session_key..val
        end
        
        if not session_key_map[session_key] then
            session_key_map[session_key] = account_idx
            break
        end
    end--]]
    
    return session_key
end

function LSHandler.GetGoodCs()
    local conn_srv_area_map = global.conn_srv_area_map
    min_player_count = 999999999
    min_area_id = 0
    for k,v in ipairs(conn_srv_area_map) do
        if v.player_amount < min_player_count then
            min_player_count = v.player_amount
            min_area_id = k
        end
    end
    
    return conn_srv_area_map[min_area_id]
end

function LSHandler.HandleReqCreateSession(peer, msg)
    local session_key_map = global.session_key_map
    
    rep_msg = {}
    rep_msg.client_uid = msg.client_uid
    rep_msg.account_idx = msg.account_idx
    rep_msg.session_key = LSHandler.MakeSessionKey(msg.account_idx)
    good_cs = LSHandler.GetGoodCs()
    rep_msg.ip = good_cs.ip
    rep_msg.port = good_cs.port
    peer:Send(csm2ls.RepCreateSession, rep_msg)
end

return LSHandler