local game = class('GameState')

local lg = require 'love.graphics'
local lt = require 'love.timer'

function game:enter()
	self.world = tiny.world()
	local world = self.world
	world.bump = bump.newWorld()
	
	world.player = require 'entity.player' (-100, 0)
	world:add(world.player)
	world:add(require 'entity.block' (-256, 128, 512, 32))
	world:add(require 'entity.block' (256, -128, 32, 256 + 32))
	-- world:add(require 'entity.bomb' (0, 0))
	world.camera = camera.new(0, 0)
	
	world:add(require 'system.bump'())
	world:add(require 'system.on_ground'())
	world:add(require 'system.recover'())
	world:add(require 'system.input'())
	world:add(require 'system.gravity'())
	world:add(require 'system.physics'())
	world:add(require 'system.bomb'())
	
	world:add(require 'system.draw'())
	
	world:refresh()
end

function game:update(dt)
	self.world:update(dt, function(w, s) return not s.draw end)
end

function game:draw()
	self.world:update(lt.getDelta(), function(w, s) return s.draw end)
end

function game:mousereleased(mx, my, button)
	if button == 1 then
		mx, my = util.getCamera(self):worldCoords(mx, my)
		local p = util.getPlayer(self)
		local px, py = util.getBombOrigin(self)
		local nx, ny = vector.normalize(vector.sub(mx, my, px, py))
		
		local speed = 500
		local b = require 'entity.bomb':new(px, py)
		b.vx, b.vy = nx * speed, ny * speed
		
		self.world:addEntity(b)
	end
end

return game