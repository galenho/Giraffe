
ls2ds = {}
ls2ds_array = {}

ls2ds = {
	ReqClientLogin						= 30001,	-- �����¼
    ReqCharacterList                    = 30002,    -- �����ɫ�б�
	ReqCreateCharacter					= 30003,	-- ������ɫ
}

for k, v in pairs(ls2ds) do
	if ls2ds_array[v] then
		print("netdefines ls2ds_array error "..k.." "..v)
	end
	
	ls2ds_array[v] = k
end
