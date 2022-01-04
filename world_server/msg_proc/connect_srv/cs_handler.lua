local common = require "common"
local util = require "util"
local global = require "global"

local ClientSession = require "client_session.client_session"

CSHandler = {}

function CSHandler.HandleProxyClientMsg(peer, msg)

	client_session = global.client_session_mgr:get_client_session_by_uid(msg.client_uid)
	if not client_session then
		return
	end

	cmd = msg.proxy_data.cmd
	
	if peer.client_handlers_[cmd] then
		peer.client_handlers_[cmd](client_session, msg.proxy_data)
	end
	
end


return CSHandler
