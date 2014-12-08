local class = require 'middleclass'

local IEntity = require 'entity.IEntity'
local Popup = require 'entity.Popup'

local Player = class('Player', IEntity)
local Bicycle = require 'entity.Bicycle'
local Cloud = require 'entity.Cloud'
local Projectile = require 'entity.Projectile'
local CastBar = require 'CastBar'
local EndScreen = require 'screen.EndScreen'
local Item = require 'Items'
local Poupee = require 'entity.Poupee'

function Player:initialize(x,y)
	IEntity.initialize(self)
	self.maxMana = 50
	self.mana = 50
	self.maxLife = 100
	self.life = 100
	self.isDeath = false
	self.isDeadByRide= false
	self.size = 32
	self.id = 1

	self.image = {}
	self.image.up = love.graphics.newImage("assets/sprites/annau.png")
	self.image.down = love.graphics.newImage("assets/sprites/annad.png")
	self.image.left = love.graphics.newImage("assets/sprites/annal.png")
	self.image.right = love.graphics.newImage("assets/sprites/annar.png")
	self.image.current = self.image.up
	for _,e in pairs(self.image) do
		e:setFilter('nearest', 'nearest')
	end

	self.str = 1
	self.int = 1
	self.regen = 0.0005

	self.pos = {}
	self.pos.x = x
	self.pos.y = y
	self.spd = {}
	self.spd.x = 0
	self.spd.y = 0
	self.h = self.size
	self.w = self.size

	self.dir = {}
	self.dir.x = 1
	self.dir.y = 0

	self.diagonale = false

	self.canMove = true

	self.hasToctoc = false
	self.hasSpokenToElsa = false
	self.hasSpokenToPoupee = false
	self.hasBuiltTheSnowman = false
	self.defeatTheSnowman = false
	self.isRiding = false
	self.flagBuiltSnowmanTime = 0
	self.flagBuiltSnowmanTimeMAX = 3

	self.inventaire = {}
	--self.inventaire.dist = {name = 'Shield', coutMana = 0, resistance = 2}
	self.inventaire.hand = Item.HAND[2]
	self.inventaire.dist = Item.DIST[1]
	--self.inventaire.sort = {name = 'Interruptball', coutMana = 5, damage = 2, castTime = 0.5, canInterrupt = true}
	self.inventaire.sort = nil

	self.defense = false
	self.attack = false
	self.attackDist = false
	self.attackSort = false
	self.dirAttack = {}
	self.castbar = nil
	self.waitbar = nil
end

function Player:update(dt)
	self.diagonale = true
	--self.maxMana = self.int * 50

	if self.canMove then
		if keyboard:isDown("up") or keyboard:isDown("w")  then
			self.spd.y = self.spd.y * IEntity.FRICTION - dt * IEntity.SPEED * (1 - IEntity.FRICTION)
			self.dir.y = -1
		elseif keyboard:isDown("down") or keyboard:isDown("s")  then
			self.spd.y = self.spd.y * IEntity.FRICTION + dt * IEntity.SPEED * (1 - IEntity.FRICTION)
			self.dir.y = 1
		else
			self.diagonale = false
			self.spd.y = self.spd.y * IEntity.FRICTION
		end
		if keyboard:isDown("left") or keyboard:isDown("a") then
			self.spd.x = self.spd.x * IEntity.FRICTION - dt * IEntity.SPEED * (1 - IEntity.FRICTION)
			self.dir.x = -1
		elseif keyboard:isDown("right") or keyboard:isDown("d") then
			self.spd.x = self.spd.x * IEntity.FRICTION + dt * IEntity.SPEED * (1 - IEntity.FRICTION)
			self.dir.x = 1
		else
			self.diagonale = false
			self.spd.x = self.spd.x * IEntity.FRICTION
		end
		self.dir = engine:vector_normalize(self.dir)

		if self.diagonale then
			self.spd.x = self.spd.x * 1 / math.sqrt(1.3)
			self.spd.y = self.spd.y * 1 / math.sqrt(1.3)
		end

		if self.dir.x > 0.5 then
			self.image.current = self.image.right
		elseif self.dir.x < -0.5 then
			self.image.current = self.image.left
		elseif self.dir.y > 0.5 then
			self.image.current = self.image.down
		elseif self.dir.y < -0.5 then
			self.image.current = self.image.up
		end

		local boolx,booly = self:tryMove()
		if boolx then
			self.pos.x = self.pos.x + self.spd.x
		elseif booly then
			self.pos.y = self.pos.y + self.spd.y
			self.spd.x = 0
		else
			self.spd.x = 0

		end
		if booly and boolx then
			self.pos.y = self.pos.y + self.spd.y
		else
			self.spd.y = 0
		end

		if not self.hasBuiltTheSnowman and self.isDeath then
			love.timer.sleep(0.2)
			engine:screen_setNext(EndScreen:new(engine.screen))
		end
		if not engine.screen.arenaMode then
			self:flag(dt)
			self:interact()
		end
	end

	if engine.screen.arenaMode and engine.screen.tournament ~= nil and engine.screen.tournament.arena ~= nil then
		self:interactArena(dt)
	else
		
	end
