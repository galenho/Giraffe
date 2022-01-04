local common = require "common"
local util = require "util"
local global = require "global"

CSHandler = {}

function CSHandler.HandleReqCharacterData(peer, msg)
	global.memcache_mgr:RequestCharacterInfo(msg.pid, msg.account_idx, peer.srv_info_.srv_uid, msg.client_uid)
end

return CSHandler
