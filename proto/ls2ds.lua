
ls2ds = {}
ls2ds_array = {}

ls2ds = {
	ReqClientLogin						= 30001,	-- �����¼
	ReqClientLogOut						= 30002,	-- ����ǳ�
	ProxyClientMsg						= 30003,    -- �����Ϳͻ�����Ϣ
}

for k, v in pairs(ls2ds) do
	if ls2ds_array[v] then
		print("netdefines ls2ds_array error "..k.." "..v)
	end
	
	ls2ds_array[v] = k
end
