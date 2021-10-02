local filter = tiny.requireAll(util.bumpFilter, 'vx', 'vy')

local function bounceFilter(item, other)
	if other.solid then return 'bounce' end
end

local function normalFilter(item, other)
	if other.solid then return 'slide' end
end

local function process(self, e, dt)
	local bump = self.world.bump
	local expectX, expectY = e.x + e.vx * dt, e.y + e.vy * dt
	local bouncy = not not e.restitution
	local actualX, actualY, cols, len = bump:move(e, expectX, expectY, bouncy and bounceFilter or normalFilter)
	if bouncy then
		for i = 1, len do
			local c = cols[i]
			if c.type == 'bounce' then
				e.vx, e.vy = e.vx * -math.abs(c.normal.x) * e.restitution, e.vy * -math.abs(c.normal.y) * e.restitution
			end
		end
	else
		if expectX ~= actualX then e.vx = 0 end
		if expectY ~= actualY then e.vy = 0 end
	end
	e.x, e.y = actualX, actualY
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end