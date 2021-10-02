local lg = require 'love.graphics'
local filter = tiny.requireAll('x', 'y', 'w', 'h')

local function process(self, e, dt)
	lg.rectangle('line', e.x, e.y, e.w, e.h)
end

return function()
	local system = tiny.processingSystem()
	
	system.draw = true
	system.filter = filter
	system.process = process
	
	return system
end