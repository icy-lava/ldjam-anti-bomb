local game = class('GameState')

local lg = require 'love.graphics'
local lt = require 'love.timer'

function game:enter(prev)
	self.world = tiny.world()
	self.fade = 1
	local world = self.world
	world.scene = self
	world.bump = bump.newWorld()
	if prev.class == game then world.checkpoint = prev.world.checkpoint end
	
	world.level = json.decode(love.filesystem.read('asset/map/level1.json'))
	
	local connections = {}
	local switches = {}
	local toggleds = {}
	for _, obj in ipairs(world.level.layers[1].objects) do
		local x, y, w, h = obj.x, obj.y, obj.width, obj.height
		local cx, cy = obj.x + obj.width / 2, obj.y + obj.height / 2
		local name = obj.name:lower()
		if name == 'player' then
			assert(not world.player, 'player added twice in level')
			local px, py = cx, cy
			local cp = world.checkpoint
			if cp then
				px = cp.x + cp.w / 2
				py = cp.y + cp.h - require 'entity.player'.HEIGHT - 10
			end
			world.player = require 'entity.player' (px, py)
			world:add(world.player)
		elseif name == 'toggled' then
			local t = require 'entity.toggled_block' (x, y, w, h)
			world:add(t)
			table.insert(toggleds, t)
		elseif name == 'toggled-off' then
			local t = require 'entity.toggled_block' (x, y, w, h)
			t.solid = false
			world:add(t)
			table.insert(toggleds, t)
		elseif name == 'switch' then
			local s = require 'entity.switch' (x, y, w, h)
			world:add(s)
			table.insert(switches, s)
		elseif name == 'checkpoint' then
			world:add(require 'entity.checkpoint' (x, y, w, h))
		elseif name == 'fallzone' then
			world:add(require 'entity.fall_zone' (x, y, w, h))
		elseif name == 'end' then
			local e = require 'entity.scene_zone' (x, y, w, h)
			e.scene = 'game_end'
			world:add(e)
		elseif obj.polyline then
			table.insert(connections, obj.polyline)
			local points = {}
			for _, p in ipairs(obj.polyline) do
				p.x, p.y = p.x + obj.x, p.y + obj.y
				lume.push(points, p.x, p.y)
			end
			local e = require 'entity.wire' (points)
			world:add(e)
			obj.polyline.entity = e
		else
			world:add(require 'entity.block' (x, y, w, h))
		end
	end
	for _, pline in ipairs(connections) do
		local switch
		for _, p in ipairs(pline) do
			for _, s in ipairs(switches) do
				if p.x >= s.x - 1 and p.x <= s.x + s.w + 1 and p.y >= s.y - 1 and p.y <= s.y + s.h + 1 then
					assert(not switch, 'connecting multiple switches is not allowed')
					switch = s
					pline.entity.switch = switch
				end
			end
		end
		if switch then
			for _, t in ipairs(toggleds) do
				for _, p in ipairs(pline) do
					if p.x >= t.x - 1 and p.x <= t.x + t.w + 1 and p.y >= t.y - 1 and p.y <= t.y + t.h + 1 then
						table.insert(switch.toggles, t)
						break
					end
				end
			end
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
	asset.audio()
	util.getTweener(self):to(self, 0.5, {fade = 0}):ease('quadinout')
	self.font = asset.font['Montserrat-Regular'](24)
end

function game:update(dt)
	local ns = self.world.nextScene
	if ns then
		scene:enter(require('scene.' .. ns):new())
		return
	end
	if dt > 0.1 then dt = 0.1 end
	self.world:update(dt, function(w, s) return not s.draw end)
end

function game:draw()
	lg.setBackgroundColor(properties.palette.background)
	self.world:update(lt.getDelta(), function(w, s) return s.draw end)
	local w, h = lg.getDimensions()
	lg.setColor(properties.palette.outline)
	do -- Speedrun timer
		local pf = lg.getFont()
		local f = self.font
		lg.setFont(f)
		local tw = f:getWidth(util.getTimerString(0))
		local pad = 4
		lg.print(util.getTimerString(lt.getTime() - startTime), w - tw - pad, pad)
		lg.setFont(pf)
	end
	lg.setColor(0, 0, 0, self.fade)
	lg.rectangle('fill', 0, 0, w, h)
	if cli.debug then
		lg.setColor(0, 0, 0, 1)
		local adt = lt.getAverageDelta()
		lg.print(string.format('FPS: %0.1f, DT: %0.1fms', 1 / adt, adt * 1e3), 4, 4)
	end
end

function game:reset()
	local items, len = self.world.bump:getItems()
	for i = 1, len do
		local s = items[i].sound
		if s then s:stop() end
	end
	scene:enter(require 'scene.game':new())
end

function game:keypressed(key)
	if key == 'r' then
		self:reset()
		return
	end
end

function game:mousepressed(mx, my, button)
	local world = self.world
	local player = world.player
	if button == 1 and not player.falling then
		player:throwBombPrepare()
		return
	end
	if cli.debug and button == 2 then
		local p = player
		local x, y = world.camera:worldCoords(mx, my)
		p.x, p.y = x, y
		world.bump:update(player, x, y)
	end
end

function game:mousereleased(mx, my, button)
	local player = self.world.player
	if button == 1 and not player.falling then
		player:throwBomb(util.getCamera(self):worldCoords(mx, my))
		return
	end
end

return game