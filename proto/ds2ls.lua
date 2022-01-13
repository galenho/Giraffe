
ds2ls = {}
ds2ls_array = {}

ds2ls = {
	RepClientLogin						= 40001,	-- 登录结果
    RepCharacterList					= 40002,	-- 角色列表结果
    RepCreateCharacter					= 40003,	-- 创建角色结果
}

for k, v in pairs(ds2ls) do
	if ds2ls_array[v] then
		print("netdefines ds2ls_array error "..k.." "..v)
	end
	
	ds2ls_array[v] = k
end