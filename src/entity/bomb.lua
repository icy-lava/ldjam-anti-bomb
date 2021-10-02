local bomb = require 'entity.dynamic' :subclass 'Bomb'
local super = bomb.super

bomb.static.WIDTH = 32
bomb.static.HEIGHT = 32
bomb.static.TIME_MAX = 2

function bomb:initialize(x, y)
	local w, h = bomb.WIDTH, bomb.HEIGHT
	super.initialize(self, x - w / 2, y - h / 2, w, h)
	self:setRestitution(0.8)
	self.timeMax = bomb.TIME_MAX
	self.time = 0
end

local lg = require 'love.graphics'
function bomb:draw()
	local x, y = self:getCenter()
	util.drawBomb(x, y, self.time / self.timeMax)
end

return bomb