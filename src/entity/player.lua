local player = require 'entity.dynamic' :subclass 'Player'
local super = player.super

player.static.WIDTH = 64
player.static.HEIGHT = 96

function player:initialize(x, y)
	local w, h = player.WIDTH, player.HEIGHT
	super.initialize(self, x - w / 2, y - h / 2, w, h)
	self.input = {
		up = {'up', 'w'},
		down = {'down', 's'},
		left = {'left', 'a'},
		right = {'right', 'd'},
	}
	self.speedMax = 500
	self.onGround = false
	self.control = 1
	self.restitution = 0.9
end

local lm = require 'love.mouse'
local lg = require 'love.graphics'
function player:draw()
	super.draw(self)
	do
		local x, y = self.x + self.w / 2, self.y + self.h / 2
		local mx, my = util.getCamera():worldCoords(lm.getPosition())
		local dx, dy = vector.sub(mx, my, x, y)
		local dlen = vector.len(dx, dy)
		local offset = 24
		local r = 20
		lg.circle('line', x - dx / dlen * offset, y - dy / dlen * offset * 0.75, r, r * math.pi * 2)
	end
	if cli.debug then
		local w, h = 100, 8
		local x, y = self.x + self.w / 2, self.y + self.h + 10
		lg.rectangle('line', x - w / 2, y, w, h)
		lg.rectangle('fill', x - w / 2, y, w * self.control, h)
	end
end

function player:getRestitution()
	return self.restitution * util.clamp(util.remap(self.control ^ 2, 0, 1, 1, -0.1), 0, 1)
end

return player