ls2csm = {}
ls2csm_array = {}

ls2csm = {
	ReqClientLogin						= 50001,	-- 请求登录
	ReqClientLogOut						= 50002,	-- 请求登出
	ProxyClientMsg						= 50003,    -- 代理发送客户端消息
}

for k, v in pairs(ls2csm) do
	if ls2csm_array[v] then
		print("netdefines ls2csm_array error "..k.." "..v)
	end
	
	ls2csm_array[v] = k
end