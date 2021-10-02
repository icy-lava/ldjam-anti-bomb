local filter = tiny.requireAll(util.subclassFilter(require 'entity.bomb'))

local dynamic = require 'entity.dynamic'
local function process(self, e, dt)
	e.time = e.time + dt
	if e.time >= e.timeMax then
		local w = self.world
		w:remove(e)
		local bx, by = e:getCenter()
		local items, len = w.bump:getItems()
		for j = 1, len do
			local i = items[j]
			if i.class and i.class:isSubclassOf(dynamic) then
				local ix, iy = i:getCenter()
				local dx, dy = vector.sub(ix, iy, bx, by)
				local dlen2 = vector.len2(dx, dy)
				local dlen = math.sqrt(dlen2)
				local force = 8e2 / (1 + dlen2 / 30000)
				local dvx, dvy = dx / dlen * force, dy / dlen * force
				i.vx, i.vy = i.vx + dvx, i.vy + dvy
				if i == w.player then
					local remap = util.clamp(util.remap(dlen, 50, 300, 0, 1), 0, 1)
					i.control = math.min(i.control, remap)
				end
			end
		end
	end
end

return function()
	local system = tiny.processingSystem()
	
	system.filter = filter
	system.process = process
	
	return system
end