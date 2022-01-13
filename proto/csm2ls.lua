csm2ls = {}
csm2ls_array = {}

csm2ls = {
	RepCreateSession					= 60001,	-- 回复创建玩家会话
}

for k, v in pairs(csm2ls) do
	if csm2ls_array[v] then
		print("netdefines csm2ls_array error "..k.." "..v)
	end
	
	csm2ls_array[v] = k
end