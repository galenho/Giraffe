cs2csm = {}
cs2csm_array = {}

cs2csm = {
	NotifyCsInfo				= 70001,	-- 把cs的登录信息通知到csm
	
}

for k, v in pairs(cs2csm) do
	if cs2csm_array[v] then
		print("netdefines cs2csm_array error "..k.." "..v)
	end
	
	cs2csm_array[v] = k
end