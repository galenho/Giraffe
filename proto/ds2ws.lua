ds2ws = {}
ds2ws_array = {}

ds2ws = {
	RepClientLogin						= 120001,	-- �ظ���¼
	RepCharacterList					= 120002,	-- �ظ���ɫ�б�
	RepCreateCharacter					= 120003,	-- �ظ�������ɫ
	RepDeleteCharacter					= 120004,	-- �ظ�ɾ����ɫ
}

for k, v in pairs(ds2ws) do
	if ds2ws_array[v] then
		print("netdefines ds2ws_array error "..k.." "..v)
	end
	
	ds2ws_array[v] = k
end