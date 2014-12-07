local class = require 'middleclass'
local IEntity = require 'entity.IEntity'
local Popup = require 'entity.Popup'

local Snowball = class('Snowball', IEntity)

function Snowball:initialize(x, y)
	IEntity.initialize(self)
	self.id = nil
	self.pos = {}
	self.pos.x = x
	self.pos.y = y
	self.spd = {}
	self.spd.x = 0
	self.spd.y = 0 
	self.image = love.graphics.newImage("assets/sprites/snowball.png")
	self.smile = love.graphics.newImage("assets/sprites/smile.png")
	self.w = self.image:getWidth()
	self.h = self.w
	self.sizePercent = 0.2
	self.size = self.w * self.sizePercent

	self.type = "snowball"

	self.pixelTraveled = 0
	self.pixelPerTurn = 100

	self.friendly = false
	self.exp = 1
	self.life = 1
	self.lvl = 1
	self.canMove = true
	self.showEyes = false
	self.attachedBall = nil
end

function Snowball:update(dt)
	if self.canMove then

		self.sizePercent = 0.2 + self.pixelTraveled/(self.pixelPerTurn * 10)
		self.size = self.w * self.sizePercent
		local boolx,booly = self:tryMove()
		if boolx then
			self.pos.x = self.pos.x + self.spd.x
			self.pixelTraveled = self.pixelTraveled + math.abs(self.spd.x)
		elseif booly then
			self.pos.y = self.pos.y + self.spd.y
			self.pixelTraveled = self.pixelTraveled +  math.abs(self.spd.y)
			self.spd.x = 0
		else
			self.spd.x = 0

		end
		if booly and boolx then
			self.pos.y = self.pos.y + self.spd.y
			self.pixelTraveled = self.pixelTraveled +  math.abs(self.spd.y)
		else
			self.spd.y = 0
		end
		self.spd.x = self.spd.x * IEntity.FRICTION
		self.spd.y = self.spd.y * IEntity.FRICTION
	end
end

function Snowball:onQuit()
	if self.attachedBall ~= nil then
		engine.screen:removeEntity(self.id)
	end
end

function Snowball:tryMove()
	local x,y = false, false
	local posTile = {}
	local idW = engine.screen.currentMap
	local tl = engine.screen.map[idW].tileset

	posTile.x = math.floor((self.pos.x + self.spd.x) / engine.TILESIZE)
	posTile.y = math.floor((self.pos.y)/ engine.TILESIZE)
	posTile.xm = math.floor((self.pos.x+ self.spd.x + self.size-1) / engine.TILESIZE)
	posTile.ym = math.floor((self.pos.y+  self.size-1) / engine.TILESIZE)

	if posTile.x >= 0 and posTile.xm < engine.screen.map[idW].w and
		posTile.y >= 0 and posTile.ym < engine.screen.map[idW].h then

		x= tl:getInfo(idW, engine.screen.map[idW].map[posTile.x][posTile.y]) == 0 and
			tl:getInfo(idW, engine.screen.map[idW].map[posTile.xm][posTile.y]) == 0 and
			tl:getInfo(idW, engine.screen.map[idW].map[posTile.x][posTile.ym]) == 0 and
			tl:getInfo(idW, engine.screen.map[idW].map[posTile.xm][posTile.ym]) == 0 
	end

	posTile.x = math.floor((self.pos.x + self.spd.x) / engine.TILESIZE)
	posTile.y = math.floor((self.pos.y + self.spd.y)/ engine.TILESIZE)
	posTile.xm = math.floor((self.pos.x+ self.spd.x + self.size-1) / engine.TILESIZE)
	posTile.ym = math.floor((self.pos.y + self.spd.y +  self.size-1) / engine.TILESIZE)

	if posTile.x >= 0 and posTile.xm < engine.screen.map[idW].w and
		posTile.y >= 0 and posTile.ym < engine.screen.map[idW].h then

		y= tl:getInfo(idW, engine.screen.map[idW].map[posTile.x][posTile.y]) == 0 and
			tl:getInfo(idW, engine.screen.map[idW].map[posTile.xm][posTile.y]) == 0 and
			tl:getInfo(idW, engine.screen.map[idW].map[posTile.x][posTile.ym]) == 0 and
			tl:getInfo(idW, engine.screen.map[idW].map[posTile.xm][posTile.ym]) == 0
	end

	if not x and not y then
		posTile.x = math.floor((self.pos.x) / engine.TILESIZE)
		posTile.y = math.floor((self.pos.y + self.spd.y)/ engine.TILESIZE)
		posTile.xm = math.floor((self.pos.x + self.size-1) / engine.TILESIZE)
		posTile.ym = math.floor((self.pos.y + self.spd.y +  self.size-1) / engine.TILESIZE)

		if posTile.x >= 0 and posTile.xm < engine.screen.map[idW].w and
			posTile.y >= 0 and posTile.ym < engine.screen.map[idW].h then

			y= tl:getInfo(idW, engine.screen.map[idW].map[posTile.x][posTile.y]) == 0 and
				tl:getInfo(idW, engine.screen.map[idW].map[posTile.xm][posTile.y]) == 0 and
				tl:getInfo(idW, engine.screen.map[idW].map[posTile.x][posTile.ym]) == 0 and
				tl:getInfo(idW, engine.screen.map[idW].map[posTile.xm][posTile.ym]) == 0
		end
	end
	boxP = self:getBox()
	boxP.x = boxP.x + self.spd.x
	for _,e in ipairs(engine.screen.entities) do
		if e.id ~= self.id then
			if engine:AABB_AABB(boxP, e:getBox()) then
				if e.type == "snowball" then
					if e.sizePercent > 1 and self.canMove and self.sizePercent > 1 then
						e:attach(self)
						self.canMove = false
					end
				else
					x = false
					boxP.x = boxP.x - self.spd.x
				end
			end
		end
	end

	boxP.y = boxP.y + self.spd.y
	for _,e in ipairs(engine.screen.entities) do
		if e.id ~= self.id then
			if engine:AABB_AABB(boxP, e:getBox()) then
				if e.type == "snowball" then
					if e.sizePercent > 1 and self.canMove and self.sizePercent > 1 then
						e:attach(self)
						self.canMove = false
					end
				else
					y = false
				end
			end
		end
	end

	return x,y
