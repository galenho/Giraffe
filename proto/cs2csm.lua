cs2csm = {}
cs2csm_array = {}

cs2csm = {
	RepClientLogin						= 70001,	-- ��¼���
	RepClientLogout						= 70002,	-- �ǳ����
	KickOutAccount						= 70003,	-- �߳��ʺ�
	HardKickOutAccount					= 70004,	-- (ǿ��)�߳��ʺ�
	ProxyWsMsg							= 70005,	-- �����Ϳͻ�����Ϣ
}

for k, v in pairs(cs2csm) do
	if cs2csm_array[v] then
		print("netdefines cs2csm_array error "..k.." "..v)
	end
	
	cs2csm_array[v] = k
end