local lg = require 'love.graphics'
local wire = class 'Wire'

function wire:initialize(points)
	self.points = points
end

local function draw(self)
	local lw = lg.getLineWidth()
	lg.setLineWidth(4)
	lg.setLineJoin('bevel')
	lg.line(self.points)
	lg.setLineWidth(lw)
end

function wire:draw()
	lg.setColor(self.switch.enabled and properties.palette.outlineExplosion or properties.palette.wire)
	draw(self)
end

function wire:drawExploded()
	lg.setColor(properties.palette.outlineExplosion)
	draw(self)
end

return wire