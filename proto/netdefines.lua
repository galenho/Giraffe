c2s = {}
c2s_array = {}

c2s = {
	-- login
    C2SReqClientLogin 			= 10001,
    C2SReqCharacterList 		= 10002,
	C2SReqCreateCharacter 		= 10003,
	C2SReqDeleteCharacter 		= 10004,
	C2SReqEnterGame 			= 10005,
}

for k, v in pairs(c2s) do
	if c2s_array[v] then
		print("netdefines c2s_array error "..k.." "..v)
	end
		
    c2s_array[v] = k
end

-------------------------------------------------------------------------------------
s2c = {}
s2c_array = {}

s2c = {
	-- login
    S2CRepClientLogin 	    = 20001,
    S2CRepCharacterList     = 20002,
	S2CRepCreateCharacter   = 20003,
    S2CRepEnterGame         = 20004,
}

for k, v in pairs(s2c) do
	if s2c_array[v] then
		print("netdefines s2c_array error "..k.." "..v)
	end
	
	s2c_array[v] = k
end