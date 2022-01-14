local luaxml = require "luaxml"
local protoc = require "protoc"
local serpent = require "serpent"
local util = require "util"
local global = require "global"
local List = require "list"

ServerResMgr = {}

function ServerResMgr:New(o)
    o = o or {} -- 如果用户没有提供则创建一个新的表
	self.__index = self
	setmetatable(o, self)

	-- 下面写成员变量
	o.serial_idx_ = 0
    o.req_table_cmds_ = List.new()
    return o
end

function ServerResMgr:LoadRes()
    LOG_INFO("LoadRes")
	
	---------------------------------------------------
	--(1) 读配置文件xml
	---------------------------------------------------
	xml_config = luaxml.load("world_server.xml")
	--dump(xml_config)
	
	success, log_level_emt = luaxml.find_node(xml_config, "log_level")
	global.config.log_level = tonumber(log_level_emt[1])
	
	success, realm_idx_emt = luaxml.find_node(xml_config, "realm_idx")
	global.config.realm_idx = tonumber(realm_idx_emt[1])
	
	success, ip_for_server_emt = luaxml.find_node(xml_config, "ip_for_server")
	global.config.ip_for_server = ip_for_server_emt[1]
	
	success, port_for_server_emt = luaxml.find_node(xml_config, "port_for_server")
	global.config.port_for_server = tonumber(port_for_server_emt[1])
	
	success, ds_ip_emt = luaxml.find_node(xml_config, "ds_ip")
	global.config.ds_ip = ds_ip_emt[1]
	
	success, ds_port_emt = luaxml.find_node(xml_config, "ds_port")
	global.config.ds_port = tonumber(ds_port_emt[1])
		
	success, log_ip_emt = luaxml.find_node(xml_config, "log_ip")
	global.config.log_ip = log_ip_emt[1]
	
	success, log_port_emt = luaxml.find_node(xml_config, "log_port")
	global.config.log_port = tonumber(log_port_emt[1])
	
	---------------------------------------------------
	--(2) 读配置表config
	---------------------------------------------------
	config_path = "../config"
	
	for file in lfs.dir(config_path) do
		if file ~= "." and file ~= ".." and util.getExtension(file) == "lua"  then
			print(file)
			require(util.getFileName(file))
		end
	end
	
	---------------------------------------------------
	--(4) 读地图map
	---------------------------------------------------
	
end

function ServerResMgr:PushTableData(table_name, field, is_batch, order_column, limit)
    if is_batch == nil then
        is_batch = false
    end
    
    cmd = {table_name=table_name, field=field, is_batch=is_batch, order_column = order_column, start=0, limit=limit}
    List.pushBack(self.req_table_cmds_, cmd)
end

function ServerResMgr:StartQueryTableData()
    if not List.isEmpty(self.req_table_cmds_) then
        cmd = List.front(self.req_table_cmds_)
        query = {}
        if cmd.is_batch then
            query[cmd.order_column] = {["$gt"] = cmd.start }
        end
        
        data = {table_name=cmd.table_name, query=query, field=cmd.field, is_batch=cmd.is_batch, order_column=order_column, limit=cmd.limit}
        global.world_server:SendToDS(internal.ReqServerRes, data)
    else
        --读完对象表了
        self:LoadDBDataEnd()
    end
end

function ServerResMgr:OnTableDataCallBack(table_name, rs)
    cmd = List.front(self.req_table_cmds_)
    local row_count = #rs
    if cmd.is_batch then
        LOG_INFO("table_name = ".. table_name .. ", row_count = " .. row_count .. ", start = " .. cmd.start + 1)
    else
        LOG_INFO("table_name = ".. table_name .. ", row_count = " .. row_count)
    end
    
    if row_count == 0 then --移除这个对象表
        List.popFront(self.req_table_cmds_)
    else
        if cmd.is_batch then --批次读表
            local maxKey = self:OnTableDataRead(table_name, rs)
            cmd.start = maxKey
        else --不是批次读表
            List.popFront(self.req_table_cmds_)
        end
    end   

    self:StartQueryTableData()
end

function ServerResMgr:OnPlayerTableCallBack(rs)
    local maxKey = 0
    for k,v in ipairs(rs) do
        maxKey = v.pid
    end
    
    return maxKey
end

function ServerResMgr:OnTableDataRead(table_name, rs)
    local maxKey = 0
    if table_name == "player" then
        maxKey = self:OnPlayerTableCallBack(rs)
    end
    
    return maxKey
end

function ServerResMgr:LoadDBData()

    self:PushTableData("player", {}, true, "pid", 1000)
    
    self:StartQueryTableData()
    
end

function ServerResMgr:LoadDBDataEnd()
    LOG_INFO("LoadDBDataEnd finish")
    
    global.net_for_server:Start()
end

function ServerResMgr:set_serial_idx(serial_idx)
	self.serial_idx_ = serial_idx
end

function ServerResMgr:get_serial_idx()
	return self.serial_idx_
end

return ServerResMgr