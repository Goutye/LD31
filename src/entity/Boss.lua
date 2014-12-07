local class = require 'middleclass'
local IEntity = require 'entity.IEntity'
local Power = require 'Power'
local CastBar = require 'CastBar'

local Boss = class('Boss')

function Boss:initialize(listPower, nbVictory)
	self.id = nil
	self.type = 'boss'
	self.pos = {}
	self.pos.x = WINDOW_WIDTH/2
	self.pos.y = WINDOW_HEIGHT/2
	self.w = 64
	self.h = 64

	self.str = math.max(2 * nbVictory + 2 - engine.screen.tournament.lose.str, 1)
	self.int = math.max(1 * nbVictory + 1 - engine.screen.tournament.lose.int, 1)
	self.castSpeed = 1 + 0.2 * nbVictory
	self.regen = 0.001 * nbVictory

	self.life = nbVictory * 50 + 100
	self.maxLife = self.life
	self.mana = nbVictory * 50 + 50 * self.int
	self.maxMana = self.mana
	self.lvl = nbVictory

	self.listPower = listPower
	self.bossPower = {}
	for i,e in ipairs(self.listPower) do
		self.bossPower[i] = Power:new(e, self, listPower, self.str, self.int, self.castSpeed, self.regen)
	end

	self.newPower = Power:new(nil, self, listPower, self.str, self.int, self.castSpeed, self.regen)
	if self.newPower.id ~= 0 then
		table.insert(listPower, self.newPower.id)
		table.insert(self.bossPower, self.newPower)
	end

	self.nbPhases = math.floor(nbVictory / 5)

	self.timeBetweenAtk = math.max(5 - nbVictory/5, 0.5)
	self.flagTimeBetweenAtk = 0

	self.timeBetweenMainAtk = 1
	self.flagTimeBetweenMainAtk = 0

	self.power = nil
	self.boxMainAtk = {x = self.pos.x + self.w/2, y = self.pos.y + self.h/2, w = self.w, h = self.h}

	self.dir = {}
	self.dir.x = 0
	self.dir.y = 0

	self.image = {}
	self.image.up = love.graphics.newImage("assets/sprites/Bossu.png")
	self.image.down = love.graphics.newImage("assets/sprites/Boss.png")
	self.image.left = love.graphics.newImage("assets/sprites/Bossl.png")
	self.image.right = love.graphics.newImage("assets/sprites/Bossr.png")
	self.image.current = self.image.down

	self.isCasting = false
	self.imageCast = {}
	for i = 1, 4 do
		self.imageCast[i] = love.graphics.newImage("assets/sprites/BossCast"..i..".png")
	end
	self.imageCastcurrent = 1
	self.timeImgCast = 0.5
	self.flagTimeImgCast = 0

	self.isDeath = false
	self.canMove = true

	self.waitBarSword = CastBar:new(0.5, self, "")
end

function Boss:update(dt)
	self.mana = self.mana + self.regen
	if self.mana > self.maxMana then
		self.mana = self.maxMana
	end

	if self.hasHit then
		if self.waitBarSword:update(dt) then
			self.hasHit = false
		end
	end

	self.flagTimeBetweenAtk = self.flagTimeBetweenAtk + dt
	if self.canMove then
		self:updateDir(engine.screen.player)
	end

	if self.isCasting then
		self.flagTimeImgCast = self.flagTimeImgCast + dt
		if self.flagTimeImgCast > self.timeImgCast then
			self.flagTimeImgCast = 0
			self.imageCastcurrent = (self.imageCastcurrent % (#self.imageCast)) + 1
		end
	end

	if self.flagTimeBetweenAtk > self.timeBetweenAtk then
		self.power = self.bossPower[love.math.random(1, #self.bossPower)]
		self.flagTimeBetweenAtk = -9999999
	end

	if self.power ~= nil then
		if self.power:update(dt) then
			self.flagTimeBetweenAtk = 0
			self.power = nil
		end
	elseif self.flagTimeBetweenMainAtk > self.timeBetweenMainAtk then
		if engine:isInAreaLine(self.pos, self.dir, engine.screen.player.pos) 
			and engine:vector_length(engine:vector_of(self:getCenter(), engine.screen.player:getCenter())) < math.min(self.w, self.h) then
			engine.screen.player:hit(self.str)
			self.hasHit = true
			engine.music.sfx.hit:play()
		end
		self.flagTimeBetweenMainAtk = 0
	else
		self.flagTimeBetweenMainAtk = self.flagTimeBetweenMainAtk + dt
	end

	if engine.screen.player.isDeath or self.isDeath then
		engine.screen:removeEntity(self.id)
	end
end

function Boss:updateDir(player)
	local posP = player.pos
	local dir = {}
	dir = engine:vector_of(self.pos, posP)

	self.dir = engine:vector_normalize(dir)
	dir = self.dir

	if dir.x > 0 then
		if dir.x > math.abs(dir.y) then
			self.image.current = self.image.right
		else
			if dir.y < 0 then
				self.image.current = self.image.up
			else
				self.image.current = self.image.down
			end
		end
	else
		if dir.x < -math.abs(dir.y) then
			self.image.current = self.image.left
		else
			if dir.y < 0 then
				self.image.current = self.image.up
			else
				self.image.current = self.image.down
			end
		end
	end
end

function Boss:hitMana(dmg)
	self.mana = self.mana - dmg
	if self.mana < 0 then
		self.mana = 0
	end
end

function Boss:hit(dmg)
	self.life = self.life - dmg
	if self.life < 0 then
		self.life = 0
		self.isDeath = true
	end
end

function Boss:draw()
	if self.isCasting then
		love.graphics.draw(self.imageCast[self.imageCastcurrent], self.pos.x, self.pos.y)
	else
		love.graphics.draw(self.image.current, self.pos.x, self.pos.y)
	end
	if self.power ~= nil then
		self.power:draw()
	end
	if self.hasHit then
		local posP = engine.screen.player:getCenter()
		local posB = self:getCenter()
		love.graphics.setColor(255, 100, 100)
		love.graphics.line(posB.x, posB.y, posB.x+ self.dir.x*40, posB.y + self.dir.y * 40)
	end

	love.graphics.setColor(0,0,0)
end

function Boss:onQuit()
end

function Boss:tryMove()
end

function Boss:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.w, h = self.h}
	return box
end

function Boss:getCenter()
	return {x = self.pos.x + self.w / 2, y = self.pos.y + self.h / 2}
end

return Boss