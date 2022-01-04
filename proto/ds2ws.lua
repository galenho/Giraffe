ds2ws = {}
ds2ws_array = {}

ds2ws = {
	RepClientLogin						= 120001,	-- 回复登录
	RepCharacterList					= 120002,	-- 回复角色列表
	RepCreateCharacter					= 120003,	-- 回复创建角色
	RepDeleteCharacter					= 120004,	-- 回复删除角色
}

for k, v in pairs(ds2ws) do
	if ds2ws_array[v] then
		print("netdefines ds2ws_array error "..k.." "..v)
	end
	
	ds2ws_array[v] = k
end