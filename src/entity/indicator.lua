local lg = require 'love.graphics'
local indicator = class 'Object'

indicator.static.DEFAULT_RADIUS = 20

function indicator:initialize(points, r)
	self.points = assert(points)
	self.r = indicator.DEFAULT_RADIUS
	self.alpha = 1
end

function indicator:draw()
	local c = properties.palette.outline
	lg.setColor(c[1], c[2], c[3], self.alpha)
	util.drawIndicator(self.points, self.r)
end

function indicator:drawExploded()
	local c = properties.palette.outlineExplosion
	lg.setColor(c[1], c[2], c[3], self.alpha)
	util.drawIndicator(self.points, self.r)
end

return indicator