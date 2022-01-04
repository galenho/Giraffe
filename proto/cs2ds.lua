cs2ds = {}
cs2ds_array = {}

cs2ds = {
	ReqCharacterData						= 150001,	-- 请求玩家数据
}

for k, v in pairs(cs2ds) do
	if cs2ds_array[v] then
		print("netdefines cs2ds_array error "..k.." "..v)
	end
	
	cs2ds_array[v] = k
end