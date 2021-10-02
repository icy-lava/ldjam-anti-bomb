local function update(self, dt)
	self.tween:update(dt)
end

return function()
	local system = tiny.processingSystem()
	
	system.tween = flux.group()
	system.update = update
	
	return system
end