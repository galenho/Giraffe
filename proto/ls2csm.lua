ls2csm = {}
ls2csm_array = {}

ls2csm = {
	ReqClientLogin						= 50001,	-- �����¼
	ReqClientLogOut						= 50002,	-- ����ǳ�
	ProxyClientMsg						= 50003,    -- �����Ϳͻ�����Ϣ
}

for k, v in pairs(ls2csm) do
	if ls2csm_array[v] then
		print("netdefines ls2csm_array error "..k.." "..v)
	end
	
	ls2csm_array[v] = k
end