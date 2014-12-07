local Mouse = {
	pressed = {},
	released = {},
	down = {},
	posPressed = {},
	posReleased = {},
}
Mouse.__index = Mouse

function Mouse.new()
	local self = setmetatable({}, Mouse)

	self.last = ""

	return self
end

function Mouse:whatButtonIsPressed()
	return self.last
end

function Mouse:buttonPressed(x, y, btn)
	self.pressed[btn] = true
	self.down[btn] = true
	self.last = btn
	self.posPressed[btn] = {x,y}
end

function Mouse:buttonReleased(x, y, btn)
	self.released[btn] = true
	self.down[btn] = false

	if self.last == btn then
		self.last = ""
	end

	self.posReleased[btn] = {x,y}
end

function Mouse:isPressed(btn)
	return self.pressed[btn] or false
end

function Mouse:isDown(btn)
	return self.down[btn] or false
end

function Mouse:isReleased(btn)
	return self.released[btn] or false
end

function Mouse:wherePressed(btn)
	return self.posPressed[btn][1],self.posPressed[btn][2]
end

function Mouse:whereReleased(btn)
	return self.posReleased[btn][1],self.posReleased[btn][2]
end

function Mouse:reset()
	for btn, value in pairs(self.pressed) do
		self.pressed[btn] = false
	end
	for btn, value in pairs(self.released) do
		self.released[btn] = false
	end
	for btn, value in pairs(self.posReleased) do
		self.posReleased = {}
	end
	for btn, value in pairs(self.posPressed) do
		self.posPressed = {}
	end
	self.last = ""
end

return Mouse