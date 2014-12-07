local class = require 'middleclass'

local IEntity = require 'entity.IEntity'

local Cloud = class('Cloud', IEntity)
local Castbar = require 'CastBar'

function Cloud:initialize()
	self.id = nil
	self.type = 'cloud'
	self.pos = {}
	self.pos.x = WINDOW_WIDTH/2
	self.pos.y = WINDOW_HEIGHT/2
	self.w = 0
	self.h = 0
	self.dir = {}
	repeat
		self.dir.x = (love.math.random() - 0.5)*2
		self.dir.y = (love.math.random() - 0.5)*2
	until not (self.dir.x == 0 and self.dir.y == 0)
	self.size = love.math.random(1,5)
	self.sizeMax = 2 * self.size

	self.spd = love.math.random(1,3) * IEntity.SPEED
	self.spdMax = 4

	self.friendly = false
	self.exp = 1
	self.life = 1
	self.lvl = 1

	self.image = {}
	self.image['cloud'] = {}
	for i = 1,3 do
		self.image['cloud'][i-1] = love.graphics.newImage("assets/sprites/cloud" .. i .. ".png")
	end
	self.current = self.image['cloud'][love.math.random(0,2)]

	self.castbar = Castbar:new(5, self, "")

	engine.music.sfx.explode:play()
end

function Cloud:update(dt)
	self.pos.x = self.pos.x + self.dir.x * self.spd * dt
	self.pos.y = self.pos.y + self.dir.y * self.spd * dt

	if self.castbar:update(dt) then
		engine.screen:removeEntityPassiv(self.id)
	end
end

function Cloud:draw()
	love.graphics.draw(self.current, self.pos.x, self.pos.y, self.size, self.size)
end

function Cloud:onQuit()
end

function Cloud:tryMove()
end

function Cloud:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.w, h = self.h}
	return box
end

Cloud.static.SPEED = 200
Cloud.static.FRICTION = 0.8
return Cloud