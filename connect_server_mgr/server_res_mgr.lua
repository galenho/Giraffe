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
    LOG_INFO("LoadRes")
	
	---------------------------------------------------
	--(1) 读配置文件xml
	---------------------------------------------------
	xml_config = luaxml.load("connect_server_mgr.xml")
	--dump(xml_config)
	
	success, log_level_emt = luaxml.find_node(xml_config, "log_level")
	global.config.log_level = log_level_emt[1]
	
	success, realm_idx_emt = luaxml.find_node(xml_config, "realm_idx")
	global.config.realm_idx = realm_idx_emt[1]
	
	success, ip_for_server_emt = luaxml.find_node(xml_config, "ip_for_server")
	global.config.ip_for_server = ip_for_server_emt[1]
	
	success, port_for_server_emt = luaxml.find_node(xml_config, "port_for_server")
	global.config.port_for_server = tonumber(port_for_server_emt[1])
	
	success, ws_ip_emt = luaxml.find_node(xml_config, "ws_ip")
	global.config.ws_ip = ws_ip_emt[1]
	
	success, ws_port_emt = luaxml.find_node(xml_config, "ws_port")
	global.config.ws_port = tonumber(ws_port_emt[1])
	
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
	
end

return ServerResMgr