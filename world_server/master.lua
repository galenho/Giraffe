Master = {}

local protoc = require "protoc"
local serpent = require "serpent"
local hotfix = require "hotfix"
local netdefines = require "netdefines"

local global = require "global"

local ClientSessionMgr = require "client_session.client_session_mgr"
local ServerResMgr = require "server_res_mgr"
local ServerRunInfo = require "server_run_info"
local NetForServer = require "network.net_for_server"
local WorldServer = require "network.world_server"

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
	----------------------------------------------
	-- 这里写相关的逻辑，直到判定可以退出
	global.net_for_server:Stop()
	
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
		global.net_for_server:ShowServer()
		LOG_INFO("-------------------------------------------------------------------------------------------")
		global.world_server:ShowServer()
	end
end

function Master:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.stopping_ = false
	
    return o
end

function Master:Run()

	crossover.set_console_handler(Master.fun_console_callback)

	global.server_res_mgr = ServerResMgr:New()
	global.server_res_mgr:LoadRes()
	
	global.net_for_server = NetForServer:New()
	global.net_for_server:Init()
	
	global.world_server = WorldServer:New()
	global.world_server:Init()
	global.world_server:Start()
	
	global.client_session_mgr = ClientSessionMgr:New()
    
    global.server_run_info = ServerRunInfo:New()
    
	LOG_INFO("Init(): worldserver started")
    
	crossover.save_log()
	
end

function Master:Stop()
	
	global.net_for_server:BroadcastMsg(internal.AppServerShutdown, {})
	global.world_server:BroadcastMsg(internal.AppServerShutdown, {})
	
	crossover.stop(Master.fun_stop_callback)
end

function Master:is_stopping()
	return stopping_
end

return Master