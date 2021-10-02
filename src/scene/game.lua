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
	world.camera = camera.new(0, 20)
	-- world.camera.scale = 1.0
	
	util.addSystem(world, 'bump')
	util.addSystem(world, 'tween')
	util.addSystem(world, 'on_ground')
	util.addSystem(world, 'recover')
	util.addSystem(world, 'input')
	util.addSystem(world, 'gravity')
	util.addSystem(world, 'physics')
	util.addSystem(world, 'bomb')
	util.addSystem(world, 'camera')
	
	util.addSystem(world, 'draw')
	
	world:refresh()
end

function game:update(dt)
	self.world:update(dt, function(w, s) return not s.draw end)
end

function game:draw()
	self.world:update(lt.getDelta(), function(w, s) return s.draw end)
end

function game:mousepressed(mx, my, button)
	if button == 1 then
		self.world.player:throwBombPrepare()
		return
	end
end

function game:mousereleased(mx, my, button)
	if button == 1 then
		self.world.player:throwBomb(util.getCamera(self):worldCoords(mx, my))
		return
	end
end

return game