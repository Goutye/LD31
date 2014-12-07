local class = require 'middleclass'

local IEntity = class('IEntity')

function IEntity:initialize()
	self.id = nil
	self.type = nil
	self.pos = {}
	self.pos.x = 0
	self.pos.y = 0
	self.w = 0
	self.h = 0

	self.friendly = false
	self.exp = 1
	self.life = 1
	self.mana = 1
	self.isDeath = false
	self.lvl = 1

	self.spd = {}
	self.spd.x = 0
	self.spd.y = 0
end

function IEntity:update(dt)
end

function IEntity:draw()
end

function IEntity:hit(damage)
	self.life = self.life - damage
	if self.life <= 0 then
		self.life = 0
		self.isDeath = true
	end
end

function IEntity:hitMana(damage)
	self.mana = self.mana - damage
	if self.mana < 0 then
		self.mana = 0
	end
end

function IEntity:onQuit()
end

function IEntity:tryMove()
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

	entiteCollide = nil

	boxP = self:getBox()
	boxP.x = boxP.x + self.spd.x
	for _,e in ipairs(engine.screen.entities) do
		if e.id ~= self.id then
			if engine:AABB_AABB(boxP, e:getBox()) then
				if entiteCollide == nil then
					entiteCollide = e
				end
				x = false
			end
		end
	end

	boxP.y = boxP.y + self.spd.y
	for _,e in ipairs(engine.screen.entities) do
		if e.id ~= self.id then
			if engine:AABB_AABB(boxP, e:getBox()) then
				if entiteCollide == nil then
					entiteCollide = e
				end
				y = false
			end
		end
	end

	return x,y,entiteCollide
end

function IEntity:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.w, h = self.h}
	return box
end

function IEntity:getCenter()
	return {x = self.pos.x + self.w / 2, y = self.pos.y + self.h / 2}
end

IEntity.static.SPEED = 200
IEntity.static.FRICTION = 0.8
return IEntity