end

function Player:interactArena(dt)
	if self.mana < self.maxMana then
		self.mana = self.mana + self.regen * self.int
		if self.mana > self.maxMana then
			self.mana = self.maxMana
		end
	end

	if self.attackDist then
		if self.castbar:update(dt) then
			self.canMove = true
			self.castbar = nil
			self.attackDist = false
			local pos = engine:vector_copy(self:getCenter())
			engine.screen:addEntity(Projectile:new(self.id, pos, self.dirAttack, self.inventaire.dist.damage * self.int, 0, 1, 5, 0, false))
			self.mana = self.mana - self.inventaire.dist.coutMana
		else
			if mouse:isPressed("r") then
				self.canMove = true
				self.attackDist = false
				self.castbar = nil
			end
		end
	elseif self.attackSort then
		if self.castbar:update(dt) then
			if self.inventaire.sort.name == 'Interruptball' then
				local pos = engine:vector_copy(self:getCenter())
				engine.screen:addEntity(Projectile:new(self.id, pos, self.dirAttack, self.inventaire.sort.damage * self.int, 0, 1.5, 8, 0, true))
			elseif self.inventaire.sort.name == 'Divine Prayer' then
				self.life = self.life + self.inventaire.sort.damage
				if self.life > self.maxLife then
					self.life = self.maxLife
				end
			end
			self.canMove = true
			self.castbar = nil
			self.attackSort = false
			self.mana = self.mana - self.inventaire.sort.coutMana
		else
			if keyboard:isPressed(" ") then
				self.canMove = true
				self.attackSort = false
				self.castbar = nil
			end
		end
	elseif self.attack then
		if self.waitbar:update(dt) then
			self.attack = false
			self.waitbar = nil
		end
	elseif self.canMove then
		if mouse:isPressed("l") then
			self.attack = true
			self.waitbar = CastBar:new(self.inventaire.hand.castTime, self, "")
			local x,y = mouse:wherePressed("l")
			local dir = engine:vector_normalize(engine:vector_of(self.pos, {x = x, y = y}))
			self.dirAttack = dir
			local boss = engine.screen.tournament.arena.boss
			engine.music.sfx.sword:play()
			if engine:isInAreaLine(self.pos, dir, boss.pos)
				and engine:vector_length(engine:vector_of(self:getCenter(), boss:getCenter())) < self.size*2 then
				boss:hit(self.inventaire.hand.damage * self.str)
			end
		elseif mouse:isReleased("l") then
		end
		if mouse:isPressed("r") then
			if self.inventaire.dist.name == 'Fireball' and self.mana > self.inventaire.dist.coutMana then
				self.attackDist = true
				self.canMove = false
				local x,y = mouse:wherePressed("r")
				local dir = engine:vector_normalize(engine:vector_of(self.pos,{x = x, y = y}))
				self.dirAttack = dir
				self.castbar = CastBar:new(self.inventaire.dist.castTime, self, self.inventaire.dist.name, 'attack')
			end
		elseif mouse:isDown("r") and self.inventaire.dist.name == 'Shield' then
			self.defense = true
		elseif mouse:isReleased("r") then
			self.defense = false
		elseif keyboard:isPressed(" ") and self.inventaire.sort ~= nil then
			if self.inventaire.sort.name == 'Interruptball' and self.mana > self.inventaire.sort.coutMana then
				self.attackSort = true
				self.canMove = false
				local x,y = love.mouse.getPosition()
				local dir = engine:vector_normalize(engine:vector_of(self.pos, {x=x, y=y}))
				self.dirAttack = dir
				self.castbar = CastBar:new(self.inventaire.sort.castTime, self, self.inventaire.sort.name, 'attack')
			elseif self.mana > self.inventaire.sort.coutMana then
				self.attackSort = true
				self.canMove = false
				self.castbar = CastBar:new(self.inventaire.sort.castTime, self, self.inventaire.sort.name, 'peace')
			end
		end
	end
