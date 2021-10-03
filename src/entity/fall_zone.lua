local lg = require 'love.graphics'
local fallzone = require 'entity.object' :subclass 'FallZone'
local super = fallzone.super

function fallzone:initialize(...)
	super.initialize(self, ...)
	self.fallzone = true
end

function fallzone:draw()
	
end

function fallzone:drawExploded()
	
end

return fallzone