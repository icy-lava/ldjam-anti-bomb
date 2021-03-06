local lg = require 'love.graphics'
local filter = tiny.requireAll('draw')

local function preProcess(self, dt)
	self.world.camera:attach()
	local shake = self.world.camera.shake or 0
	lg.translate(shake * (love.math.random() * 2 - 1) * 10, shake * (love.math.random() * 2 - 1) * 10)
end

local function process(self, e, dt)
	-- lg.rectangle('line', e.x, e.y, e.w, e.h)
	e:draw()
end

local function postProcess(self, dt)
	self.world.camera:detach()
end

local function compare(self, a, b)
	if a.class == require 'entity.wire' then return false end
end

return function()
	local system = tiny.sortedProcessingSystem()
	
	system.draw = true
	system.filter = filter
	system.preProcess = preProcess
	system.process = process
	system.postProcess = postProcess
	system.compare = compare
	
	return system
end