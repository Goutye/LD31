local class = require 'middleclass'
local IEntity = require 'entity.IEntity'
local CastBar = require 'CastBar'

local FireFollower = class('FireFollower', IEntity)

function FireFollower:initialize(r, retard, duree, dmg, auto, nb)
	IEntity.initialize(self)
	self.pos = engine:vector_copy(engine.screen.player:getCenter())
	--self.pos.x = self.pos.x - self.player.size/2
	--self.pos.y = self.pos.y - self.player.size/2
	self.r = r
	self.retard = retard
	self.duree = duree
	self.auto = auto
	self.nb = nb
	self.count = 0
	self.dmg = dmg

	self.castbarRetard = CastBar:new(retard, self, "")
	self.castbarDuree = CastBar:new(duree, self, "")
	self.isPut = false
	self.waitbar = CastBar:new(0.1, self, "")
	self.hit = false
	self.isDeath = false
end

function FireFollower:update(dt)
	if self.hit then
		if self.waitbar:update(dt) then
			self.hit = false
		end
	elseif self.auto then
		if self.count < self.nb then
			if self.castbarRetard:update(dt) then
				self.isPut = true
				engine.music.sfx.fire:play()
			elseif self.isPut then
				if self.castbarDuree:update(dt) then
					self.isPut = false
					self.castbarRetard:reset()
					self.pos = engine:vector_copy(engine.screen.player:getCenter())
					self.count = self.count + 1
				else
					if engine:AABB_circle(engine.screen.player:getBox(), self:getCircle()) then
						engine.screen.player:hit(self.dmg)
						self.hit = true
						self.waitbar.time = 0
					end
				end
			end
		end
	else
		if self.castbarRetard:update(dt) then
			self.isPut = true
			engine.music.sfx.fire:play()
		elseif self.isPut then
			if self.castbarDuree:update(dt) then
				self.isPut = false
				self.isDeath = true
				engine.screen:removeEntityPassiv(self.id)
			elseif not self.isDeath then
				if engine:AABB_circle(engine.screen.player:getBox(), self:getCircle()) then
					engine.screen.player:hit(self.dmg)
					self.hit = true
					self.waitbar.time = 0
				end
			end
		end
	end
end

function FireFollower:draw()
	if self.isPut and not self.isDeath then
		love.graphics.setColor(45,0,0)
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
		love.graphics.setColor(255,255,255)
	end
end

function FireFollower:onQuit()
end

function FireFollower:tryMove()
end

function FireFollower:getCircle()
	return {pos = {x= self.pos.x, y = self.pos.y}, r = self.r}
end

function FireFollower:getBox()
	local box = {x = self.pos.x, y = self.pos.y, w = self.w, h = self.h}
	return box
end

return FireFollower