end

function Snowball:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.image, self.pos.x + self.size/2, self.pos.y + self.size/2, math.pi * self.pixelTraveled / self.pixelPerTurn, self.sizePercent, self.sizePercent, self.w/2, self.w/2)
	if self.showEyes then
		self:drawEyes()
		self:drawSmile()
	end
	love.graphics.setColor(255,255,255)
end

function Snowball:attach(s)
	s.pos.x = self.pos.x + (math.abs(self.size - s.size)/2)
	s.pos.y = self.pos.y - self.size/2

	self.canMove = false
	self.attachedBall = s
	s.showEyes = true

	if s.id < self.id then
		engine.screen:removeEntity(s.id)
		engine.screen:addEntity(s)
	end

	engine.screen.player.canMove = false
	engine.screen:addEntityPassiv(Popup:new("Hum... I feel... unachieved.", self, 2, 150,
		Popup:new("It's weird, really weird. WHERE IS MY NOSE?", self, 2, 250,
			Popup:new("Oh.. No matter. My dear Anna, this snow, you know nothing, nothing about it.", self, 3.5, 300,
				Popup:new("All of this was just a joke. A little big joke to allow me to come back from the dead.", self, 4, 300,
					Popup:new("YOU ARE NOT ANNA. I M NEITHER OLAF, nor a nice snowman. AND A DAY, I WILL BECOME A LUDUM DARE THEME!", self, 4, 300,
						Popup:new("Bless your soul, little dove, and sees the world... EXPLODE!", self, 2.5, 200,
							Popup:new("?!", engine.screen.player, 1, 50, nil, nil, 100, 20, true))))))))
end

function Snowball:drawEyes()
	love.graphics.setColor(50,50,50)
	love.graphics.circle("fill", self.pos.x + self.size/2 - self.size/4, self.pos.y + self.size/2 - self.size/4, self.size/10)
	love.graphics.circle("fill", self.pos.x + self.size/2 + self.size/4, self.pos.y + self.size/2 - self.size/4, self.size/10)
	love.graphics.setColor(255,255,255)
end

function Snowball:drawSmile()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.smile, self.pos.x + self.size/2, self.pos.y + self.size/2, 0, sizePercent, sizePercent, self.w/2, self.w/2)
end

function Snowball:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.size, h = self.size}
	return box
end

Snowball.static.SPEED = 200
Snowball.static.FRICTION = 0.8
return Snowball