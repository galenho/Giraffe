package.path = package.path..";../?.lua"
package.path = package.path..";../common/?.lua"
package.path = package.path..";../common/hotfix/?.lua"
package.path = package.path..";../common/lua-protobuf/?.lua"
package.path = package.path..";../common/lua-xml/?.lua"
package.path = package.path..";../config/?.lua"
package.path = package.path..";../proto/?.lua"

package.cpath = package.cpath..";../?.dll"

local global = require "global"
local Master = require "master"

function Main() 
	global.master = Master:New()
	global.master:Run()
end

Main()