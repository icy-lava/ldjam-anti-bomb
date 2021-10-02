local lume = require 'lume'
local parser = require 'argparse' ()

local mutex = function(t)
	parser:mutex(unpack(t))
	return t
end

local group = function(name, ...)
	local options = {}
	for i = 1, select('#', ...) do
		lume.push(options, unpack((select(i, ...))))
	end
	return parser:group(name, unpack(options))
end

parser:help_max_width(120)
parser:help_description_margin(30)

parser:add_help('--help -?')

local windows = jit.os == 'Windows'

local fs = parser:flag('--fullscreen -f', 'Start in fullscreen mode')
local nfs = parser:flag('--no-fullscreen', 'Start in windowed mode'):target("fullscreen"):action("store_false")
parser:mutex(fs, nfs)

group(
	'Game options',
	mutex {
		parser:flag('--music', 'Play the game music (default)'),
		parser:flag('--no-music', 'Don\'t play the game music'):target("music"):action("store_false"):default(true)
	}
)

group(
	'Window options',
	mutex {
		fs,
		nfs
	},
	mutex {
		parser:flag('--vsync', 'Use vsync'),
		parser:flag('--no-vsync', 'Don\'t use vsync (default)'):target("vsync"):action("store_false"),
	},
	mutex {
		parser:flag('--borderless', 'Start in a borderless window'),
		parser:flag('--no-borderless', 'Don\'t start in a borderless window (default)'):target("borderless"):action("store_false"),
	},
	{
		parser:option('--width -w', 'Set startup window width'):convert(tonumber),
		parser:option('--height -h', 'Set startup window height'):convert(tonumber)
	}
)

group(
	'Developer options',
	mutex {
		parser:flag('--color', 'Use colored output in the console window' .. (windows and '' or ' (Default)')),
		parser:flag('--no-color', 'Don\'t use colored output in the console window' .. (windows and ' (Default)' or '')):target("color"):action("store_false"),
	},
	{
		parser:flag('--debug -d'):description('Turn on debug mode' .. (windows and ' (implies --show-console)' or '')),
		parser:flag('--show-console'):description('Show a console window (ignored on non-Windows OSs)'):hidden(not windows),
		parser:flag('--dump-cli-args --cli'):description('Dump CLI arguments as a lua table and exit')
	}
)

local args = love.arg.parseGameArguments(arg)
for i = 1, #args do
	if args[i]:lower() == '-debug' then
		args[i] = '--debug'
	end
end

do
	local status, result = parser:pparse(args)
	if not status then
		io.stderr:write(string.format('argparse error: %s\nfalling back to defaults...\n', result))
		cli = parser:parse {}
	else cli = result end
end

cli.color = (cli.color == nil) and (not windows) or cli.color

cli.fullscreen = cli.fullscreen or not cli.debug and cli.fullscreen == nil

local virtualW, virtualH = properties.window.virtualWidth, properties.window.virtualHeight
cli.height = cli.height or math.floor(cli.width and (cli.width * virtualH / virtualW) or virtualH)
cli.width = cli.width or math.floor(cli.height * virtualW / virtualH)

if cli.dump_cli_args then
	print(inspect(cli))
	os.exit(0)
end

if cli.debug then
	local result, mobdebug = pcall(require, 'mobdebug')
	if result then mobdebug.start() end
end