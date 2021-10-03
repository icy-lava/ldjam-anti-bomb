std = '+love'
ignore = {'6[13]1', '212'}
globals = {
	'love.arg',
	'cli',
	'luaReload',
	'properties',
	'log',
	'asset',
	'scene',
}

require 'path'
for k, v in pairs(require 'library') do
	if v then
		table.insert(globals, type(v) == 'string' and v or k)
	end
end
