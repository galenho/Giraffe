local common = require "common"
local util = require "util"
local global = require "global"

LSHandler = {}

function LSHandler.ReqLoginDataEnd(is_success, rs, param)
    local rep_msg = {}
    rep_msg.client_uid = param.client_uid
    rep_msg.account_name = param.account_name

    if not is_success then
		rep_msg.login_result = LoginResult.E_LR_FAILED_SERVERINTERNALERROR
	else
		if not rs.account_idx then
			-- 账号不存在
			rep_msg.login_result = LoginResult.E_LR_FAILED_INVALIDACCOUNT
		else -- 有记录, 验证密码是否正确
			if param.password == rs.password then
				rep_msg.login_result = LoginResult.E_LR_SUCCESS -- 成功
                rep_msg.account_idx = rs.account_idx
			else
				rep_msg.login_result = LoginResult.E_LR_FAILED_INVALIDPASSWORD -- 密码错误
            end
		end
	end
	
    global.net_for_server:SendToLS(ds2ls.RepClientLogin, rep_msg)
end

function LSHandler.HandleReqClientLogin(peer, msg)
    local param = {client_uid = msg.client_uid, account_name = msg.account_name, password = msg.password}
    global.gamedb:find_one("account_info", {account_name = msg.account_name}, {}, LSHandler.ReqLoginDataEnd, param)
end

-----------------------------------------------------------------
function LSHandler.HandleReqCharacterList(peer, msg)
	local account_player_map = global.server_res_mgr.account_player_map_

    local rep_msg = {}
	rep_msg.client_uid = msg.client_uid
    rep_msg.char_data = {}

    if account_player_map[msg.account_idx] then
		for k,v in pairs(account_player_map[msg.account_idx]) do
            rep_msg.char_data[v.pid] = {}
            rep_msg.char_data[v.pid].pid = v.pid
            rep_msg.char_data[v.pid].name = v.name
            rep_msg.char_data[v.pid].type_idx = v.type_idx
            rep_msg.char_data[v.pid].level = v.level
            rep_msg.char_data[v.pid].last_update_time = v.last_update_time
		end
    end

    global.net_for_server:SendToLS(ds2ls.RepCharacterList, rep_msg)					
end
-----------------------------------------------------------------
function LSHandler.ReqCreateCharacterEnd(is_success, rs, param)
    if is_success then
		
	else		
		print("create character is faile")
	end
end

function LSHandler.HandleReqCreateCharacter(peer, msg)
    --msg: client_uid, account_idx, name, type_idx
    local player_name_map = global.server_res_mgr.player_name_map_
    local account_player_count_map = global.server_res_mgr.account_player_map_
    
    local rep_msg = {}
	rep_msg.client_uid = msg.client_uid
    
	-- 1. 判断同名
    if player_name_map[msg.name] then
        rep_msg.result = CreateCharacterResult.E_CCR_FAILED_INVALIDPARAM_REPEATED_NAME
        global.net_for_server:SendToLS(ds2ls.RepCreateCharacter, rep_msg)
        return
    end
    
    -- 2. 判断角色数量
    local max_char_count = 4
    local account_player_map = account_player_count_map[msg.account_idx]
    if account_player_map then
        if table_len(account_player_map) >= max_char_count then
            rep_msg.result = CreateCharacterResult.E_CCR_FAILED_CHARCOUNTLIMIT
            global.net_for_server:SendToLS(ds2ls.RepCreateCharacter, rep_msg)
            return
        end  
    end
    
    -- 3. 创建角色
    local player_data = {pid=msg.pid, name=msg.name, account_idx=msg.account_idx, type_idx=msg.type_idx, level=1, last_update_time = os.time()}
    player_name_map[msg.name] = msg.pid
    if not player_name_map[msg.account_idx] then
        player_name_map[msg.account_idx] = {}
    end

    player_name_map[msg.account_idx][msg.pid] = player_data    
    global.gamedb:insert_one("player", player_data, LSHandler.ReqCreateCharacterEnd, {})
	
    rep_msg.pid = player_data.pid
    rep_msg.name = player_data.name
    rep_msg.account_idx = player_data.account_idx
    rep_msg.type_idx = player_data.type_idx
    rep_msg.level = player_data.level
    rep_msg.last_update_time = player_data.last_update_time
    rep_msg.result = CreateCharacterResult.E_CCR_SUCCESS
    global.net_for_server:SendToLS(ds2ls.RepCreateCharacter, rep_msg)
end

return LSHandler
