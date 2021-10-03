local lg = require 'love.graphics'
local checkpoint = require 'entity.object' :subclass 'Checkpoint'
local super = checkpoint.super

function checkpoint:initialize(...)
	super.initialize(self, ...)
	self.checkpoint = true
end

function checkpoint:draw()
	
end

function checkpoint:drawExploded()
	
end

return checkpoint