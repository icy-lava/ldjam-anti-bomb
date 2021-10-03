if love then
	require 'love.timer'
	love.setDeprecationOutput(false)
end

local libs = {
	util = true,
	lume = true,
	flux = true,
	json = true,
	cargo = true,
	-- log = true,
	-- lurker = true,
	inspect = true,
	vivid = true,
	class = 'middleclass',
	-- prof = 'jprof',
	vector = 'hump.vector-light',
	camera = 'hump.camera',
	tiny = true,
	roomy = true,
	bump = true
}

return setmetatable(libs, {__call = function()
	for k,v in pairs(libs) do
		if v then
			if type(v) ~= 'string' then v = k end
			_G[k] = require(v)
		end
	end
end})