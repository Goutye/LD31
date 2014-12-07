local class = require 'middleclass'

local Bar = class('Bar')

function Bar:initialize(max, color, x, y, w, h)
	self.max = max
	self.current = 0
	self.color = color
	self.box = {x = x, y = y, w = w, h = h}
end

function Bar:update(current)
	self.current = current
end

function Bar:draw()
	love.graphics.setColor(150,150,150,100)
	love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.w, self.box.h)
	love.graphics.setColor(self.color[1], self.color[2], self.color[3])
	love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.w * self.current/self.max, self.box.h)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h)
	love.graphics.setColor(245,245,245)
	text = math.floor(self.current) .. "/" .. self.max
	engine:printOutLine(text, self.box.x + self.box.w/2 - text:len()/2*10, self.box.y+10)
end

function Bar:onQuit()
end

return Bar