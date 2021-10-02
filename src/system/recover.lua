local filter = tiny.requireAll('control')

local function process(self, e, dt)
	e.control = math.min(e.control + dt, 1)
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end