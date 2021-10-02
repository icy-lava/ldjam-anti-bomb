local vivid = require 'vivid'
properties = {
	window = {
		referenceDimension = 720,
		defaultAspectRatio = '16:9'
	},
	palette = {
		background = {vivid.LCHtoRGB(90, 20, 300)},
		outline = {vivid.LCHtoRGB(12, 50, 60)},
		backgroundExplosion = {vivid.LCHtoRGB(0, 0, 0)},
		outlineExplosion = {1, 0, 0},
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