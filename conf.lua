require 'path'

local propertiesFileName = 'properties.lua'
properties = loadstring(require 'love.filesystem'.read(propertiesFileName), '@' .. propertiesFileName)()

require 'cli'
log = require 'log'
log.usecolor = cli.color
if cli.debug then log.outfile = 'log.txt'
else log.level = 'fatal' end

if cli.show_console or cli.debug then require 'alloc_console' () end

function love.conf(t)
	t.identity = 'il-ldjam49'
	t.appendidentity = false
	t.version = "11.3"
	t.console = false -- we manually allocate a console when needed
	t.accelerometerjoystick = true
	t.externalstorage = false
	t.gammacorrect = false
	
	t.audio.mic = false
	t.audio.mixwithsystem = true
	
	-- t.window.title = string.format("%s%s", assert(properties.title, 'title not defined in properties.json'), cli.debug and ' - Debug Mode' or '')
	t.window.title = string.format("%s%s", t.identity, cli.debug and ' - Debug Mode' or '')
	t.window.icon = nil
	t.window.width = cli.width
	t.window.height = cli.height
	t.window.borderless = cli.borderless
	t.window.resizable = true
	t.window.minwidth = 100
	t.window.minheight = 100
	t.window.fullscreen = cli.fullscreen
	t.window.fullscreentype = "desktop"
	t.window.vsync = cli.vsync and 1 or 0
	t.window.msaa = 8
	t.window.depth = nil
	t.window.stencil = nil
	t.window.display = 1
	t.window.highdpi = false
	t.window.usedpiscale = true
	t.window.x = nil
	t.window.y = nil
	
	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = false
	t.modules.video = false
	t.modules.window = true
end