end

function Player:drawInteractArena()
	if self.castbar ~= nil then
		self.castbar:draw()
	end
end

function Player:drawButton()
	if self.arenaMode then

	end
end

function Player:interact()
	if keyboard:isPressed("return") then
		tile = {}

		if self.image.current == self.image.up then
			tile.x = math.floor((self.pos.x + self.size/2) / engine.TILESIZE)
			tile.y = math.floor((self.pos.y - engine.TILESIZE + self.size/2) / engine.TILESIZE)

			if tile.x == 2 and tile.y == 15 then
				engine.screen.map[engine.screen.currentMap]:areaFadeIn(1)
				engine.screen.map[engine.screen.currentMap]:areaFadeOut(0)
				self.pos.y = 14 * engine.TILESIZE
				self.pos.x = 2 * engine.TILESIZE
				for _,e in ipairs(engine.screen.entities) do
					if e.type == 'poupee' then
						engine.screen:removeEntity(e.id)
						break
					end
				end
				engine.screen:addEntity(Bicycle:new())
				if not self.hasToctoc then
					engine.screen:addEntityPassiv(Popup:new("Elsa?", self, 1, 80))
					engine.music.anna.elsa:play()
				end
			elseif tile.x == 22 and tile.y == 15 then
				engine.screen:changeMap(1)
				engine.screen.map[engine.screen.currentMap]:areaFadeIn(2)
				engine.screen.map[engine.screen.currentMap].areaGoal[0] = 0
				engine.screen.map[engine.screen.currentMap].area[0] = 0
				self.pos.y = 14 * engine.TILESIZE
				self.pos.x = 22 * engine.TILESIZE
			else
				boxP = self:getBox()
				boxP.y = boxP.y - self.size/2
				for _,e in ipairs(engine.screen.entities) do
					if e.id ~= 1 then
						if engine:AABB_AABB(boxP, e:getBox()) and self.hasSpokenToElsa and not self.isRiding then
							e:ride(self)
							self.isRiding = true
							engine.music.anna['ride']:play()
							break
						end
					end
				end
			end


		elseif self.image.current == self.image.right then
			tile.x = math.floor((self.pos.x + engine.TILESIZE + self.size/2) / engine.TILESIZE)
			tile.y = math.floor((self.pos.y + self.size/2) / engine.TILESIZE)

			if tile.x == 3 and tile.y == 9 and not self.hasSpokenToElsa then
				if not self.hasToctoc then
					engine.music.anna['toctoc']:play()
					self.hasToctoc = true
					love.timer.sleep(1.3)
					engine.music.anna['begin']:play()
				elseif self.hasSpokenToPoupee and not self.isRiding then
					engine.music.anna['beginP2']:play()
					self.hasSpokenToElsa = true
					engine.screen:addEntityPassiv(Popup:new("Do you want to build a snowman?", self, 3, 250,
						Popup:new("It doesn't have to be a snowman.", self, 3, 270,
							Popup:new("Go away, Anna!", {pos = {x = 300; y = 350}}, 2, 150,
								Popup:new("Ok bye...", self, 3, 100)))))
					self.canMove = false
				end
			else
				boxP = self:getBox()
				boxP.x = boxP.x + self.size / 2
				for _,e in ipairs(engine.screen.entities) do
					if e.id ~= 1 then
						if engine:AABB_AABB(boxP, e:getBox()) and self.hasSpokenToPoupee and not self.isRiding then
							if e.current ~= self.image.out then
								e:ride(self)
								engine.music.anna['ride']:play()
								break
							end
						end
					end
				end
			end
		
		elseif self.image.current == self.image.left then
			boxP = self:getBox()
			boxP.x = boxP.x - self.size/2
			for _,e in ipairs(engine.screen.entities) do
				if e.type == 'poupee' then
					if engine:AABB_AABB(boxP, e:getBox()) and self.hasToctoc and not self.hasSpokenToPoupee then
						engine.music.anna.poupee:play()
						self.hasSpokenToPoupee = true
						break
					end
				end
			end
		elseif self.image.current == self.image.down then
			tile.x = math.floor((self.pos.x + self.size/2) / engine.TILESIZE)
			tile.y = math.floor((self.pos.y + engine.TILESIZE + self.size/2) / engine.TILESIZE)

			if tile.x == 22 and tile.y == 15 then
				engine.screen:changeMap(2)
				engine.screen.map[engine.screen.currentMap]:areaFadeIn(3)
				self.pos.y = 16 * engine.TILESIZE
			elseif tile.x == 2 and tile.y == 15 then
				engine.screen.map[engine.screen.currentMap]:areaFadeIn(0)
				engine.screen.map[engine.screen.currentMap]:areaFadeOut(1)
				for _,e in ipairs(engine.screen.entities) do
					if e.type == "bicycle" then
						engine.screen:removeEntity(e.id)
						break
					end
				end
				engine.screen:addEntity(Poupee:new())
				self.pos.y = 16* engine.TILESIZE
			end

			boxP = self:getBox()
			boxP.y = boxP.y + self.size/2
			for _,e in ipairs(engine.screen.entities) do
				if e.type == 'poupee' then
					if engine:AABB_AABB(boxP, e:getBox()) and self.hasToctoc and not self.hasSpokenToPoupee then
						engine.music.anna.poupee:play()
						self.hasSpokenToPoupee = true
						break
					end
				end
			end
		end
	end
