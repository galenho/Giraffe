
ds2ls = {}
ds2ls_array = {}

ds2ls = {
	RepClientLogin						= 40001,	-- ��¼���
    RepCharacterList					= 40002,	-- ��ɫ�б���
    RepCreateCharacter					= 40003,	-- ������ɫ���
}

for k, v in pairs(ds2ls) do
	if ds2ls_array[v] then
		print("netdefines ds2ls_array error "..k.." "..v)
	end
	
	ds2ls_array[v] = k
end