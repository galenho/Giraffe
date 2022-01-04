package.path = package.path..";../common/lua-protobuf/?.lua"
package.cpath = package.cpath..";../?.dll"

local pb = require "pb"
local protoc = require "protoc"
local serpent = require "serpent"

-- ֱ������schema (��ôдֻ�Ƿ���, ���������Ƽ�ʹ�� protoc.new() �ӿ�)
assert(protoc:load [[
   message Phone {
      optional string name        = 1;
      optional int64  phonenumber = 2;
   }
   message Person {
      optional string name     = 1;
      optional int32  age      = 2;
      optional string address  = 3;
      repeated Phone  contacts = 4;
   } ]])

-- lua ������
local data = {
   name = "ilse",
   age  = 18,
   contacts = {
      { name = "alice", phonenumber = 12312341234 },
      { name = "bob",   phonenumber = 45645674567 }
   }
}

client = tcpclient.new()

fun_connect = function(conn_idx, is_success)
	-- (1)�����ɶ�����
	local bytes = assert(pb.encode("Person", data))
	client:send_msg(conn_idx, bytes, #bytes);
end

fun_close = function(conn_idx)
	print(conn_idx)
end

fun_recv = function(conn_idx, data, len)
    -- (2)������Lua��
	local t = assert(pb.decode("Person", data))
	print(len)
end

client:connect("127.0.0.1", 30061, fun_connect, fun_close, fun_recv, 8192, 8192) 
