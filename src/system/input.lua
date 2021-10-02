local lk = require 'love.keyboard'
local filter = tiny.requireAll('input', 'vx', 'vy', 'speedMax')

local function process(self, e, dt)
	local ix = (lk.isDown(e.input.right) and 1 or 0) - (lk.isDown(e.input.left) and 1 or 0)
	local iy = (lk.isDown(e.input.down)  and 1 or 0) - (lk.isDown(e.input.up)   and 1 or 0)
	-- if ix ~= 0 or iy ~= 0 then
	-- 	ix, iy = vector.mul(e.speedMax, vector.normalize(ix, iy))
	-- end
	ix = ix * e.speedMax
	local still = ix == 0
	local control = util.clamp(e.control, 0, 1)
	if still then
		e.vx = util.damp(e.vx, 0, util.lerp(e.control ^ 2, 0.99, e.onGround and 0.001 or 0.5), dt)
	else
		if lume.sign(ix) ~= lume.sign(e.vx) or math.abs(ix) > math.abs(e.vx) then
			e.vx = util.damp(e.vx, ix, util.lerp(e.control ^ 2, 0.99, e.onGround and 0.0005 or 0.01), dt)
		end
	end
	if e.onGround and iy < 0 then
		e.vy = -500
	end
	-- e.vx, e.vy = util.damp(e.vx, ix, 0.001, dt), util.damp(e.vy, iy, 0.001, dt)
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end