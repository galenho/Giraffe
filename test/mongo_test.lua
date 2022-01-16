package.path = package.path..";../common/?.lua"
package.cpath = package.cpath..";../?.dll"

require("common")
local util = require("util")

db = mongo.new()

g_rs = {}
fun_callback = function(is_success, rs)
	if is_success then
		--dump(rs)
		param = {client_uid = 3258173598713, account_name = "test1", password = "1"}
		db:find_one("account_info", {account_name = param.account_name}, {}, fun_callback)
	end
end

fun_callback_param = function(is_success, rs, param)
    if is_success then
		--dump(rs)
		param = {client_uid = 3258173598713, account_name = "test1", password = "1"}
		db:find_one("account_info", {account_name = param.account_name}, {}, fun_callback_param, param)
	end
end

function TestQuery()
	ret = db:initialize("mongodb://root:88104725galenho@127.0.0.1:27017/?authSource=admin", "gamedb", 1)
	--db:initialize("mongodb://root:YXTxsaj22WSJ7wTG@192.168.44.138:27017/?authSource=admin", "game", 1)
	--db:ping()
	--db:drop("player", fun_callback)
	
	--db:drop_index("player", "*", fun_callback)
	
	--db:create_index("player", {obj_idx=1}, fun_callback)
	--db:drop_index("player", "obj_idx_1", fun_callback)
	
	
	--db:insert_one("player", {obj_idx=1, name="galen", hp=100}, fun_callback)
	--db:insert_many("player", {{obj_idx=2, name="chen", hp=100}, {obj_idx=3, name="flashboy", hp=100}}, fun_callback)
	--db:insert_many("player", {{obj_idx=4, name="chen", hp=100}, {obj_idx=5, name="flashboy", hp=100}}, fun_callback)
	--db:insert_many("player", {{obj_idx=4, name="chen", hp=100}, {obj_idx=5, name="flashboy", hp=100}}, fun_callback)
	
	--db:delete_one("player", {obj_idx=1}, fun_callback)
	--db:delete_many("player", {{obj_idx=4}, {obj_idx=5}}, fun_callback)
		
	--db:find("player", {}, {}, fun_callback)
	--db:find("player", {obj_idx=1}, {obj_idx=true, name=true}, fun_callback)
	--db:find("player", {obj_idx=2}, {}, fun_callback_param, {a=1, b=2}, 1)
	
	--db:find_one("player", {pid=10002}, {}, fun_callback)
	
	--db:update_one("player", {pid=10002}, {["$set"] = {hp22 = 388}}, fun_callback)
	
	--db:find_one("player", {pid=10002}, {hp22 = true}, fun_callback)
    --db:insert_one("player", {pid=10000000000033332}, fun_callback)
	--db:find("player", {}, {pid = true}, fun_callback)
	
	
	--db:update_many("player", {hp = 100}, {["$set"] = {name = "kof"}}, fun_callback)
	--db:find("player", {obj_idx=1}, {}, fun_callback)
	param = {client_uid = 3258173598713, account_name = "test1", password = "1"}
	for i=1, 1000000, 1 do
		db:find_one("account_info", {account_name = param.account_name}, {}, fun_callback)
	end
	
end

TestQuery()


