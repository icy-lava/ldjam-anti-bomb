local vivid = require 'vivid'
properties = {
	window = {
		referenceDimension = 720,
		defaultAspectRatio = '16:9'
	},
	palette = {
		background = {vivid.LCHtoRGB(90, 20, 300, 1)},
		outline = {vivid.LCHtoRGB(12, 50, 60, 1)},
		wire = {vivid.LCHtoRGB(12, 50, 240, 1)},
		solid = {vivid.LCHtoRGB(60, 30, 300, 1)},
		toggled = {vivid.LCHtoRGB(60, 30, 0, 1)},
		player = {vivid.LCHtoRGB(60, 50, 30, 1)},
		bomb = {vivid.LCHtoRGB(40, 90, 0, 1)},
		switch = {vivid.LCHtoRGB(60, 30, 0, 1)},
		switchOn = {vivid.LCHtoRGB(85, 30, 0, 1)},
		backgroundExplosion = {vivid.LCHtoRGB(0, 0, 0, 1)},
		outlineExplosion = {1, 0, 0, 1},
	},
	audio = {
		volume = {
			explode = 0.4,
			feedback = 0.05,
			land1 = 0.05,
			land2 = 0.05,
			land3 = 0.05,
			clock = 0.08,
			buildup = 0.05,
			bomb_bounce = 0.2,
		},
		looping = {
			clock = true
		}
	}
}

local aspectW, aspectH = properties.window.defaultAspectRatio:match('%s*(%d+)%s*:%s*(%d+)%s*')
aspectW, aspectH = assert(tonumber(aspectW)), assert(tonumber(aspectH))
if aspectW < aspectH then
	properties.window.virtualWidth  = properties.window.referenceDimension
	properties.window.virtualHeight = properties.window.referenceDimension * aspectH / aspectW
else
	properties.window.virtualWidth  = properties.window.referenceDimension * aspectW / aspectH
	properties.window.virtualHeight = properties.window.referenceDimension
end