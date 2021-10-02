local util = {}

function util.bumpFilter(s, e)
	return s.world.bump:hasItem(e)
end

function util.lerp(a, b, t)
	return a * (1 - t) + b * t
end

local lerp = util.lerp
function util.damp(a, b, smoothing, dt)
	return lerp(a, b, 1 - smoothing ^ dt)
end

function util.getScene()
	return scene._scenes[#scene._scenes]
end

return util