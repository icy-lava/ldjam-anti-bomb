local block = require 'entity.object' :subclass 'Block'
local super = block.super

function block:initialize(...)
	super.initialize(self, ...)
	self.solid = true
end

return block