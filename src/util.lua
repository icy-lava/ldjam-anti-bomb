local util = {}

-- Math(y)

util.tau = math.pi * 2

function util.lerp(t, a, b)
	return a * (1 - t) + b * t
end

local lerp = util.lerp
function util.damp(a, b, smoothing, dt)
	return lerp(1 - smoothing ^ dt, a, b)
end

function util.sign(x)
	if x == 0 then return 0 end
	if x < 0 then return -1 end
	return 1
end

function util.remap(x, fromMin, fromMax, toMin, toMax)
	return (x - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin
end

function util.clamp(x, min, max)
	if x < min then return min end
	if x > max then return max end
	return x
end

function util.index(t, ...)
	for i = 1, select('#', ...) do
		if type(t) ~= 'table' then return nil end
		t = t[select(i, ...)]
	end
	return t
end

-- End Math(y)

function util.bumpFilter(s, e)
	return s.world.bump:hasItem(e)
end

function util.getScene()
	return scene._scenes[#scene._scenes]
end

function util.getWorld(scene)
	return (scene or util.getScene()).world
end

function util.getPlayer(scene)
	return util.getWorld(scene).player
end

function util.getCamera(scene)
	return util.getWorld(scene).camera
end

function util.getTweener(scene)
	return util.getWorld(scene).tweenSystem.tween
end

function util.getCenter(e)
	return e.x + e.w / 2, e.y + e.h / 2
end

function util.getBombOrigin(scene)
	return util.getCenter(util.getPlayer(scene))
end

function util.isSubclass(class, other)
	if class == other then return true end
	other:isSubclassOf(class)
end

function util.subclassFilter(class)
	return function(s, e)
		local c = e.class
		return c == class or (c.isSubclassOf and c:isSubclassOf(class))
	end
end

local lg = require 'love.graphics'
local bomb = require 'entity.bomb'
function util.drawBomb(x, y, time, fill)
	local lw = lg.getLineWidth()
	lg.setLineWidth(4)
	
	local r = vector.len(bomb.WIDTH / 2, bomb.HEIGHT / 2)
	lg.push()
	lg.translate(x, y)
	if fill then
		local c = {lg.getColor()}
		lg.setColor(properties.palette.bomb)
		lg.circle('fill', 0, 0, r, r * math.pi * 2)
		lg.setColor(c)
	end
	lg.circle('line', 0, 0, r, r * math.pi * 2)
	
	local dashCount = 10
	for i = 0, math.ceil(dashCount * (1 - time)) - 1 do
		local angle = i / dashCount * util.tau - math.pi / 2
		local nx, ny = math.cos(angle), math.sin(angle)
		lg.line(nx * r / 2.5, ny * r / 2.5, nx * r * 3 / 4, ny * r * 3 / 4)
	end
	lg.pop()
	lg.setLineWidth(lw)
end

function util.drawIndicator(points, radius)
	radius = radius or require 'entity.indicator'.DEFAULT_RADIUS
	local lj = lg.getLineJoin()
	lg.setLineJoin('none')
	lg.setLineStyle('rough')
	lg.setLineWidth(4)
	local r, g, b, a = lg.getColor()
	local pointCount = #points / 2
	
	if pointCount > 1 then
		local x1, y1 = points[1], points[2]
		for i = 1, pointCount - 1 do
			local x2, y2 = points[i * 2 + 1], points[i * 2 + 2]
			lg.setColor(r, g, b, (1 - i / (pointCount - 1)) * a)
			lg.line(x1, y1, x2, y2)
			x1, y1 = x2, y2
		end
	end
	lg.setColor(r, g, b, 0.2 * a)
	if pointCount > 0 then
		lg.circle('line', points[pointCount * 2 - 1], points[pointCount * 2], radius)
	end
	lg.setColor(r, g, b, a)
	lg.setLineJoin(lj)
end

function util.addSystem(world, systemName, ...)
	local label = systemName:gsub('_(.)', string.upper) .. 'System'
	world[label] = require('system.' .. systemName)(...)
	world:addSystem(world[label])
	return world[label]
end

function util.playSound(sound)
	if type(sound) == 'string' then sound = asset.audio[sound] end
	sound:stop()
	sound:play()
end

local timerFormat = '%02d:%05.2f'
function util.getTimerString(time)
	time = time or (love.timer.getTime() - startTime)
	return timerFormat:format(math.floor(time / 60), time % 60)
end

return util