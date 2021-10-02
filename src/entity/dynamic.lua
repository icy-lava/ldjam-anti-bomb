local dynamic = require 'entity.kinematic' :subclass 'DynamicObject'
local super = dynamic.super

function dynamic:initialize(...)
	super.initialize(self, ...)
	self.gx, self.gy = 0, 1000
end

return dynamic