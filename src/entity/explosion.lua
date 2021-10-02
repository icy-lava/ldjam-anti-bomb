local lg = require 'love.graphics'
local explosion = class 'Object'

function explosion:initialize(x, y, r)
	self.x, self.y, self.r = x, y, r
end

function explosion:drawExplosionStencil()
	lg.circle('fill', self.x, self.y, self.r, self.r * util.tau)
end

return explosion