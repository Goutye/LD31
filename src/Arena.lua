local class = require 'middleclass'

local Arena = class('Arena')
local Map = require 'Map'
local Boss = require 'entity.Boss'
local UI = require 'UI'

function Arena:initialize(ListPowerUnlocked, nbVictory)
	self.num = love.math.random(1,1)
	self.map = Map:new(self.num, true)
	self.boss = Boss:new(ListPowerUnlocked, nbVictory)
	
	engine.screen.ui = UI:new(self.boss)
	--engine.screen.tournament:addPower(self.boss.newPower)
	engine.screen:addEntity(self.boss)
	engine.screen.map.arena = self.map
end

function Arena:update(dt)
	if engine.screen.player.isDeath then
		--Screen : AVEUGLE etc
		return 'player'
	elseif self.boss.isDeath then
		engine.screen.player.defeatTheSnowman = true
		--Screen : GG... Not the end! NEXT BOSS
		return 'boss'
	end

	return 'in progress'
end

function Arena:draw()
end

function Arena:onQuit()
end

return Arena