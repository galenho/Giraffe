local common = require "common"
local util = require "util"
local global = require "global"

ClientHandler = {}

function ClientHandler.HandleRepClientLogin(session, msg)
    print("HandleRepClientLogin")
	if session:get_status() ~= ClientSession.SS_LOGIN_DOING then
		return
	end
	
    if msg.login_result == LoginResult.E_LR_SUCCESS then
        session:set_account_idx(msg.account_idx)
		session:set_status(ClientSession.SS_LOGIN_OK)
		
		-- 请求角色列表
		session:SendMsg(c2s.C2SReqCharacterList, {})
	else
		
	end
end

function ClientHandler.HandleRepCharacterList(session, msg)
    print("HandleRepCharacterList")
	if session:get_status() ~= ClientSession.SS_LOGIN_OK then
		return
	end
	
	if (not msg.char_data) or (table_len(msg.char_data) == 0) then
		-- 创建一个角色
		req_msg = {}
		req_msg.name = "player_" .. session:get_account_idx()
		req_msg.type_idx = 1
		
		session:SendMsg(c2s.C2SReqCreateCharacter, req_msg)
	else
		-- 进入游戏
        print("realy enter game ---- "..msg.char_data[1].pid)
        
        session:set_status(ClientSession.SS_REQUEST_CHARINFO)
        session:Disconnect()
        
		--req_msg = {}
		--req_msg.pid = msg.char_data[1].pid
		--session:SendMsg(c2s.C2SReqEnterGame, req_msg)
        
        
	end
end

function ClientHandler.HandleRepCreateCharacter(session, msg)
	print("HandleRepCreateCharacter ")
	if session:get_status() ~= ClientSession.SS_LOGIN_OK then
		return
	end
	
	if msg.result == CreateCharacterResult.E_CCR_SUCCESS then
        -- 进入游戏
        print("realy enter game ---- "..msg.char_data.pid)
	else
		
	end
end

return ClientHandler