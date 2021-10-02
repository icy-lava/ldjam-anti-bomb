local player = require 'entity.dynamic' :subclass 'Player'
local super = player.super

function player:initialize(...)
	super.initialize(self, ...)
	self.input = {
		up = {'up', 'w'},
		down = {'down', 's'},
		left = {'left', 'a'},
		right = {'right', 'd'},
	}
	self.speedMax = 500
	self.onGround = false
end

return player