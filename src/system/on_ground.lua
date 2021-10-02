local filter = tiny.requireAll(util.bumpFilter, 'onGround')

local function process(self, e, dt)
	local bump = self.world.bump
	local ty = e.y + 0.1
	local actualX, actualY, cols, len = bump:check(e, e.x, ty)
	local nog = actualY ~= ty
	if nog ~= e.onGround then
		e.onGround = nog
	end
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end