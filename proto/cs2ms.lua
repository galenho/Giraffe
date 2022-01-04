cs2ms = {}
cs2ms_array = {}

cs2ms = {
	ReqClientLogOut						= 130001,	-- ÇëÇóµÇ³ö
}

for k, v in pairs(cs2ms) do
	if cs2ms_array[v] then
		print("netdefines cs2ms_array error "..k.." "..v)
	end
	
	cs2ms_array[v] = k
end