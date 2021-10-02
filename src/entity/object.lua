local object = class 'Object'

function object:initialize(x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

return object