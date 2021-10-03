local lg = require 'love.graphics'
local block = require 'entity.block' :subclass 'ToggledBlock'
local super = block.super

local function drawSolid(self, fill)
	local lw = lg.getLineWidth()
	lg.setLineWidth(4)
	
	if fill then
		lg.setColor(properties.palette.toggled)
		lg.rectangle('fill', self.x, self.y, self.w, self.h, 3)
		lg.setColor(properties.palette.outline)
	end
	lg.rectangle('line', self.x, self.y, self.w, self.h, 3)
	
	local x1, y1, x2, y2 = self.x, self.y, self.x + self.w, self.y + self.h
	local offset = 16
	local dx, dy = vector.sub(x2, y2, x1, y1)
	local px, py = vector.project(dx, dy, vector.normalize(1, -1))
	px, py = x2 - px, y2 - py
	local lineCount = math.floor(vector.dist(x1, y1, px, py) / offset + 0.5)
	for i = 1, lineCount - 1 do
		local lerp = i / lineCount
		local x, y = util.lerp(lerp, x1, px), util.lerp(lerp, y1, py)
		local off1 = math.min(x - x1, y2 - y)
		local px1, py1 = x - off1, y + off1
		local off2 = math.min(x2 - x, y - y1)
		local px2, py2 = x + off2, y - off2
		lg.line(px1, py1, px2, py2)
	end
	lg.setLineWidth(lw)
end

local function drawFree(self)
	require 'entity.object'.draw(self)
end

function block:draw()
	lg.setColor(properties.palette.outline);
	(self.solid and drawSolid or drawFree)(self, true)
end

function block:drawExploded()
	lg.setColor(properties.palette.outlineExplosion);
	(self.solid and drawSolid or drawFree)(self, false)
end

return block