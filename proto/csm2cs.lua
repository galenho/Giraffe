
csm2cs = {}
csm2cs_array = {}

csm2cs = {
	RepEnterGame					= 80001,	-- 回复客户端请求进入游戏
}

for k, v in pairs(csm2cs) do
	if csm2cs_array[v] then
		print("netdefines csm2cs_array error "..k.." "..v)
	end
	
	csm2cs_array[v] = k
end