local luaxml = require "luaxml"
local protoc = require "protoc"
local serpent = require "serpent"
local util = require "util"
local global = require "global"

ServerResMgr = {}

function ServerResMgr.HandleReqGetSerialIDEnd(is_success, rs, param)
    
	if is_success then
		if rs.value then
			serial_idx = FormatNum(global.config.realm_idx * 10000000 + rs.value) -- 5 + 7 = 12位十进制
			
			peer = global.net_for_server:get_peer_by_uid(param.srv_uid)
			if peer then
				peer:Send(internal.RepServerSerial, {serial_idx = serial_idx})
			else
				LOG_ERROR("peer is not find")
			end
		
		else
			LOG_ERROR("serial_idx is not find ")
		end
	else
		LOG_ERROR("serial_idx is not find")
	end
    
end 

function ServerResMgr.HandleReqServerResEnd(is_success, rs, param)
 
    if is_success then
		peer = global.net_for_server:get_peer_by_uid(param.srv_uid)
        if peer then
            peer:Send(internal.RepServerRes, {table_name = param.table_name, rs = rs})
        else
            LOG_ERROR("peer is not find")
        end
	else
		LOG_ERROR("table is not find")
	end
    
end 

function ServerResMgr:New(o)
    o = o or {} -- 如果用户没有提供则创建一个新的表
	self.__index = self
	setmetatable(o, self)

	-- 下面写成员变量
	o.bind_conn_idx_ = 0
	
    return o
end

function ServerResMgr:LoadRes()
    LOG_INFO("LoadRes")
	
	---------------------------------------------------
	--(1) 读配置文件xml
	---------------------------------------------------
	xml_config = luaxml.load("db_server.xml")
	--(xml_config)
	
	success, log_level_emt = luaxml.find_node(xml_config, "log_level")
	global.config.log_level = log_level_emt[1]
	
	success, realm_idx_emt = luaxml.find_node(xml_config, "realm_idx")
	global.config.realm_idx = realm_idx_emt[1]
	
	success, area_idx_emt = luaxml.find_node(xml_config, "area_idx")
	global.config.area_idx = area_idx_emt[1]
	
	success, ip_for_server_emt = luaxml.find_node(xml_config, "ip_for_server")
	global.config.ip_for_server = ip_for_server_emt[1]
	
	success, port_for_server_emt = luaxml.find_node(xml_config, "port_for_server")
	global.config.port_for_server = tonumber(port_for_server_emt[1])
		
	success, gamedb_emt = luaxml.find_node(xml_config, "gamedb")
	global.config.gamedb = {}
	global.config.gamedb.hostname = gamedb_emt.hostname
	global.config.gamedb.port = tonumber(gamedb_emt.port)
	global.config.gamedb.username = gamedb_emt.username
	global.config.gamedb.password = gamedb_emt.password
	global.config.gamedb.database = gamedb_emt.database
	global.config.gamedb.conn_count = tonumber(gamedb_emt.conn_count)
	--(global.config.gamedb)
	
	---------------------------------------------------
	--(2) 读配置表config
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

function ServerResMgr:HandleReqGetSerialID(srv_type, srv_uid)
	global.gamedb:find_and_modify("public_data", {name="serial_idx"}, {["$inc"] = {value = 1}}, ServerResMgr.HandleReqGetSerialIDEnd, {srv_type=srv_type, srv_uid=srv_uid}, self.bind_conn_idx_)
end

function ServerResMgr:HandleReqServerRes(table_name, query, field, is_batch, limit, srv_uid)
    if is_batch then --批次查询
        global.gamedb:find(table_name, query, field, ServerResMgr.HandleReqServerResEnd, {table_name = table_name, srv_uid = srv_uid}, INVALID_INDEX, limit)
    else --整表查询
        global.gamedb:find(table_name, query, field, ServerResMgr.HandleReqServerResEnd, {table_name = table_name, srv_uid = srv_uid}, INVALID_INDEX)
    end
end

function ServerResMgr:get_bind_conn_idx()
	return self.bind_conn_idx_
end

return ServerResMgr

