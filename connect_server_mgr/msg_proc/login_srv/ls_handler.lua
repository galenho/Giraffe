local common = require "common"
local util = require "util"
local global = require "global"

LSHandler = {}

function LSHandler.MakeSessionKey(account_idx)
    local session_key_map = global.session_key_map
    
    session_key = ""
    while true do
        session_key = ""
        for i=1, 16, 1 do
            val = math.random(10)
            session_key = session_key..val
        end
        
        if not session_key_map[session_key] then
            session_key_map[session_key] = account_idx
            return session_key
        end
    end 
end

function LSHandler.HandleReqCreateSession(peer, msg)
    --msg.client_uid
    --msg.account_idx
    local session_key_map = global.session_key_map
    
    rep_msg = {}
    rep_msg.client_uid = msg.client_uid
    rep_msg.account_idx = msg.account_idx
    rep_msg.session_key = LSHandler.MakeSessionKey(msg.account_idx)
    peer:Send(csm2ls.RepCreateSession, rep_msg)
end

return LSHandler