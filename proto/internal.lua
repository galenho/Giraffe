internal = {}
internal_array = {}

internal = {
	ReqLogin						= 1,
	RepLogin						= 2,
	AppServerList					= 3,	-- �㲥��ǰ�������б�
	AppServerAdd					= 4,
	AppServerRemove					= 5,
	AppServerShutdown				= 6,
	ReqServerSerial					= 7,
	RepServerSerial					= 8,
	ReqServerRes					= 9,	-- �������ݿ��ѯ
	RepServerRes					= 10,	-- �������ݿ��ѯ
}

for k, v in pairs(internal) do
	if internal_array[v] then
		print("netdefines internal_array error "..k.." "..v)
	end
	
	internal_array[v] = k
end
