ws2ds = {}
ws2ds_array = {}

ws2ds = {
	ReqClientLogin						= 110001,	-- 请求登录
	ReqCharacterList					= 110002,	-- 请求角色列表信息
	ReqCreateCharacter					= 110003,	-- 请求创建角色
	ReqDeleteCharacter					= 110004,	-- 请求删除角色
}

for k, v in pairs(ws2ds) do
	if ws2ds_array[v] then
		print("netdefines ws2ds_array error "..k.." "..v)
	end
	
	ws2ds_array[v] = k
end