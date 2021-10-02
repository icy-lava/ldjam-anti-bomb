local properties = {
	window = {
		referenceDimension = 720,
		defaultAspectRatio = '16:9'
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

return properties