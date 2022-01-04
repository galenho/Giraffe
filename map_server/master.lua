Master = {}

local global = require "global"
local ServerResMgr = require "server_res_mgr"
local NetForServer = require "network.net_for_server"
local MapServer = require "network.map_server"

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
	----------------------------------------------
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
		global.map_server:ShowServer()
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
	
	global.map_server = MapServer:New()
	global.map_server:Init()
	global.map_server:Start()
	
	global.net_for_server = NetForServer:New()
	global.net_for_server:Init()
	global.net_for_server:Start()

	LOG_INFO("Init(): mapserver started")
	crossover.save_log()

end

function Master:Stop()
	crossover.stop(Master.fun_stop_callback)
end

function Master:is_stopping()
	return stopping_
end

return Master