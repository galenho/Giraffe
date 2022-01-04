ws2cs = {}
ws2cs_array = {}

ws2cs = {
	RepClientLogin						= 100001,	-- 登录结果
	RepClientLogout						= 100002,	-- 登出结果
	KickOutAccount						= 100003,	-- 踢出帐号
	HardKickOutAccount					= 100004,	-- (强行)踢出帐号
	ProxyWsMsg							= 100005,	-- 代理发送客户端消息
}

for k, v in pairs(ws2cs) do
	if ws2cs_array[v] then
		print("netdefines ws2cs_array error "..k.." "..v)
	end
	
	ws2cs_array[v] = k
end