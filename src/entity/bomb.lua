local bomb = require 'entity.dynamic' :subclass 'Bomb'
local super = bomb.super

bomb.static.WIDTH = 24
bomb.static.HEIGHT = 24

function bomb:initialize(x, y)
	local w, h = bomb.WIDTH, bomb.HEIGHT
	super.initialize(self, x - w / 2, y - h / 2, w, h)
	self:setRestitution(0.8)
	self.timeMax = 1
	self.time = 0
end

return bomb