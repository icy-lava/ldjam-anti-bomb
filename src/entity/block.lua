local lg = require 'love.graphics'
local block = require 'entity.object' :subclass 'Block'
local super = block.super

function block:initialize(...)
	super.initialize(self, ...)
	self.solid = true
end

function block:draw()
	local lw = lg.getLineWidth()
	lg.setLineWidth(4)
	lg.setColor(properties.palette.solid)
	lg.rectangle('fill', self.x, self.y, self.w, self.h, 3)
	lg.setColor(properties.palette.outline)
	lg.rectangle('line', self.x, self.y, self.w, self.h, 3)
	lg.setLineWidth(lw)
end

return block