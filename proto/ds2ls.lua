
ds2ls = {}
ds2ls_array = {}

ds2ls = {
	RepClientLogin						= 40001,	-- µÇÂ¼½á¹û
}

for k, v in pairs(ds2ls) do
	if ds2ls_array[v] then
		print("netdefines ds2ls_array error "..k.." "..v)
	end
	
	ds2ls_array[v] = k
end