end

function Player:flag(dt)
	if self.hasBuiltTheSnowman and self.flagBuiltSnowmanTime < self.flagBuiltSnowmanTimeMAX then
		self.flagBuiltSnowmanTime = self.flagBuiltSnowmanTime + dt
		if math.floor((self.flagBuiltSnowmanTime * 10) % 3) == 0 then
			engine.screen:addEntityPassiv(Cloud:new())
		end

		if self.flagBuiltSnowmanTime >= self.flagBuiltSnowmanTimeMAX then
			engine.screen.arenaMode = true
			self.pos.x = engine.TILESIZE * 6
			self.pos.y = engine.TILESIZE * 10
		end
	end 
end

function Player:draw()
	love.graphics.setColor(255,255,255)

	love.graphics.draw(self.image.current, self.pos.x, self.pos.y)
	self:drawInteractArena()

	if self.attack then
		local posB = self:getCenter()
		love.graphics.setColor(100, 255, 100)
		love.graphics.line(posB.x, posB.y, posB.x+ self.dirAttack.x*40, posB.y + self.dirAttack.y * 40)
	end
end

function Player:onQuit()
end

function Player:tryMove()
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
		if e.id ~= 1 then
			if engine:AABB_AABB(boxP, e:getBox()) then
				if e.type == "snowball" then
					e.spd.x = self.spd.x
					x = false
				else
					x = false
					boxP.x = boxP.x - self.spd.x
				end
			end
		end
	end

	boxP.y = boxP.y + self.spd.y
	for _,e in ipairs(engine.screen.entities) do
		if e.id ~= 1 then
			if engine:AABB_AABB(boxP, e:getBox()) then
				if e.type == "snowball" then
					e.spd.y = self.spd.y
					y = false
				else
					y = false
				end
			end
		end
	end

	return x,y
end

function Player:getBox()
	local box = {x = self.pos.x, y = self.pos.y, h = self.size, w = self.size}
	return box
end

function Player:getCenter()
	return {x = self.pos.x + self.w / 2, y = self.pos.y + self.h / 2}
end

return Player