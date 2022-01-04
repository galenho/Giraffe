Master = {}

local global = require "global"
local util = require "util"

local ServerResMgr = require "server_res_mgr"
local NetForClient = require "network.net_for_client"
local LoginServer = require "network.login_server"
local ClientSessionMgr = require "client_session.client_session_mgr"

local protoc = require "protoc"
local serpent = require "serpent"

local hotfix = require("hotfix")

function Master.HotUpdateCode()
	file = io.open("hot_update_code.list", "r")
	io.input(file)
	
	while true do
		local line = io.read()
		if line == nil then
			break
		else
			print("reload " .. line)
			hotfix.hotfix_module(line)
		end
	end
	
	io.close(file)
end

function Master.HotUpdateTable()
	file = io.open("hot_update_table.list", "r")
	io.input(file)
	
	while true do
		local line = io.read()
		if line == nil then
			break
		else
			print("reload " .. line)
			hotfix.hotfix_table(line)
		end
	end
	
	io.close(file)
end

function Master.fun_stop_callback(timer_id)
	LOG_INFO("waitting for stop...")
	------------------------------------------------------------------------
	-- 一次50个ClientSession慢慢退, 以防止缓冲区溢出
	------------------------------------------------------------------------
	global.client_session_mgr:TryContinueCloseOtherClient()
	
	------------------------------------------------------------------------
	-- 需要延迟等待退出的ClientSession全部退出
	------------------------------------------------------------------------
	session_count = global.client_session_mgr:get_session_count()
	if session_count > 0 then
		LOG_INFO("waiting for all client session (" .. session_count .. ") logout.")
		return
	end
	
	------------------------------------------------------------------------
	-- 断开网络
	------------------------------------------------------------------------
	global.net_for_client:Stop()
	global.login_server:Stop()
	
	----------------------------------------------
	crossover.remove_timer(timer_id)
	crossover.exit()
end

function Master.fun_console_callback(cmd)
	if cmd == "exit" then
		global.master:Stop()
	elseif cmd == "r" then
		Master.HotUpdateCode()
		Master.HotUpdateTable()
	elseif cmd == "show server" then
		global.login_server:ShowServer()
	end
end

function Master:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	o.stopping_ = false
	
    return o
end

function Master:Run()
	crossover.set_console_handler(Master.fun_console_callback)
	
	global.server_res_mgr = ServerResMgr:New()
	global.server_res_mgr:LoadRes()
	
	global.login_server = LoginServer:New()
	global.login_server:Init()
	global.login_server:Start()
	
	global.net_for_client = NetForClient:New()
	global.net_for_client:Init()
	
	global.client_session_mgr = ClientSessionMgr:New()
	
	LOG_INFO("Init(): connectserver started")
	crossover.save_log()
end

function Master:Stop()
	-- 禁止客户端连接
	global.net_for_client:switch_client_connect(false)

	-- 断开所有客户端连接
	global.client_session_mgr:CloseAllClient()
	
	crossover.stop(Master.fun_stop_callback)
end

function Master:is_stopping()
	return stopping_
end

return Master