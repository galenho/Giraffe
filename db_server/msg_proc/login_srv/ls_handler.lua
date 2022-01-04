local common = require "common"
local util = require "util"
local global = require "global"

WSHandler = {}

function WSHandler.ReqLoginDataEnd(is_success, rs, param)
    rep_msg = {}
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
				rep_msg.login_result = LoginResult.E_LR_SUCCESS; -- 成功
                rep_msg.account_idx = rs.account_idx;
			else
				rep_msg.login_result = LoginResult.E_LR_FAILED_INVALIDPASSWORD -- 密码错误
            end
		end
	end
	
    global.net_for_server:SendToWS(ds2ls.RepClientLogin, rep_msg)
end

function WSHandler.HandleReqClientLogin(peer, msg)
    param = {client_uid = msg.client_uid, account_name = msg.account_name, password = msg.password}
    global.gamedb:find_one("account_info", {account_name = msg.account_name}, {}, WSHandler.ReqLoginDataEnd, param)
end

-----------------------------------------------------------------
function WSHandler.ReqCharacterListEnd(is_success, rs, param)

	if is_success then
		rep_msg = {}
		rep_msg.client_uid = param.client_uid
		rep_msg.last_login_pid = 0
		rep_msg.char_data = {}

		for i = 1, #rs, 1 do
			rep_msg.char_data[i] = rs[i]
			if rs[i].last_update_time > rep_msg.last_login_pid then
				rep_msg.last_update_time = rs[i].last_update_time
				rep_msg.last_login_pid = rs[i].pid
			end
		end
		
		global.net_for_server:SendToWS(ds2ws.RepCharacterList, rep_msg)
	end
	
end

function WSHandler.HandleReqCharacterList(peer, msg)
	
	param = {client_uid = msg.client_uid, account_idx = msg.account_idx}
    global.gamedb:find("player", {account_idx = msg.account_idx}, 
							{_id = false, pid = true, name = true, type_idx = true, level = true, last_update_time = true}, 
							WSHandler.ReqCharacterListEnd, param)
							
end
-----------------------------------------------------------------
function WSHandler.ReqCreateCharacterEnd(is_success, rs, param, msg)
    
    if is_success then
		if rs.retval == 0 then --创建成功
			
		elseif rs.retval == 1 then --已达到最大的角色数量
			
		elseif rs.retval == 2 then --角色名重复
			
		else --未知错误
			print("is faile")
		end
	else		
		print("is faile")
	end
	
end

function WSHandler.HandleReqCreateCharacter(peer, msg)

	param = {client_uid = msg.client_uid, pid = msg.pid, account_idx = msg.account_idx, type_idx = msg.type_idx}
	
	max_char_count = 4
	create_time = os.time()
	cmd = "(" .. msg.pid .. ",'" .. msg.name .. "'," .. msg.account_idx .. "," .. msg.type_idx .. "," .. create_time .. ", " .. max_char_count .. ")"
	
	t = {eval = cmd}
	global.gamedb:create(t, WSHandler.ReqCreateCharacterEnd, param, global.server_res_mgr:get_bind_conn_idx())	
	
end
-----------------------------------------------------------------
function WSHandler.ReqDeleteCharacterEnd(peer, msg)
    
end

function WSHandler.HandleReqDeleteCharacter(peer, msg)
    
end

return WSHandler
