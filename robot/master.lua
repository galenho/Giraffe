local global = require "global"
local ServerResMgr = require "server_res_mgr"
local ClientManager = require "client_manager"

local protoc = require "protoc"
local serpent = require "serpent"

local hotfix = require("hotfix")


Master = {}

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
	----------------------------------------------
	-- 这里写相关的逻辑，直到判定可以退出
	global.client_manager:Stop()
	
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
	end
end

function Master.GameLoop(timer_id)
    
end

function Master:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	o.a = 5
	
    return o
end

function Master:Run()
	crossover.set_console_handler(Master.fun_console_callback)

	global.server_res_mgr = ServerResMgr:New()
	global.server_res_mgr:LoadRes()
	
	global.tcp_client = tcpclient.new()

	global.client_manager = ClientManager:New()
	global.client_manager:Start()
		
	LOG_INFO("Init(): robot started")
	crossover.save_log()
end

function Master:StartGameLoop()
    crossover.add_timer(200, Master.GameLoop)
end

function Master:Stop()
	crossover.stop(Master.fun_stop_callback)
end

return Master