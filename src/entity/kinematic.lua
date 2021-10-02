local kinematic = require 'entity.object' :subclass 'KinematicObject'
local super = kinematic.super

function kinematic:initialize(...)
	super.initialize(self, ...)
	self.vx, self.vy = 0, 0
end

return kinematic