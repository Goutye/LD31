local class = require 'middleclass'
local CastBar = require 'CastBar'
local Projectile = require 'entity.Projectile'
local FireFollower = require 'entity.FireFollower'

local Power = class('Power')

Power.static.POWER = {{name = 'Fireball', castTime = 2, canBeShorter = true,dmg = 2, dmgMana = 0, coutMana = 3, type = 'attack', canMove = true, inCast = false},
					{name = 'Explodeball', castTime = 3, canBeShorter = true,dmg = 2, dmgMana = 0, coutMana = 5, type = 'attack', canMove = true, inCast = false},
					{name = 'Fire follower', castTime = 10, canBeShorter = true,dmg = 2, dmgMana = 0, coutMana = 6, type = 'attack', canMove = true, inCast = true, betweenTic = 2},
					{name = 'Auto Fire follower', castTime = 3, canBeShorter = true,dmg = 2, dmgMana = 0, coutMana = 10, type = nil, canMove = false, inCast = false, nbFire = 4},
					{name = 'Blessing of health', castTime = 5, canBeShorter = false, dmg = 15, dmgMana = 0, coutMana = 10, type = 'canBeInterrupt', canMove = true, minPower = 3}}

function Power:initialize(known, boss, listPower, str, int, castSpeed, regen)
	if known ~= nil then
		self.id = known
		self.power = Power.POWER[known]
		self.power.dmg = Power.POWER[known].dmg * boss.int
		self.power.dmgMana = Power.POWER[known].dmgMana * boss.int
	else
		self.id = self:learnNewPower(listPower)

		if self.id == 0 then
			return
		end
		self.power = Power.POWER[self.id]
		self.power.dmg = self.power.dmg * boss.int
		self.power.dmgMana = self.power.dmgMana * boss.int
	end
	if self.power.canBeShorter then
		self.power.castTime = self.power.castTime / boss.castSpeed
		if self.power.inCast then
			self.power.betweenTic = self.power.betweenTic / boss.castSpeed
		end
	end
	self.boss = boss
	self.flagCastTime = 0
	self.castBar = CastBar:new(self.power.castTime, boss, self.power.name, self.power.type)

	self.isInterrupt = false
end

function Power:update(dt)
	if self.isInterrupt then
		self.isInterrupt = false
		self.castBar.time = 0
		return true
	end
	if self.boss.mana >= self.power.coutMana then
		if self.power.inCast then
			if self.castBar:update(dt) then
				self.boss:hitMana(self.power.coutMana)
				self.castBar.maxTime = self.power.castTime
				return true
			end
			if self.castBar.time > self.power.betweenTic then
				self:execute()
				self.castBar.time = self.castBar.time - self.power.betweenTic
				self.castBar.maxTime = self.castBar.maxTime - self.power.betweenTic
			end
		else
			self.boss.canMove = self.power.canMove
			if not self.boss.canMove then
				self.boss.isCasting = true
			end

			if self.castBar:update(dt) then
				self.boss.isCasting = false
				self.boss.canMove = true
				self:execute()
				self.boss:hitMana(self.power.coutMana)
				return true
			end
		end
		return false
	end
	return true
end

function Power:learnNewPower(listPower)
	if #listPower < #Power.POWER then
		continue = true
		i = 0
		repeat
			continue = false
			i = love.math.random(1,#Power.POWER)
			for _,e in ipairs(listPower) do
				if e == i then
					continue = true
				end
			end

			if Power.POWER[i].minPower ~= nil and Power.POWER[i].minPower > #listPower then
				continue = true
			end  
		until not continue

		return i
	end

	return 0
end

function Power:execute()
	local pos = {x = self.boss.pos.x + self.boss.w/2, y = self.boss.pos.y + self.boss.h/2}
	if self.power.name == 'Fireball' then
		engine.screen:addEntity(Projectile:new(self.boss.id, pos, self.boss.dir, self.power.dmg, self.power.dmgMana, 1, 8 + 2 * self.boss.int, 0))
	elseif self.power.name == 'Explodeball' then
		engine.screen:addEntity(Projectile:new(self.boss.id, pos, self.boss.dir, self.power.dmg, self.power.dmgMana, 1, 8 + 2 * self.boss.int, 6))
	elseif self.power.name == 'Fire follower' then
		engine.screen:addEntityPassiv(FireFollower:new(15 + 3 * self.boss.int , 1, 1, 1, true, 1))
	elseif self.power.name == 'Auto Fire follower' then
		engine.screen:addEntityPassiv(FireFollower:new(15 + 3 * self.boss.int, 1, 1, 1, true, self.power.nbFire))
	elseif self.power.name == 'Blessing of health' then
		self.boss.life = self.boss.life + self.power.dmg
		if self.boss.life > self.boss.maxLife then
			self.boss.life = self.boss.maxLife
		end
	end
end

function Power:draw()
	self.castBar:draw()
end

function Power:onQuit()
end

return Power