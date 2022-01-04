ms2cs = {}
ms2cs_array = {}

ms2cs = {
	ReqClientLogOut						= 140001,	-- ÇëÇóµÇ³ö
}

for k, v in pairs(ms2cs) do
	if ms2cs_array[v] then
		print("netdefines ms2cs_array error "..k.." "..v)
	end
	
	ms2cs_array[v] = k
end