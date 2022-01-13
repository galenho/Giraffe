local protoc 	= require "protoc"
local serpent 	= require "serpent"
local hotfix 	= require "hotfix"
local common	= require "common"
local util 	    = require "util"
local global 	= require "global"

local ServerResMgr = require "server_res_mgr"
local NetForServer = require "network.net_for_server"
local MemcacheMgr = require "memcache.memcache_mgr"

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
	global.net_for_server:Stop()
	global.gamedb:shutdown()
	
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
	elseif cmd == "insert account" then
		Master.TestInsertAccount()
    else
        
    end
end

function Master.InsertAccountCallBack(is_success, rs, param)
	if is_success then
		print("account_idx = " .. param.account)
	end
end

function Master.TestInsertAccount()
	for i = 1, 10000, 1 do
		global.gamedb:insert_one("account_info", {account_idx=i, account_name="test"..i, password="1"}, Master.InsertAccountCallBack, {account=i})
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
	
    -- 读取资源
	global.server_res_mgr = ServerResMgr:New()
	global.server_res_mgr:LoadRes()
    
    -- 连接数据库
	global.gamedb = mongo.new()
	str_conn = "mongodb://" .. global.config.gamedb.username .. ":" .. global.config.gamedb.password 
									.. "@" .. global.config.gamedb.hostname .. ":" .. global.config.gamedb.port .. "/?authSource=admin"
	
	LOG_INFO(str_conn)
	global.gamedb:initialize(str_conn, global.config.gamedb.database, global.config.gamedb.conn_count)
    
	-- 读取数据库表
    global.server_res_mgr:LoadDBData()

	-- 缓存管理器
	global.memcache_mgr = MemcacheMgr:New()
	
	-- 初始化网络
	global.net_for_server = NetForServer:New()
	global.net_for_server:Init()
	
	LOG_INFO("Init(): dbserver started")

	crossover.save_log()
end

function Master:Stop()
	crossover.stop(Master.fun_stop_callback)
end

function Master:is_stopping()
	return stopping_
end

return Master