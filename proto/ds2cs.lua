ds2cs = {}
ds2cs_array = {}

ds2cs = {
	RepClientLogin						= 160001,	-- �ظ���¼
	RepCharacterData					= 160002,	-- �ظ��������
}

for k, v in pairs(ds2cs) do
	if ds2cs_array[v] then
		print("netdefines ds2ws_array error "..k.." "..v)
	end
	
	ds2cs_array[v] = k
end