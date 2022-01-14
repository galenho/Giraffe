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

return CSHandler