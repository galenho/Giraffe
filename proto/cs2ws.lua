cs2ws = {}
cs2ws_array = {}

cs2ws = {
	ProxyClientMsg						= 90003,    -- �����Ϳͻ�����Ϣ
}

for k, v in pairs(cs2ws) do
	if cs2ws_array[v] then
		print("netdefines cs2ws_array error "..k.." "..v)
	end
	
	cs2ws_array[v] = k
end