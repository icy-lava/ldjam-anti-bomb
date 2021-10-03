local lg = require 'love.graphics'
local filter = tiny.requireAll('drawExploded')

local function preProcess(self, dt)
	lg.setStencilTest('equal', 1)
	lg.setColor(properties.palette.backgroundExplosion)
	lg.rectangle('fill', 0, 0, lg.getDimensions())
	self.world.camera:attach()
	local shake = self.world.camera.shake or 0
	lg.translate(shake * (love.math.random() * 2 - 1) * 10, shake * (love.math.random() * 2 - 1) * 10)
end

local function process(self, e, dt)
	e:drawExploded()
end

local function postProcess(self, dt)
	lg.setStencilTest()
	self.world.camera:detach()
end

return function()
	local system = tiny.processingSystem()
	
	system.draw = true
	system.filter = filter
	system.preProcess = preProcess
	system.process = process
	system.postProcess = postProcess
	
	return system
end