local luaxml = require "luaxml"
local protoc = require "protoc"
local serpent = require "serpent"
local util = require "util"
local global = require "global"

ServerResMgr = {}

function ServerResMgr:New(o)
    o = o or {} -- 如果用户没有提供则创建一个新的表
	self.__index = self
	setmetatable(o, self)

	-- 下面写成员变量
	o.a = 5
	
    return o
end

function ServerResMgr:LoadRes()

	---------------------------------------------------
	--(1) 读配置文件xml
	---------------------------------------------------
	xml_config = luaxml.load("robot.xml")
	--dump(xml_config)
	
	success, log_level_emt = luaxml.find_node(xml_config, "log_level")
	global.config.log_level = tonumber(log_level_emt[1])
	
	success, ip_emt = luaxml.find_node(xml_config, "ip")
	global.config.ip = ip_emt[1]
	
	success, port_emt = luaxml.find_node(xml_config, "port")
	global.config.port = tonumber(port_emt[1])
	
	success, cases_emt = luaxml.find_node(xml_config, "cases")
	global.config.cases = cases_emt
	
	---------------------------------------------------
	--(2) 读消息协议proto
	---------------------------------------------------
	common_path = "../proto/common"
	client_path = "../proto/client"
	server_path = "../proto/server"
	
	global.proto = protoc.new()
	global.proto:addpath(common_path)

	for file in lfs.dir(client_path) do
		if file ~= "." and file ~= ".." and util.getExtension(file) == "proto" then
			full_name = client_path .. "/" .. file
			global.proto:loadfile(full_name)
		end
	end
	
	for file in lfs.dir(server_path) do
	 	if file ~= "." and file ~= ".." and util.getExtension(file) == "proto" then
	 		full_name = server_path .. "/" .. file
	 		global.proto:loadfile(full_name)
	 	end
	end
	
	---------------------------------------------------
	--(3) 读配置表config
	---------------------------------------------------
	config_path = "../config"
	
	for file in lfs.dir(config_path) do
		if file ~= "." and file ~= ".." and util.getExtension(file) == "lua"  then
			--print(file)
			require(util.getFileName(file))
		end
	end
	
	---------------------------------------------------
	--(4) 读地图map
	---------------------------------------------------
	
	LOG_INFO("LoadRes")
end

return ServerResMgr