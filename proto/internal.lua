internal = {}
internal_array = {}

internal = {
	ReqLogin						= 1,
	RepLogin						= 2,
	AppServerList					= 3,	-- 广播当前服务器列表
	AppServerAdd					= 4,
	AppServerRemove					= 5,
	AppServerShutdown				= 6,
	ReqServerSerial					= 7,
	RepServerSerial					= 8,
	ReqServerRes					= 9,	-- 请求数据库查询
	RepServerRes					= 10,	-- 返回数据库查询
}

for k, v in pairs(internal) do
	if internal_array[v] then
		print("netdefines internal_array error "..k.." "..v)
	end
	
	internal_array[v] = k
end
