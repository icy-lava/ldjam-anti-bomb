local bouncy = require 'entity.dynamic' :subclass 'BouncyObject'
local super = bouncy.super

function bouncy:initialize(...)
	super.initialize(self, ...)
	self.restitution = 0.5
end

function bouncy:setRestitution(r)
	self.restitution = r
	return self
end

return bouncy