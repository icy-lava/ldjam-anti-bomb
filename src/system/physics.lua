local filter = tiny.requireAll(util.bumpFilter, 'vx', 'vy')

local function bounceFilter(item, other)
	if other.solid then return 'bounce' end
	if other.checkpoint or other.fallzone or other.scenezone then return 'cross' end
end

local function normalFilter(item, other)
	if other.solid then return 'slide' end
	if other.checkpoint or other.fallzone or other.scenezone then return 'cross' end
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
	if e == self.world.player and not e.falling then
		for i = 1, len do
			local c = cols[i]
			if c.other.checkpoint then
				self.world.checkpoint = c.other
			end
			if c.other.fallzone then
				e.falling = true
				e.lastX, e.lastY = e:getCenter()
				util.getTweener():to(self.world.scene, 0.5, {}):after(0.3, {fade = 1}):ease('quadinout')
				util.getTweener():to({}, 1.2, {}):oncomplete(function()
					self.world.scene:reset()
				end)
			end
			if c.other.scenezone then
				util.getTweener():to(self.world.scene, 2, {fade = 1}):ease('quadinout'):oncomplete(function()
					self.world.nextScene = c.other.scene
				end)
			end
		end
	end
	if bouncy then
		for i = 1, len do
			local c = cols[i]
			if c.type == 'bounce' then
				if c.item.class == require 'entity.bomb' and not c.item.sim then util.playSound 'bomb_bounce' end
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