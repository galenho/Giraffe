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
	o.serial_idx_ = 0
	
    return o
end

function ServerResMgr:LoadRes()
    LOG_INFO("LoadRes")
	
	---------------------------------------------------
	--(1) 读配置文件xml
	---------------------------------------------------
	xml_config = luaxml.load("connect_server.xml")
	--dump(xml_config)
	
	success, log_level_emt = luaxml.find_node(xml_config, "log_level")
	global.config.log_level = log_level_emt[1]
	
	success, realm_idx_emt = luaxml.find_node(xml_config, "realm_idx")
	global.config.realm_idx = realm_idx_emt[1]
	
	success, area_idx_emt = luaxml.find_node(xml_config, "area_idx")
	global.config.area_idx = area_idx_emt[1]
	
	success, ip_for_client_emt = luaxml.find_node(xml_config, "ip_for_client")
	global.config.ip_for_client = ip_for_client_emt[1]
	
	success, port_for_client_emt = luaxml.find_node(xml_config, "port_for_client")
	global.config.port_for_client = tonumber(port_for_client_emt[1])
	
	success, ws_ip_emt = luaxml.find_node(xml_config, "ws_ip")
	global.config.ws_ip = ws_ip_emt[1]
	
	success, ws_port_emt = luaxml.find_node(xml_config, "ws_port")
	global.config.ws_port = tonumber(ws_port_emt[1])
	
	success, ds_ip_emt = luaxml.find_node(xml_config, "ds_ip")
	global.config.ds_ip = ds_ip_emt[1]
	
	success, ds_port_emt = luaxml.find_node(xml_config, "ds_port")
	global.config.ds_port = tonumber(ds_port_emt[1])
		
	success, log_ip_emt = luaxml.find_node(xml_config, "log_ip")
	global.config.log_ip = log_ip_emt[1]
	
	success, log_port_emt = luaxml.find_node(xml_config, "log_port")
	global.config.log_port = tonumber(log_port_emt[1])
	
	success, csm_ip_emt = luaxml.find_node(xml_config, "csm_ip")
	global.config.csm_ip = csm_ip_emt[1]
	
	success, csm_port_emt = luaxml.find_node(xml_config, "csm_port")
	global.config.csm_port = tonumber(csm_port_emt[1])
	
	success, map_servers_emt = luaxml.find_node(xml_config, "map_servers")
	global.config.map_servers = map_servers_emt[1]
	--dump(map_servers_emt[1])
	
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

function ServerResMgr:set_serial_idx(serial_idx)
	self.serial_idx_ = serial_idx
end

function ServerResMgr:get_serial_idx()
	return self.serial_idx_
end

return ServerResMgr