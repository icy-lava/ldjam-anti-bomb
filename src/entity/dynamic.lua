local dynamic = require 'entity.kinematic' :subclass 'DynamicObject'
local super = dynamic.super

function dynamic:initialize(...)
	super.initialize(self, ...)
	self.gx, self.gy = 0, 1000
	self.restitution = 0
end

function dynamic:setRestitution(r)
	self.restitution = r
	return self
end

function dynamic:getRestitution()
	return self.restitution
end

return dynamic