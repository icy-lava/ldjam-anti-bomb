local dynamic = require 'entity.kinematic' :subclass 'DynamicObject'
local super = dynamic.super

dynamic.static.GRAVITY_X = 0
dynamic.static.GRAVITY_Y = 1000

function dynamic:initialize(...)
	super.initialize(self, ...)
	self.gx, self.gy = dynamic.GRAVITY_X, dynamic.GRAVITY_Y
	self.restitution = 0
	self.damping = 0.05
end

function dynamic:setRestitution(r)
	self.restitution = r
	return self
end

function dynamic:getRestitution()
	return self.restitution
end

return dynamic