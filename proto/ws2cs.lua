ws2cs = {}
ws2cs_array = {}

ws2cs = {
	RepClientLogin						= 100001,	-- ��¼���
	RepClientLogout						= 100002,	-- �ǳ����
	KickOutAccount						= 100003,	-- �߳��ʺ�
	HardKickOutAccount					= 100004,	-- (ǿ��)�߳��ʺ�
	ProxyWsMsg							= 100005,	-- �����Ϳͻ�����Ϣ
}

for k, v in pairs(ws2cs) do
	if ws2cs_array[v] then
		print("netdefines ws2cs_array error "..k.." "..v)
	end
	
	ws2cs_array[v] = k
end