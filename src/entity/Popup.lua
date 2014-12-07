local class = require 'middleclass'

local Popup = class('IEntity')

function Popup:initialize(text, entity, duration, width, next, fct, x, y, bool)
	self.text = text;
	self.entity = entity;
	self.duration = duration;
	self.width = width
	self.next = next;
	self.time = 0
	self.fct = fct
	self.activeCloud = bool

	if x == nil then
		x = 0
	end
	if y == nil then
		y = 0
	end

	self.decalage = {}
	self.decalage.y = y
	self.decalage.x = x

	self.pos = {}
	self.pos.x = self.entity.pos.x - self.width / 2
	if self.pos.x + self.width > WINDOW_WIDTH then
		self.pos.x = WINDOW_WIDTH - self.width
	elseif self.pos.x < 0 then
		self.pos.x = 0
	end

	self.pos.y = self.entity.pos.y - 20* (math.ceil(self.text:len()*8/self.width) - 1) - 20
	
end

function Popup:update(dt)
	self.time = self.time + dt
	if self.time > self.duration then
		engine.screen:removeEntityPassiv(self.id)
	end

	self.pos.x = self.entity.pos.x - self.width / 2
	if self.pos.x + self.width > WINDOW_WIDTH then
		self.pos.x = WINDOW_WIDTH - self.width
	elseif self.pos.x < 0 then
		self.pos.x = 0
	end

	self.pos.y = self.entity.pos.y - 20* (math.ceil(self.text:len()*8/self.width) - 1) - 20
end

function Popup:draw()
	love.graphics.setColor(0,0,0,155)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.width, 20 * math.ceil(self.text:len()*8/self.width))
	love.graphics.setColor(222,222,222)
	love.graphics.printf(self.text, self.pos.x, self.pos.y+2, self.width, "center")
	love.graphics.setColor(255,255,255)
end

function Popup:onQuit()
	if self.next ~= nil then
		engine.screen:addEntityPassiv(self.next)
	else
		self.entity.canMove = true
	end

	if self.fct ~= nil then
		self.entity.pos.x = self.entity.pos.x + self.fct.x * engine.TILESIZE
		self.entity.pos.y = self.entity.pos.y + self.fct.y * engine.TILESIZE
		self.entity.image.current = self.entity.image.down
	end

	if self.activeCloud ~= nil and self.activeCloud then
		engine.screen.player.hasBuiltTheSnowman = true
	end
end

return Popup