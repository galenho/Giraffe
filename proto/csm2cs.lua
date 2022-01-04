
csm2cs = {}
csm2cs_array = {}

csm2cs = {
	ReqClientLogin						= 80001,	-- 请求登录
	ReqClientLogOut						= 80002,	-- 请求登出
	ProxyClientMsg						= 80003,    -- 代理发送客户端消息
}

for k, v in pairs(csm2cs) do
	if csm2cs_array[v] then
		print("netdefines csm2cs_array error "..k.." "..v)
	end
	
	csm2cs_array[v] = k
end