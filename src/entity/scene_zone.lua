local lg = require 'love.graphics'
local scenezone = require 'entity.object' :subclass 'SceneZone'
local super = scenezone.super

function scenezone:initialize(...)
	super.initialize(self, ...)
	self.scenezone = true
end

function scenezone:draw()
	
end

function scenezone:drawExploded()
	
end

return scenezone