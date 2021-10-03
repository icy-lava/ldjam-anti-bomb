local lg = require 'love.graphics'
local indicator = class 'Object'

function indicator:initialize(x, y, r)
	self.x, self.y, self.r = x, y, r
	self.alpha = 0.1
end

function indicator:draw()
	local c = properties.palette.outline
	lg.setColor(c[1], c[2], c[3], self.alpha)
	lg.setLineWidth(4)
	lg.circle('line', self.x, self.y, self.r, self.r * util.tau)
end

return indicator