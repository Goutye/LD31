local class = require 'middleclass'
local IEntity = require 'entity.IEntity'

local Poupee = class('Poupee', IEntity)

function Poupee:initialize()
	self.type = 'poupee'
	self.id = nil
	self.pos = {}
	self.pos.x = engine.TILESIZE * 0
	self.pos.y = engine.TILESIZE * 18
	self.image = love.graphics.newImage("assets/sprites/poupee.png")
	self.w = self.image:getWidth()
	self.h = self.image:getHeight()

	self.friendly = false
	self.exp = 1
	self.life = 1
	self.lvl = 1
end

function Poupee:update(dt)
end

function Poupee:draw()
	love.graphics.draw(self.image, self.pos.x, self.pos.y)
end

function Poupee:onQuit()
end

function Poupee:tryMove()
end

function Poupee:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.w, h = self.h}
	return box
end

return Poupee