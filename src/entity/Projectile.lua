local class = require 'middleclass'

local IEntity = require 'entity.IEntity'
local Projectile = class('Projectile', IEntity)

function Projectile:initialize(idEntity, pos, dir, dmg, dmgMana, spd, r, explode, canInterrupt)
	IEntity.initialize(self)
	self.id = nil
	self.pos = {x = pos.x - r/2, y = pos.y-r/2}
	self.w = r*2
	self.h = r*2
	self.size = r*2
	self.r = r
	self.idEntity = idEntity

	self.spdInit = spd
	self.SPEED = spd * IEntity.SPEED
	self.spd = {}
	self.spd.x = 0
	self.spd.y = 0

	self.friendly = false
	self.exp = 1
	self.life = 1

	self.dir = {x = dir.x, y = dir.y}

	self.dmg = dmg
	self.dmgMana = dmgMana

	self.explode = explode
	self.canInterrupt = canInterrupt

	engine.music.sfx.projectile:play()
end

function Projectile:update(dt)
	self.spd.x = self.dir.x * self.SPEED * dt
	self.spd.y = self.dir.y * self.SPEED * dt

	local boolx,booly,e = self:tryMove()
	if not boolx or not booly then
		--EXPLODE
		if e ~= nil then
			if e.id ~= 1 or (e.id == 1 and not e.defense ) then
				if e.type == 'boss' and self.canInterrupt then
					if e.power ~= nil then
						e.power.isInterrupt = true
					end
				end
				e:hit(self.dmg)
				e:hitMana(self.dmgMana)
			elseif e.id == 1 and e.defense then
				x,y = love.mouse.getPosition()
				local dir = engine:vector_of(e.pos, {x = x, y = y})
				if not engine:isInAreaLine(e.pos, dir, self.pos) then
					e:hit(self.dmg)
					e:hitMana(self.dmgMana)
				else
					e:hit(self.dmg/e.inventaire.dist.resistance)
					e:hitMana(self.dmgMana/e.inventaire.dist.resistance)
				end
			end
		end
		engine.screen:removeEntity(self.id)
	else
		self.pos.x = self.pos.x + self.spd.x
		self.pos.y = self.pos.y + self.spd.y
	end
end

function Projectile:tryMove()
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
		if e.id ~= self.id and e.id ~= self.idEntity then
			if engine:AABB_circle(e:getBox(), self:getCircle()) then
				if entiteCollide == nil then
					entiteCollide = e
				end
				x = false
			end
		end
	end

	boxP.y = boxP.y + self.spd.y
	for _,e in ipairs(engine.screen.entities) do
		if e.id ~= self.id and e.id ~= self.idEntity then
			if engine:AABB_circle(e:getBox(), self:getCircle()) then
				if entiteCollide == nil then
					entiteCollide = e
				end
				y = false
			end
		end
	end

	return x,y,entiteCollide
end

function Projectile:draw()
	if self.idEntity == 1 then
		if self.canInterrupt then
			love.graphics.setColor(20,80,0)
		else
			love.graphics.setColor(80,20,20)
		end
	else
		love.graphics.setColor(80, 20, 0)
	end
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
	love.graphics.setColor(255,255,255)
end

function Projectile:getCircle()
	return {pos = {x= self.pos.x, y = self.pos.y}, r = self.r}
end

function Projectile:onQuit()
	if self.explode > 0 then
		self:generateParticules(math.pi*8/9,self.explode)
	end
end

function Projectile:generateParticules(angle, nb)
	local stepAngle = angle/(nb - 1)
	local dir = {}
	dir.x = -self.dir.x
	dir.y = -self.dir.y

	dir = engine:vector_rotate(dir, -angle/2)
	local pos = engine:vector_copy(self.pos)
	engine.screen:addEntity(Projectile:new(self.idEntity, pos, dir, math.floor(self.dmg/2), math.floor(self.dmgMana/2), self.spdInit, math.floor(self.r/2), 0))

	for i = 1, nb-1 do
		dir = engine:vector_rotate(dir, stepAngle)
		local pos2 = engine:vector_copy(self.pos)
		engine.screen:addEntity(Projectile:new(self.idEntity, pos2, dir, math.floor(self.dmg/2), math.floor(self.dmgMana/2), self.spdInit, math.floor(self.r/2), 0))
	end
end

return Projectile