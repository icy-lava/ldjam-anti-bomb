local game = class('GameState')

local lg = require 'love.graphics'
local lt = require 'love.timer'

function game:enter()
	self.world = tiny.world()
	local world = self.world
	world.bump = bump.newWorld()
	
	world:add(require 'entity.player' (128, 64, 64, 96))
	world:add(require 'entity.block' (128, 512, 256, 32))
	world:add(require 'entity.block' (128 + 256, 512 - 64, 256, 32 + 64))
	world:add {
		x = 256, y = 128, w = 24, h = 24, vx = 0, vy = 0, gx = 0, gy = 1000, restitution = 0.8
	}
	
	world:add(require 'system.bump'())
	world:add(require 'system.on_ground'())
	world:add(require 'system.input'())
	world:add(require 'system.gravity'())
	world:add(require 'system.physics'())
	world:add(require 'system.draw'())
	
	world:refresh()
end

function game:update(dt)
	self.world:update(dt, function(w, s) return not s.draw end)
end

function game:draw()
	self.world:update(lt.getDelta(), function(w, s) return s.draw end)
end

return game