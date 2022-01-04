
ls2ds = {}
ls2ds_array = {}

ls2ds = {
	ReqClientLogin						= 30001,	-- 请求登录
	ReqClientLogOut						= 30002,	-- 请求登出
	ProxyClientMsg						= 30003,    -- 代理发送客户端消息
}

for k, v in pairs(ls2ds) do
	if ls2ds_array[v] then
		print("netdefines ls2ds_array error "..k.." "..v)
	end
	
	ls2ds_array[v] = k
end
