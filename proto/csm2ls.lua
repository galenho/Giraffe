csm2ls = {}
csm2ls_array = {}

csm2ls = {
	RepClientLogin						= 60001,	-- 登录结果
	RepClientLogout						= 60002,	-- 登出结果
	KickOutAccount						= 60003,	-- 踢出帐号
	HardKickOutAccount					= 60004,	-- (强行)踢出帐号
	ProxyWsMsg							= 60005,	-- 代理发送客户端消息
}

for k, v in pairs(csm2ls) do
	if csm2ls_array[v] then
		print("netdefines csm2ls_array error "..k.." "..v)
	end
	
	csm2ls_array[v] = k
end