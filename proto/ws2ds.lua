ws2ds = {}
ws2ds_array = {}

ws2ds = {
	ReqClientLogin						= 110001,	-- �����¼
	ReqCharacterList					= 110002,	-- �����ɫ�б���Ϣ
	ReqCreateCharacter					= 110003,	-- ���󴴽���ɫ
	ReqDeleteCharacter					= 110004,	-- ����ɾ����ɫ
}

for k, v in pairs(ws2ds) do
	if ws2ds_array[v] then
		print("netdefines ws2ds_array error "..k.." "..v)
	end
	
	ws2ds_array[v] = k
end