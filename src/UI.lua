local class = require 'middleclass'
local Bar = require 'Bar'

local UI = class('UI')

function UI:initialize(boss)
	self.lifeBarPlayer = Bar:new(engine.screen.player.maxLife, {150, 10, 10}, 20, 10, WINDOW_WIDTH/2 - 40, 30)
	self.lifeBarBoss = Bar:new(boss.maxLife, {150, 10, 10}, 20 + WINDOW_WIDTH/2, 10, WINDOW_WIDTH/2 - 40, 30)
	self.manaBarPlayer = Bar:new(engine.screen.player.maxLife, {10, 10, 150}, 20, 30, WINDOW_WIDTH/2 - 40, 10)
	self.manaBarBoss = Bar:new(boss.maxLife, {10, 10, 150}, 20 + WINDOW_WIDTH/2, 30, WINDOW_WIDTH/2 - 40, 10)
end

function UI:update(dt)
	self.lifeBarPlayer.max = engine.screen.player.maxLife
	self.lifeBarBoss.max = engine.screen.tournament.arena.boss.maxLife
	self.lifeBarPlayer:update(engine.screen.player.life)
	self.lifeBarBoss:update(engine.screen.tournament.arena.boss.life)
	self.manaBarPlayer.max = engine.screen.player.maxMana
	self.manaBarBoss.max = engine.screen.tournament.arena.boss.maxMana
	self.manaBarPlayer:update(engine.screen.player.mana)
	self.manaBarBoss:update(engine.screen.tournament.arena.boss.mana)

end

function UI:draw()
	self.lifeBarPlayer:draw()
	self.lifeBarBoss:draw()
	self.manaBarPlayer:draw()
	self.manaBarBoss:draw()
end

function UI:onQuit()
end

return UI