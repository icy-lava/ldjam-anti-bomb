local filter = tiny.requireAll('x', 'y', 'w', 'h')

local function onAdd(self, e)
	self.world.bump:add(e, e.x, e.y, e.w, e.h)
end

local function onRemove(self, e)
	self.world.bump:remove(e)
end

local function process(self, e, dt)
	e.x, e.y, e.w, e.h = self.world.bump:getRect(e)
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	
	system.onAdd = onAdd
	system.onRemove = onRemove
	system.process = process
	
	return system
end