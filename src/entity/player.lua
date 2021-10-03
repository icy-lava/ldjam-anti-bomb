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
	self.speedMax = 500
	self.onGround = false
	self.control = 1
	self.restitution = 0.8
	self.armPosition = player.DEFAULT_ARM_POSITION
	self.bombState = 'ready'
end

local lm = require 'love.mouse'
local lg = require 'love.graphics'
function player:draw()
	-- super.draw(self)
	lg.setColor(properties.palette.outline)
	
	do -- Body
		local w, h = player.WIDTH - 16, player.HEIGHT - 50
		local x, y = self:getCenter()
		lg.setColor(properties.palette.player)
		lg.rectangle('fill', x - w / 2, self.y + player.HEIGHT - h, w, h, 2)
		lg.setLineWidth(4)
		lg.setColor(properties.palette.outline)
		lg.rectangle('line', x - w / 2, self.y + player.HEIGHT - h, w, h, 2)
	end
	
	
	do -- Head
		local w, h = player.WIDTH, 44
		local x, y = self:getCenter()
		lg.setColor(properties.palette.player)
		lg.rectangle('fill', x - w / 2, self.y, w, h, 2)
		lg.setLineWidth(4)
		lg.setColor(properties.palette.outline)
		lg.rectangle('line', x - w / 2, self.y, w, h, 2)
		do -- Eyes
			local eyeRelationalHeight = 0.3
			local eyeR = 6
			local mx, my = util.getCamera():worldCoords(lm.getPosition())
			local dx, dy = vector.sub(mx, my, x, self.y + h * eyeRelationalHeight)
			local dlen = vector.len(dx, dy)
			local offset = math.sqrt(util.clamp(util.remap(dlen, 0, 500, 0.1, 1), 0.1, 1)) * 12
			local eyeGap = 30 - offset * 0.5
			dx, dy = dx / dlen * offset, dy / dlen * offset * 0.5
			lg.circle('fill', x - eyeGap / 2 + dx, self.y + h * eyeRelationalHeight + dy, eyeR, math.ceil(eyeR * util.tau))
			lg.circle('fill', x + eyeGap / 2 + dx, self.y + h * eyeRelationalHeight + dy, eyeR, math.ceil(eyeR * util.tau))
		end
	end
	
	do -- Bomb and trajectory
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
				lg.setColor(properties.palette.outline)
				util.drawIndicator(self:getBombTrajectory())
			end
		end
	end
	if cli.debug then -- Debug control gauge
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
			
			local points = self:getBombTrajectory()
			local indicator = require 'entity.indicator':new(points)
			util.getTweener():to(indicator, math.min(1, b.timeMax - b.time), {alpha = 0, r = indicator.r * 0.5}):ease('quadinout'):oncomplete(function()
				util.getWorld():removeEntity(indicator)
			end)
			util.getWorld():addEntity(indicator)
			
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