local lm = require 'love.mouse'
local lg = require 'love.graphics'
local function getCameraTargetPosition(self)
	local p = self.world.player
	local x, y = p:getCenter()
	if p.falling then
		x, y = p.lastX, p.lastY
	end
	local w, h = lg.getDimensions()
	local mindim = math.min(w, h)
	local mx, my = lm.getPosition()
	local ox, oy = (mx - w / 2) / (mindim / 2), (my - h / 2) / (mindim / 2)
	local refdim = properties.window.referenceDimension / 2
	return x + refdim / 2 * ox, y + refdim / 2 * oy
end

local function update(self, dt)
	local camera = self.world.camera
	local tx, ty = getCameraTargetPosition(self)
	local smoothing = 0.1
	camera.x = util.damp(camera.x, tx, smoothing, dt)
	camera.y = util.damp(camera.y, ty, smoothing, dt)
	local w, h = lg.getDimensions()
	local mindim = math.min(w, h)
	local mx, my = lm.getPosition()
	mx, my = mx - w / 2, my - h / 2
	local p = self.world.player
	local zoomFactor = util.clamp(vector.len(mx, my) / (mindim / 2), 0, 1) + vector.len(p.vx, p.vy) ^ 0.5 / 20
	zoomFactor = util.remap(zoomFactor, 0, 1, 1.0, 0.8)
	camera.zoomFactor = util.damp(camera.zoomFactor or 1, zoomFactor, 0.5, dt)
	camera.scale = mindim / properties.window.referenceDimension * camera.zoomFactor
end

return function()
	local system = tiny.processingSystem()
	
	system.update = update
	
	return system
end