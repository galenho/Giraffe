local common = require "common"

ClientSession = {}

-- 未创建
ClientSession.SS_NONE		= 0
-- 刚创建
ClientSession.SS_CREATED	= 1
-- 已进入SS，游戏中
ClientSession.SS_INGAME		= 2
-- 传送中
ClientSession.SS_TRANSFERING= 3
-- 断线中
ClientSession.SS_OFFLINEING	= 4

function ClientSession:New(o)
    o = o or {}	
	self.__index = self
	setmetatable(o, self)
	
	-- 下面写成员变量
	
    return o
end

function ClientSession:Send()
	
end

return ClientSession