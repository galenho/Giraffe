csm2ls = {}
csm2ls_array = {}

csm2ls = {
	RepClientLogin						= 60001,	-- ��¼���
	RepClientLogout						= 60002,	-- �ǳ����
	KickOutAccount						= 60003,	-- �߳��ʺ�
	HardKickOutAccount					= 60004,	-- (ǿ��)�߳��ʺ�
	ProxyWsMsg							= 60005,	-- �����Ϳͻ�����Ϣ
}

for k, v in pairs(csm2ls) do
	if csm2ls_array[v] then
		print("netdefines csm2ls_array error "..k.." "..v)
	end
	
	csm2ls_array[v] = k
end