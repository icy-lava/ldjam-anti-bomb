if love then
	local fs = require 'love.filesystem'
	fs.setRequirePath('lib/?/init.lua;lib/?.lua;' .. fs.getRequirePath())
	fs.setRequirePath('src/?/init.lua;src/?.lua;' .. fs.getRequirePath())
end
package.path = '?/init.lua;lib/?/init.lua;lib/?.lua;' .. package.path
package.path = 'src/?/init.lua;src/?.lua;' .. package.path