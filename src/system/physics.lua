local filter = tiny.requireAll(util.bumpFilter, 'vx', 'vy')

local function bounceFilter(item, other)
	if other.solid then return 'bounce' end
end

local function normalFilter(item, other)
	if other.solid then return 'slide' end
end

local function process(self, e, dt)
	local bump = self.world.bump
	if e.damping then
		e.vx = util.damp(e.vx, 0, 1 - e.damping, dt)
		e.vy = util.damp(e.vy, 0, 1 - e.damping, dt)
	end
	local expectX, expectY = e.x + e.vx * dt, e.y + e.vy * dt
	local bouncy = e.getRestitution and e:getRestitution() > 0
	local actualX, actualY, cols, len = bump:move(e, expectX, expectY, bouncy and bounceFilter or normalFilter)
	if bouncy then
		for i = 1, len do
			local c = cols[i]
			if c.type == 'bounce' then
				local nx, ny = util.sign(c.normal.x), util.sign(c.normal.y)
				if nx ~= 0 then e.vx = e.vx * -math.abs(nx) * e.restitution end
				if ny ~= 0 then e.vy = e.vy * -math.abs(ny) * e.restitution end
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