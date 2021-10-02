local lg = require 'love.graphics'
local filter = tiny.requireAll('drawExplosionStencil')

local function preProcess(self, dt)
	self.world.camera:attach()
	lg.clear(false, true, false)
end

local function process(self, e, dt)
	lg.stencil(function()
		e:drawExplosionStencil()
	end, 'replace', 1, true)
end

local function postProcess(self, dt)
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