local lg = require 'love.graphics'
local switch = require 'entity.block' :subclass 'SwitchBlock'
local super = switch.super

function switch:initialize(...)
	super.initialize(self, ...)
	self.enabled = false
	self.toggles = {}
end

local function draw(self, fill)
	local lw = lg.getLineWidth()
	lg.setLineWidth(4)
	if fill then
		lg.setColor(self.enabled and properties.palette.switchOn or properties.palette.switch)
		lg.rectangle('fill', self.x, self.y, self.w, self.h, 3)
		lg.setColor(self.enabled and properties.palette.outlineExplosion or properties.palette.outline)
	end
	lg.rectangle('line', self.x, self.y, self.w, self.h, 3)
	lg.setLineWidth(lw)
	local cx, cy = self:getCenter()
	local r = math.min(self.w, self.h) / 2 - 12
	lg.arc('line', 'open', cx, cy, r, math.pi * -0.25, math.pi * 1.25, r * util.tau)
	lg.line(cx, cy + 4, cx, cy - r - 4)
end

function switch:draw()
	lg.setColor(self.enabled and properties.palette.outlineExplosion or properties.palette.outline)
	draw(self, true)
end

function switch:drawExploded()
	lg.setColor(properties.palette.outlineExplosion)
	draw(self, false)
end

function switch:trigger()
	self.enabled = not self.enabled
	for _, t in ipairs(self.toggles) do
		t.solid = not t.solid
	end
end

return switch