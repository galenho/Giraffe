ls2csm = {}
ls2csm_array = {}

ls2csm = {
	ReqCreateSession					= 50001,	-- ���󴴽���һỰ
}

for k, v in pairs(ls2csm) do
	if ls2csm_array[v] then
		print("netdefines ls2csm_array error "..k.." "..v)
	end
	
	ls2csm_array[v] = k
end