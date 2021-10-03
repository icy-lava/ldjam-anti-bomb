local game = class('GameState')

local lg = require 'love.graphics'
local lt = require 'love.timer'

function game:enter()
	self.world = tiny.world()
	local world = self.world
	world.bump = bump.newWorld()
	
	world.level = json.decode(love.filesystem.read('asset/map/level1.json'))
	
	for _, obj in ipairs(world.level.layers[1].objects) do
		local x, y, w, h = obj.x, obj.y, obj.width, obj.height
		local cx, cy = obj.x + obj.width / 2, obj.y + obj.height / 2
		local name = obj.name:lower()
		if name == 'player' then
			assert(not world.player, 'player added twice in level')
			world.player = require 'entity.player' (cx, cy)
			world:add(world.player)
		else
			world:add(require 'entity.block' (x, y, w, h))
		end
	end
	
	world.camera = camera.new(world.player:getCenter())
	
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
	util.addSystem(world, 'draw_explosion_stencil')
	util.addSystem(world, 'draw_explosion')
	
	world:refresh()
	lg.setBackgroundColor(properties.palette.background)
end

function game:update(dt)
	self.world:update(dt, function(w, s) return not s.draw end)
end

function game:draw()
	lg.setBackgroundColor(properties.palette.background)
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