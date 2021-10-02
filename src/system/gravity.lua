local filter = tiny.requireAll('vx', 'vy', 'gx', 'gy')

local function process(self, e, dt)
	e.vx, e.vy = e.vx + e.gx * dt, e.vy + e.gy * dt
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end