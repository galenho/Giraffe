local common = require "common"
local util = require "util"
local global = require "global"

ClientHandler = {}

function ClientHandler.HandleRepClientLogin(session, msg)
	print("HandleRepClientLogin " .. msg.login_result)
	
	if session:get_status() ~= ClientSession.SS_LOGIN_DOING then
		return
	end
	
    if msg.login_result == LoginResult.E_LR_SUCCESS then
		session:set_status(ClientSession.SS_LOGIN_OK)
		
		-- 请求角色列表
		session:SendMsg(c2s.C2SReqCharacterList, {})
	else
		
	end
end

function ClientHandler.HandleRepCharacterList(session, msg)
	print("HandleRepCharacterList ")
	
	if session:get_status() ~= ClientSession.SS_LOGIN_OK then
		return
	end
	
	if (not msg.char_data) or (#msg.char_data == 0) then
		-- 创建一个角色
		req_msg = {}
		req_msg.name = "player_" .. session:get_account_idx()
		req_msg.type_idx = 1
		
		session:SendMsg(c2s.C2SReqCreateCharacter, req_msg)

	else
		-- 进入游戏
		req_msg = {}
		req_msg.pid = msg.char_data[1].pid
		session:SendMsg(c2s.C2SReqEnterGame, req_msg)
	end
end

return ClientHandler