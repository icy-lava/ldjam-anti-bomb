local util = {}

-- Math(y)

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

function util.getCenter(e)
	return e.x + e.w / 2, e.y + e.h / 2
end

function util.getBombOrigin(scene)
	return util.getCenter(util.getPlayer(scene))
end

function util.subclassFilter(class)
	return function(s, e)
		local c = e.class
		return c == class or (c.isSubclassOf and c:isSubclassOf(class))
	end
end

return util