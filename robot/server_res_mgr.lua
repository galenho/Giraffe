local luaxml = require "luaxml"
local protoc = require "protoc"
local serpent = require "serpent"
local util = require "util"
local global = require "global"

ServerResMgr = {}

function ServerResMgr:New(o)
    o = o or {} -- ����û�û���ṩ�򴴽�һ���µı�
	self.__index = self
	setmetatable(o, self)

	-- ����д��Ա����
	o.a = 5
	
    return o
end

function ServerResMgr:LoadRes()

	---------------------------------------------------
	--(1) �������ļ�xml
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
	--(2) ����ϢЭ��proto
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
	--(3) �����ñ�config
	---------------------------------------------------
	config_path = "../config"
	
	for file in lfs.dir(config_path) do
		if file ~= "." and file ~= ".." and util.getExtension(file) == "lua"  then
			--print(file)
			require(util.getFileName(file))
		end
	end
	
	---------------------------------------------------
	--(4) ����ͼmap
	---------------------------------------------------
	
	LOG_INFO("LoadRes")
end

return ServerResMgr