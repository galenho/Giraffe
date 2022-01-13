
ls2ds = {}
ls2ds_array = {}

ls2ds = {
	ReqClientLogin						= 30001,	-- 请求登录
    ReqCharacterList                    = 30002,    -- 请求角色列表
	ReqCreateCharacter					= 30003,	-- 创建角色
}

for k, v in pairs(ls2ds) do
	if ls2ds_array[v] then
		print("netdefines ls2ds_array error "..k.." "..v)
	end
	
	ls2ds_array[v] = k
end
