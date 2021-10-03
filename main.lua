require 'library' ()

function love.load()
	if luaReload then luaReload.SetPrintReloadingLogs(false) end
	asset = cargo.init {
		dir = 'asset',
		processors = {
			['audio/'] = function(sound, filename)
				local name = assert(filename:match('[^/]+$')):gsub('%.[^%.]+$', '')
				local v = util.index(properties, 'audio', 'volume', name)
				if v then sound:setVolume(v) end
				if util.index(properties, 'audio', 'looping', name) then sound:setLooping(true) end
			end
		}
	}
	if cli.music then
		asset.audio.music:play()
	end
	scene = roomy.new()
	scene:hook()
	scene:enter(require 'scene.game':new())
end

function love.update(dt)
	if luaReload then luaReload.Monitor() end
end

local lk = require 'love.keyboard'
function love.keypressed(key)
	if cli.debug then
		if key == 'f5' and lk.isDown('lctrl', 'rctrl') then
			require 'love.event'.quit 'restart'
			return
		end
	end
	if (key == 'return' and lk.isDown('lalt', 'ralt')) or
		(key == 'f' and lk.isDown('lctrl', 'rctrl')) or key == 'f11' then
		love.window.setFullscreen(not love.window.getFullscreen())
		return
	end
end