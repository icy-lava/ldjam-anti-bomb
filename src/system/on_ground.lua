local filter = tiny.requireAll(util.bumpFilter, 'onGround')

local function isGroundFilter(_, item)
	return item.solid and 'slide'
end

local function process(self, e, dt)
	local bump = self.world.bump
	local ty = e.y + 0.1
	local actualX, actualY, cols, len = bump:check(e, e.x, ty, isGroundFilter)
	local nog = actualY ~= ty
	if nog ~= e.onGround then
		if nog then
			local s = asset.audio['land' .. love.math.random(1, 3)]
			s:setPitch(2 ^ ((love.math.random() * 2 - 1) * 0.1))
			util.playSound(s)
		end
		e.onGround = nog
	end
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end