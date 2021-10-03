local filter = tiny.requireAll(util.subclassFilter(require 'entity.bomb'))

local dynamic = require 'entity.dynamic'
local function process(self, e, dt)
	e.time = e.time + dt
	if e.time >= e.timeMax then
		local w = self.world
		w:removeEntity(e)
		-- print(e.sound)
		if e.sound then e.sound:stop() end
		
		local bx, by = e:getCenter()
		local exp = require 'entity.explosion':new(bx, by, e.bad and 250 or 350)
		w:addEntity(exp)
		util.getTweener():to(exp, 0.09 * 1, {}):oncomplete(function()
			w:removeEntity(exp)
		end):ease('quartout')
		local items, len = w.bump:getItems()
		for j = 1, len do
			local i = items[j]
			local ix, iy = i:getCenter()
			if i.class and i.class:isSubclassOf(dynamic) then
				local dx, dy = vector.sub(ix, iy, bx, by)
				local dlen2 = vector.len2(dx, dy)
				local dlen = math.sqrt(dlen2)
				local force = 9e2 / (1 + dlen2 / 25000)
				local dvx, dvy = dx / dlen * force, dy / dlen * force
				i.vx, i.vy = i.vx + dvx, i.vy + dvy
				if i == w.player then
					local remap = util.clamp(util.remap(dlen, 50, 300, 0, 1), 0, 1)
					i.control = math.min(i.control, remap)
					if e.bad then
						i.vx, i.vy = i.vx * 0.2, i.vy * 0.2
					end
				end
			end
			if not e.bad and i.trigger and vector.dist(bx, by, ix, iy) < 350 then
				i:trigger()
			end
		end
		
		local cam = util.getCamera()
		cam.shake = 0.8
		util.getTweener():to(cam, 0.3, {shake = 0}):ease('quadin')
		
		asset.audio.explode:stop()
		asset.audio.explode:setPitch(2 ^ ((love.math.random() * 2 - 1) * 0.1))
		asset.audio.explode:play()
		asset.audio.feedback:stop()
		asset.audio.feedback:play()
	end
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end