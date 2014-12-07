local class = require 'middleclass'
local IEntity = require 'entity.IEntity'

local Statue = class('Statue', IEntity)

function Statue:initialize()
	self.type = ""
	self.id = nil
	self.pos = {}
	self.pos.x = engine.TILESIZE * 23
	self.pos.y = engine.TILESIZE * 7
	self.image = love.graphics.newImage("assets/sprites/statue.png")
	self.w = self.image:getWidth()
	self.h = self.image:getHeight()

	self.friendly = false
	self.exp = 1
	self.life = 1
	self.lvl = 1
end

function Statue:update(dt)
end

function Statue:draw()
	love.graphics.draw(self.image, self.pos.x, self.pos.y)
end

function Statue:onQuit()
end

function Statue:tryMove()
end

function Statue:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.w, h = self.h}
	return box
end

Statue.static.SPEED = 200
Statue.static.FRICTION = 0.8
return Statue