local luaxml = require "luaxml"
local protoc = require "protoc"
local serpent = require "serpent"
local util = require "util"
local global = require "global"
local List = require "list"

ServerResMgr = {}

function ServerResMgr:New(o)
    o = o or {} -- ����û�û���ṩ�򴴽�һ���µı�
	self.__index = self
	setmetatable(o, self)

	-- ����д��Ա����
	o.serial_idx_ = 0
	o.req_table_cmds_ = List.new()
    
    return o
end

function ServerResMgr:LoadRes()
    LOG_INFO("LoadRes")
	
	---------------------------------------------------
	--(1) �������ļ�xml
	---------------------------------------------------
	xml_config = luaxml.load("login_server.xml")
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
        global.login_server:SendToDS(internal.ReqServerRes, data)
    else
        --����������
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
    
    if row_count == 0 then --�Ƴ���������
        List.popFront(self.req_table_cmds_)
    else
        if cmd.is_batch then --���ζ���
            local maxKey = self:OnTableDataRead(table_name, rs)
            cmd.start = maxKey
        else --�������ζ���
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
    
    global.net_for_client:Start()
end

function ServerResMgr:set_serial_idx(serial_idx)
	self.serial_idx_ = serial_idx
end

function ServerResMgr:get_serial_idx()
	return self.serial_idx_
end

return ServerResMgr