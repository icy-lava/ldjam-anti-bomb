local player = require 'entity.dynamic' :subclass 'Player'
local super = player.super

player.static.WIDTH = 64
player.static.HEIGHT = 96
player.static.DEFAULT_ARM_POSITION = 0.75
player.static.BOMB_SIMULATION_DT = 1 / 60

function player:initialize(x, y)
	local w, h = player.WIDTH, player.HEIGHT
	super.initialize(self, x - w / 2, y - h / 2, w, h)
	self.input = {
		up = {'up', 'w'},
		down = {'down', 's'},
		left = {'left', 'a'},
		right = {'right', 'd'},
	}
	self.speedMax = 400
	self.onGround = false
	self.control = 1
	self.restitution = 0.8
	self.armPosition = player.DEFAULT_ARM_POSITION
	self.bombState = 'ready'
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
		local ta = self.throwAnimation
		local offset = 32 * self.armPosition
		local r = 20
		-- lg.circle('line', x - dx / dlen * offset, y - dy / dlen * offset * 0.75, r, r * math.pi * 2)
		if self.bombState ~= 'missing' then
			local bx, by = self:getBombPosition()
			util.drawBomb(bx, by, self:getBombCompletion())
			if self.bombState == 'prepared' then
				local points = self:getBombTrajectory()
				local lj = lg.getLineJoin()
				lg.setLineJoin('none')
				lg.setLineStyle 'rough'
				lg.setLineWidth(4)
				-- lg.line(points)
				local r, g, b = lg.getColor()
				local pointCount = #points / 2
				
				if pointCount > 1 then
					local x1, y1 = points[1], points[2]
					for i = 1, pointCount - 1 do
						local x2, y2 = points[i * 2 + 1], points[i * 2 + 2], points[i * 2 + 3], points[i * 2 + 4]
						lg.setColor(r, g, b, 1 - i / (pointCount - 1))
						lg.line(x1, y1, x2, y2)
						x1, y1 = x2, y2
					end
				end
				lg.setColor(r, g, b, 1)
				-- local r = lg.getLineWidth() / 2
				-- for i = 0, #points / 2 - 1 do
				-- 	lg.circle('fill', points[i * 2 + 1], points[i * 2 + 2], r, math.ceil(r * util.tau))
				-- end
				lg.setLineJoin(lj)
			end
		end
	end
	if cli.debug then
		local w, h = 100, 8
		local x, y = self.x + self.w / 2, self.y + self.h + 10
		lg.rectangle('line', x - w / 2, y, w, h)
		lg.rectangle('fill', x - w / 2, y, w * self.control, h)
	end
end

function player:getAimPolar()
	local camera = util.getCamera()
	local mx, my = camera:worldCoords(lm.getPosition())
	local px, py = util.getBombOrigin()
	local dx, dy = vector.sub(mx, my, px, py)
	return vector.toPolar(dx, dy)
end

function player:getAimVelocity()
	local angle, len = self:getAimPolar()
	return vector.fromPolar(angle, len ^ 0.5 * 50 + 50)
end

local bomb = require 'entity.bomb'
function player:getBombTrajectory()
	local world = util.getWorld()
	local b = bomb:new(util.getBombOrigin())
	b.vx, b.vy = self:getAimVelocity()
	local points = {b:getCenter()}
	local dt = player.BOMB_SIMULATION_DT
	local simulationSteps = math.ceil((b.timeMax - self:getBombCompletion() * b.timeMax) / dt)
	
	-- Disgusting hack
	world.bump:add(b, b.x, b.y, b.w, b.h)
	for i = 1, simulationSteps do
		world.bumpSystem:process(b, dt)
		world.gravitySystem:process(b, dt)
		world.physicsSystem:process(b, dt)
		lume.push(points, b:getCenter())
	end
	world.bump:remove(b)
	return points
end

function player:getBombCompletion()
	return self.bombTimer and self.bombTimer.value or 0
end

function player:getBombPosition()
	local x, y = self.x + self.w / 2, self.y + self.h / 2
	local mx, my = util.getCamera():worldCoords(lm.getPosition())
	local dx, dy = vector.sub(mx, my, x, y)
	local dlen = vector.len(dx, dy)
	local ta = self.throwAnimation
	local offset = 32 * self.armPosition
	local r = 20
	return x - dx / dlen * offset, y - dy / dlen * offset * 0.75
end

function player:throwBombPrepare()
	if self.bombState == 'ready' then
		self.bombState = 'prepared'
		util.getTweener():to(self, 0.2, {armPosition = 1.5}):ease('quadinout')
		self.bombTimer = {value = 0}
		self.bombTimerTween = util.getTweener():to(self.bombTimer, bomb.TIME_MAX, {value = 1}):ease('linear'):oncomplete(function()
			local b = bomb:new(self:getBombPosition())
			b.time = b.timeMax
			util.getWorld():addEntity(b)
			self.bombState = 'missing'
			util.getTweener():to({}, 0.2, {}):oncomplete(function() -- duplicate code
				self.bombTimer = nil
				self.armPosition = player.DEFAULT_ARM_POSITION
				self.bombState = 'ready'
			end)
		end)
	end
end

function player:throwBomb(mx, my)
	if self.bombTimerTween then
		self.bombTimerTween:stop()
		self.bombTimerTween = nil
	end
	if self.bombState == 'prepared' then
		self.bombState = 'throwing'
		util.getTweener():to(self, 0.1, {armPosition = 0}):ease('quadin'):oncomplete(function()
			self.bombState = 'missing'
			
			local b = require 'entity.bomb':new(util.getBombOrigin())
			b.vx, b.vy = self:getAimVelocity()
			b.time = self:getBombCompletion() * b.timeMax
			
			util.getWorld():addEntity(b)
		end):after(0.2, {}):oncomplete(function() -- duplicate code
			self.bombTimer = nil
			self.armPosition = player.DEFAULT_ARM_POSITION
			self.bombState = 'ready'
		end)
	end
end

function player:getRestitution()
	return self.restitution * util.clamp(util.remap(self.control ^ 2, 0, 1, 1, -0.1), 0, 1)
end

return player