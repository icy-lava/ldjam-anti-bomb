local lg = require 'love.graphics'
local object = class 'Object'

function object:initialize(x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

function object:draw()
	local lw = lg.getLineWidth()
	lg.setLineWidth(4)
	lg.setColor(properties.palette.outline)
	lg.rectangle('line', self.x, self.y, self.w, self.h, 3)
	lg.setLineWidth(lw)
end

function object:drawExploded()
	local lw = lg.getLineWidth()
	lg.setLineWidth(4)
	lg.setColor(properties.palette.outlineExplosion)
	lg.rectangle('line', self.x, self.y, self.w, self.h, 3)
	lg.setLineWidth(lw)
end

function object:getCenter()
	return self.x + self.w / 2, self.y + self.h / 2
end

return object