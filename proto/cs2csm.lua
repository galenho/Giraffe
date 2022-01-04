cs2csm = {}
cs2csm_array = {}

cs2csm = {
	RepClientLogin						= 70001,	-- 登录结果
	RepClientLogout						= 70002,	-- 登出结果
	KickOutAccount						= 70003,	-- 踢出帐号
	HardKickOutAccount					= 70004,	-- (强行)踢出帐号
	ProxyWsMsg							= 70005,	-- 代理发送客户端消息
}

for k, v in pairs(cs2csm) do
	if cs2csm_array[v] then
		print("netdefines cs2csm_array error "..k.." "..v)
	end
	
	cs2csm_array[v] = k
end