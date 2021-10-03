local lg = require 'love.graphics'
local state = class('EndState')

function state:enter()
	self.fade = 1
	self.world = tiny.world()
	util.addSystem(self.world, 'tween')
	util.getTweener():to(self, 0.2, {}):after(0.8, {fade = 0}):ease('quadinout')
	lg.setBackgroundColor(properties.palette.background)
	self.font = asset.font['Montserrat-Regular'](48)
	self.fontTitle = asset.font['Montserrat-Regular'](96)
end

function state:update(dt)
	if dt > 0.1 then dt = 0.1 end
	self.world:update(dt, function(w, s) return not s.draw end)
end

function state:draw()
	local ww, wh = lg.getDimensions()
	local f = lg.getFont()
	
	local spacing = 64
	local textTitle = ('Congratulations'):upper()
	local ttf = self.fontTitle
	local ttw, tth = ttf:getWidth(textTitle), ttf:getHeight()
	
	local textSub = 'You\'ve completed the game!'
	local tsf = self.font
	local tsw, tsh = tsf:getWidth(textSub), tsf:getHeight()
	
	lg.setColor(properties.palette.outline)
	local y = (wh - tth - tsh - spacing) / 2
	lg.setFont(self.fontTitle)
	lg.print(textTitle, math.floor((ww - ttw) / 2), math.floor(y))
	
	y = y + tth + spacing
	
	lg.setFont(self.font)
	lg.print(textSub, math.floor((ww - tsw) / 2), math.floor(y))
	
	lg.setColor(0, 0, 0, self.fade)
	lg.rectangle('fill', 0, 0, ww, wh)
	lg.setFont(f)
end

return state