
csm2cs = {}
csm2cs_array = {}

csm2cs = {
	ReqClientLogin						= 80001,	-- �����¼
	ReqClientLogOut						= 80002,	-- ����ǳ�
	ProxyClientMsg						= 80003,    -- �����Ϳͻ�����Ϣ
}

for k, v in pairs(csm2cs) do
	if csm2cs_array[v] then
		print("netdefines csm2cs_array error "..k.." "..v)
	end
	
	csm2cs_array[v] = k
end