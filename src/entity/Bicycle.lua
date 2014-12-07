local class = require 'middleclass'

local IEntity = require 'entity.IEntity'
local Popup = require 'entity.Popup'
local Statue = require 'entity.Statue'

local Bicycle = class('Bicycle', IEntity)

function Bicycle:initialize()
	self.entity = nil
	self.pos = {}
	self.pos.x = engine.TILESIZE * 2
	self.pos.y = engine.TILESIZE * 5
	self.type = "bicycle"

	self.image = {}
	self.image.up = love.graphics.newImage("assets/sprites/bicycleu.png")
	self.image.down = love.graphics.newImage("assets/sprites/bicycled.png")
	self.image.out = love.graphics.newImage("assets/sprites/bicycleo.png")

	self.w = self.image.up:getWidth()
	self.h = self.image.up:getHeight()

	self.current = self.image.up
	self.isRidden = false

	self.ball = 0
	self.gain = 1
end

function Bicycle:setPos()
	self.pos.y = engine.TILESIZE * 5
	self.pos.x = engine.TILESIZE * 23
	self.current = self.image.out
end

function Bicycle:update(dt)
	if self.isRidden then
		tile.x = math.floor((self.pos.x + self.w/2) / engine.TILESIZE)
		tile.y = math.floor((self.pos.y - engine.TILESIZE + self.w/2) / engine.TILESIZE)
		coeff = IEntity.SPEED

		if tile.y < 0 or self.pos.x > WINDOW_WIDTH / 2 or engine.screen.map[1].tileset:getInfo(1, engine.screen.map[1].map[tile.x][tile.y]) == 2 then
			if self.pos.x < WINDOW_WIDTH / 2 then
				coeff = coeff * 2
			else
				coeff = coeff * 3
			end
		end

		if self.pos.x < WINDOW_WIDTH/2 then
			self.pos.y = self.pos.y - dt * coeff * (1 - IEntity.FRICTION)
			if self.pos.y < 0 - engine.TILESIZE then
				self.pos.x = engine.TILESIZE * 23
				self.current = self.image.down
				self.entity.image.current = self.entity.image.down
				engine.screen.map[1]:areaFadeOut(1)
				engine.screen.map[1]:areaFadeIn(2)
				engine.screen:addEntity(Statue:new())
			end

			self.entity.pos.x = self.pos.x
			self.entity.pos.y = self.pos.y + 20
		elseif self.pos.y < engine.TILESIZE * 5 then
			self.pos.y = self.pos.y + dt * coeff * (1 - IEntity.FRICTION)
			self.entity.pos.x = self.pos.x
			self.entity.pos.y = self.pos.y
		else
			self.isRidden = false
			self.current = self.image.out
			self.entity.image.current = self.entity.image.left --FALL POSITION
			engine.screen:addEntityPassiv(Popup:new("*cling*", self.entity, 1, 100, 
				Popup:new("I think some company is overdue", self.entity, 3, 200,
					Popup:new("I've started talking to the pictures on the walls", self.entity, 3, 200, nil, {x = -1, y = 0}))))
			self.entity.pos.y = self.pos.y + self.h
			return
		end

		self.ball = self.ball + self.gain
		if self.ball >= 0 then
			self.gain = self.gain + 0.5
		else
			self.gain = self.gain - 0.5
		end
		

		if keyboard:isDown("left") or keyboard:isDown("q") then
			self.gain = self.gain - 2
		elseif keyboard:isDown("right") or keyboard:isDown("d") then
			self.gain = self.gain + 2
		end

		if math.abs(self.ball) > 5000 then
			self.isRidden = false
			self.entity.image.current = self.entity.image.right --DEATH POSITION
			engine.screen:addEntityPassiv(Popup:new("*YOU DIED*", self.entity, 10, 100))
			engine.screen.player.isDeath = true
			engine.screen.player.isDeadByRide = true
		end
	end
end

function Bicycle:ride(e)
	self.entity = e
	self.isRidden = true
	e.image.current = e.image.up
	e.canMove = false
end


function Bicycle:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.current, self.pos.x, self.pos.y)
	if self.isRidden then
		love.graphics.line(self.pos.x - 50, self.pos.y + 50, self.pos.x + 50, self.pos.y +50)
		love.graphics.circle("fill", self.pos.x + 50 * self.ball / 5000, self.pos.y + 50, 5, 20)
	end
end

function Bicycle:onQuit()
end

function Bicycle:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.w, h = self.h}
	return box
end

return Bicycle