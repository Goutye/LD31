local class = require 'middleclass'

local IScreen = require 'screen.IScreen'
local GameScreen = class('GameScreen', IScreen)

local Map = require 'Map'
local Player = require 'entity.Player'
local Snowball = require 'entity.Snowball'
local Bicycle = require 'entity.Bicycle'
local Statue = require 'entity.Statue'
local Tournament = require 'Tournament'
local Poupee = require 'entity.Poupee'

function GameScreen:initialize()
	self.mode = mode ~=nil
	self.difficulty = difficulty

	self.entitiesPassivToDelete = {}
	self.entities = {}
	self.entitiesPassiv = {}

	table.insert(self.entities, Player:new(70, 570))--730, 400))
	self.player = self.entities[1]
	self.player.id = 1

	--Map

	self.currentMap = 1
	self.map = {}
	self.map[1] = Map:new(1)
	self.map[2] = Map:new(2)
	self.map[3] = nil
	self.map.arena = nil 

	self:addEntity(Poupee:new())
	
	self.tournament = nil
	self.arenaMode = false
	self.ui = nil
end

function GameScreen:update(dt)
	--CHEAT
	if keyboard:isPressed("j") then
		self.player.hasBuiltTheSnowman = true
	end
	--CHEAT

	if self.arenaMode then
		if self.tournament == nil then
			self.tournament = Tournament:new()
		else
			if self.ui ~= nil then
				self.ui:update(dt)
			end
			self.tournament:update(dt)
		end
	end

	for _,e in ipairs(self.entities) do
		e:update(dt)
	end
	for _,p in ipairs(self.entitiesPassiv) do
		p:update(dt)
	end

	self.map[self.currentMap]:update(dt)

	self:removeViaPassivToDelete()
end

function GameScreen:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
	love.graphics.setColor(255,255,255)
	if self.arenaMode and self.tournament ~= nil and self.tournament.arena ~= nil then
		self.map[3] = self.tournament.arena.map
		self.currentMap = 2+self.tournament.arena.num
		self.tournament.arena.map:draw()
		self.tournament:draw()
		self.ui:draw()
	else
		self.map[self.currentMap]:draw()
	end

	love.graphics.setColor(255,255,255)

	for i,e in ipairs(self.entities) do
		if i ~= 1 then
			e:draw()
		end
	end
	self.entities[1]:draw()

	love.graphics.setColor(255,255,255)
	
	for _,p in ipairs(self.entitiesPassiv) do
		p:draw()
	end


end

function GameScreen:changeMap(id)
	if self.arenaMode then
		self.currentMap = id
		for _,e in ipairs(self.entities) do
			if e.id ~= 1 then
				self:removeEntity(e.id)
			end
		end
		self.entities = {}
		self.entities[1] = self.player

	else
		self.currentMap = id
		for _,e in ipairs(self.entities) do
			if e.id ~= 1 then
				self:removeEntity(e.id)
			end
		end
		self.entities = {}
		self.entities[1] = self.player

		if id == 2 then
			self:addEntity(Snowball:new(300,300))
			self:addEntity(Snowball:new(400,400))
		elseif id == 1 then
			self:addEntity(Statue:new())
			b = Bicycle:new()
			b:setPos()
			self:addEntity(b)
		end
	end
end

function GameScreen:onQuit()
end


function GameScreen:addEntity(e)
	table.insert(self.entities, e)
	e.id = #self.entities
end

function GameScreen:removeEntity(id)
	self.entities[id]:onQuit()
	table.remove(self.entities, id)
	
	for i = id, #self.entities do
		self.entities[i].id = self.entities[i].id - 1
	end	
end

function GameScreen:removeAllEntities(text)
	for _,e in ipairs(self.entities) do
		if e.id ~= 1 then
			table.remove(self.entities, e.id)
			
			for i = e.id, #self.entities do
				self.entities[i].id = self.entities[i].id - 1
			end	
		end
	end

	if text == nil then
		for _,e in ipairs(self.entitiesPassiv) do
			table.remove(self.entitiesPassiv, e.id)
		end
		self.entitiesPassiv = {}
	end
end

function GameScreen:addEntityPassiv(e)
	table.insert(self.entitiesPassiv, e)
	e.id = #self.entitiesPassiv
end

function GameScreen:removeEntityPassiv(id)
	table.insert(self.entitiesPassivToDelete, self.entitiesPassiv[id])
end

function GameScreen:removeViaPassivToDelete()
	for _,e in ipairs(self.entitiesPassivToDelete) do
		table.remove(self.entitiesPassiv, e.id)
		
		for i = e.id, #self.entitiesPassiv do
			self.entitiesPassiv.id = self.entitiesPassiv[i].id - 1
		end	

		e:onQuit()
	end
	self.entitiesPassivToDelete = {}
end

return GameScreen