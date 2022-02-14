local common = require "common"
local util = require "util"
local global = require "global"

ClientHandler = {}

function ClientHandler.HandleRepClientLogin(session, msg)
    print("HandleRepClientLogin ---- "..session.account_idx_)
	if session:get_status() ~= ClientSession.SS_LOGIN_DOING then
		return
	end
	
    if msg.login_result == LoginResult.E_LR_SUCCESS then
        session:set_account_idx(msg.account_idx)
		session:set_status(ClientSession.SS_LOGIN_OK)
		session.ip_for_cs_ = msg.ip
        session.port_for_cs_ = msg.port
        session.session_key_ = msg.session_key
        
		-- 请求角色列表
		session:SendMsg(c2s.C2SReqCharacterList, {})
	else
		print("Login Faile")
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
        print("Realy enter game ---- "..msg.char_data[1].pid)
        session.pid_ = msg.char_data[1].pid
        session:set_status(ClientSession.SS_INIT_CS_INFO)
        session:Disconnect()
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
        
        session:set_status(ClientSession.SS_INIT_CS_INFO)
        session:Disconnect()
	else
		
	end
end

function ClientHandler.HandleRepEnterGame(session, msg)
	print("HandleRepEnterGame ")
	if session:get_status() ~= ClientSession.SS_ENTER_GAMEING then
		return
	end
	
	if msg.result then
        -- 进入游戏
        print("enter game success ---- "..msg.pid)
        session:set_status(ClientSession.SS_INGAME)
		session:Disconnect()
	else
		
	end
end


return ClientHandler