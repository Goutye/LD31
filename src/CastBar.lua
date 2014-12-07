local class = require 'middleclass'

local CastBar = class('CastBar')

function CastBar:initialize(maxTime, entity, text, type)
	self.maxTimeReal = maxTime
	self.maxTime = maxTime
	self.text = text
	self.w = text:len()*11 + 10
	self.h = 18
	self.type = type
	self.pos = engine:vector_copy(entity.pos)
	self.pos.y = self.pos.y - 20
	self.pos.x = self.pos.x + entity.w/2 - self.w / 2
	self.idEntity = entity.id
	self.time = 0
end

function CastBar:update(dt)
	self.time = self.time + dt
	if self.time > self.maxTime then
		self.time = 0
		if self.text ~= "" then
			engine.music.sfx.cast:play()
		end
		return true
	end
	return false
end

function CastBar:reset()
	self.time = 0
end

function CastBar:selectColor()
	if self.type == nil then
		return 0,0,0
	elseif self.type == 'canBeInterrupt' then
		return 150,150,20
	elseif self.type == 'peace' then
		return 0,150,20
	elseif self.type == 'attack' then
		return 150,20,20
	end
end

function CastBar:draw()
	love.graphics.setColor(150,150,150,100)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
	love.graphics.setColor(self:selectColor())
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w * self.time/self.maxTimeReal, self.h)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)
	love.graphics.setColor(245,245,245)
	engine:printOutLine(self.text, self.pos.x+5, self.pos.y+10)
	engine:printOutLine(round(self.maxTime - self.time, 1), self.pos.x+ self.w - 30, self.pos.y+10)
end

function CastBar:onQuit()
end

return CastBar