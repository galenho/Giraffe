local common = require "common"
local util = require "util"
local global = require "global"

ClientHandler = {}

function ClientHandler.HandleReqClientLogin(conn_idx, msg)
    req_msg = {}
	req_msg.client_uid = client_session:get_client_uid()
	req_msg.account_name = msg.account_name
	req_msg.password = msg.password
    req_msg.platform_idx = PlatformType.E_PT_INTERNAL
    global.login_server:SendToDS(ls2ds.ReqClientLogin, req_msg)
end

function ClientHandler.HandleReqCharacterList(conn_idx, msg)
   
end

function ClientHandler.HandleReqCreateCharacter(conn_idx, msg)
   
end

function ClientHandler.HandleReqDeleteCharacter(conn_idx, msg)
   
end

return ClientHandler