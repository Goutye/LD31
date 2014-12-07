local class = require 'middleclass'

local Tournament = class('Tournament')
local Map = require 'Map'
local Arena = require 'Arena'
local EndScreen = require 'screen.EndScreen'
local Item = require 'Items'

function Tournament:initialize()
	self.victory = 0
	self.lose = 0
	self.arena = nil
	self.listPower = {}
	self.status = 'in progress'

	self.display = 0
	self.goalDisplay = 0
	self.entitiesClean = false

	self.choice = 0
	self.nbChoice = 2

	self.weapon = 0
	self.nbWeapon = 3

	self.next = {}
	self.next.hand = nil
	self.next.sort = nil
	self.next.dist = nil

	self.item = Item:new()

	self.lose = {}
	self.lose.int = 0
	self.lose.str = 0

	self.screenCompet = false
	self.screenWeapon = false
	self.screenLose = false

	local tab = {}
	table.insert(tab, engine.screen.player)
	engine.screen.entities = tab
end

function Tournament:update(dt)
	self:displayFade(dt)
	if self.arena == nil then
		self:newFight()
	end

	if self.screenCompet then
		engine.screen.player.canMove = false
		if keyboard:isPressed("a") or keyboard:isPressed("left") then
			self.choice = (self.choice - 1 + self.nbChoice) % self.nbChoice
		elseif keyboard:isPressed("d") or keyboard:isPressed("right") then
			self.choice = (self.choice + 1) % self.nbChoice
		end
		if keyboard:isPressed("return") then
			self.screenWeapon = true
			self.screenCompet = false

			self.next.hand = self.item:getRandomHand(engine.screen.player.inventaire.hand)
			self.next.dist = self.item:getRandomDist(engine.screen.player.inventaire.dist)
			self.next.sort = self.item:getRandomSort(engine.screen.player.inventaire.sort)

			if self.choice == 0 then
				engine.screen.player.str = engine.screen.player.str + 1
			else
				engine.screen.player.int = engine.screen.player.int + 1
			end
		end
	elseif self.screenWeapon then
		engine.screen.player.canMove = false
		if keyboard:isPressed("a") or keyboard:isPressed("left") then
			self.choice = (self.choice - 1 + self.nbChoice) % self.nbChoice
		elseif keyboard:isPressed("d") or keyboard:isPressed("right") then
			self.choice = (self.choice + 1) % self.nbChoice
		end
		if keyboard:isPressed("return") then
			if self.weapon == 0 then
				if self.choice == 1 then
					engine.screen.player.inventaire.hand = self.next.hand
				end
			elseif self.weapon == 1 then
				if self.choice == 1 then
					engine.screen.player.inventaire.dist = self.next.dist
				end
			elseif self.weapon == 2 then
				if self.choice == 1 then
					engine.screen.player.inventaire.sort = self.next.sort
				end
			end
			self.weapon = self.weapon + 1
			if self.weapon >= self.nbWeapon then
				self.weapon = 0
				self.entitiesClean = false
				self.screenWeapon = false
				engine.screen.player.canMove = true
				engine.music:next()
				self:newFight()
			end
		end
	elseif self.screenLose then
		engine.screen.player.canMove = false
		if keyboard:isPressed("escape") then
			engine:screen_setNext(EndScreen:new(engine.screen))
			return
		end
		if keyboard:isPressed("a") or keyboard:isPressed("left") then
			self.choice = (self.choice - 1 + self.nbChoice) % self.nbChoice
		elseif keyboard:isPressed("d") or keyboard:isPressed("right") then
			self.choice = (self.choice + 1) % self.nbChoice
		end
		if keyboard:isPressed("return") then
			self.screenLose = false

			if self.choice == 0 then
				self.lose.int = self.lose.int + 1
			else
				self.lose.str = self.lose.str + 1
			end
			self.entitiesClean = false
			engine.screen.player.canMove = true
			engine.music:next()
			self:newFight()
		end
	else
		self.status = self.arena:update(dt)
		if self.status == 'in progress' then
		elseif self.status == 'boss' then
			self.goalDisplay = 1
			if not self.entitiesClean then
				engine.screen:removeAllEntities()
				self.entitiesClean = true
			end
			engine.screen.player.canMove = false
			self.screenCompet = true
			self.victory = self.victory + 1
		elseif self.status == 'player' then
			engine.screen.player.canMove = false
			self.goalDisplay = 1
			self.screenLose = true
			if not self.entitiesClean then
				engine.screen:removeAllEntities()
				self.entitiesClean = true
			end
		end
	end
end

function Tournament:updateCompetence()
	
end

function Tournament:displayFade(dt)
	if self.display < self.goalDisplay then
		self.display = self.display + dt
		if self.display > self.goalDisplay then
			self.display = self.goalDisplay
		end
	elseif self.display > self.goalDisplay then
		self.display = self.display - dt
		if self.display < self.goalDisplay then
			self.display = self.goalDisplay
		end
	end
end

function Tournament:draw()
	love.graphics.setColor(10,10,10,200*self.display/self.goalDisplay)
	love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(engine.font60)
	if self.status == 'boss' then
		engine:printOutLineGreen("VICTORY", WINDOW_WIDTH/2, WINDOW_HEIGHT/4, math.rad(15))
		engine:printOutLineGreen(self.victory, WINDOW_WIDTH/2, WINDOW_HEIGHT/4+75, math.rad(15))
	elseif self.status == 'player' then
		engine:printOutLineRed("YOU LOSE", WINDOW_WIDTH/4, WINDOW_HEIGHT/4, math.rad(15))
	end
	love.graphics.setFont(engine.font14)

	if self.screenCompet then
		self:drawCompetence()
	elseif self.screenWeapon then
		self:drawWeapon()
	elseif self.screenLose then
		self:drawLose()
	end
end

function Tournament:drawLose()
	love.graphics.setColor(230,230,230)
	love.graphics.printf("What was the problem, dude?", WINDOW_WIDTH/4, WINDOW_HEIGHT/8, 300, "left")
	love.graphics.printf("His powerful spells", WINDOW_WIDTH/4, WINDOW_HEIGHT/8 + 40, 180, "left")
	love.graphics.printf("His melee attacks", WINDOW_WIDTH/4 + 180, WINDOW_HEIGHT/8 + 40, 180, "left")
	love.graphics.rectangle("line", WINDOW_WIDTH/4-5 + 180*self.choice, WINDOW_HEIGHT/8+25, 180, 30)
	love.graphics.printf("...or maybe, you want to stop to fight now? Press <ESCAPE>", WINDOW_WIDTH/4, WINDOW_HEIGHT/2 +100, 600, "left")
end

function Tournament:drawCompetence()
	love.graphics.setColor(230,230,230)
	love.graphics.printf("What do you want to improve?", WINDOW_WIDTH/4, WINDOW_HEIGHT/8, 300, "left")
	love.graphics.printf("My Strength : +1", WINDOW_WIDTH/4, WINDOW_HEIGHT/8 + 40, 130, "left")
	love.graphics.printf("My Intel : +1", WINDOW_WIDTH/4 + 140, WINDOW_HEIGHT/8 + 40, 130, "left")
	love.graphics.rectangle("line", WINDOW_WIDTH/4-5 + 140*self.choice, WINDOW_HEIGHT/8+25, 140, 30)
end

function Tournament:drawWeapon()
	love.graphics.setColor(230,230,230)
	item = nil
	if self.weapon == 0 then
		item = self.next.hand
		love.graphics.printf("Do you want this beautiful hand weapon?", WINDOW_WIDTH/4, WINDOW_HEIGHT/8, 400, "left")
	elseif self.weapon == 1 then
		item = self.next.dist
		love.graphics.printf("Do you want this amazing distance weapon?", WINDOW_WIDTH/4, WINDOW_HEIGHT/8, 400, "left")
	else 
		item = self.next.sort
		love.graphics.printf("Do you want to learn this incredible spell?", WINDOW_WIDTH/4, WINDOW_HEIGHT/8, 400, "left")
	end

	i = 0
	if self.item ~= nil then
		love.graphics.printf("Name : " .. item.name, WINDOW_WIDTH/4, WINDOW_HEIGHT/4 + 50 + i*20, 200, "left")
		i = i + 1
		for k,v in pairs(item) do
			if v == nil then
				v = 'no'
			elseif type(v) == "boolean" and v then
				v = 'true'
			elseif type(v) == "boolean" and not v then
				v = 'false'
			elseif k == 'coutMana' then
				k = 'Mana cost'
			end
			if k == 'name' then

			else
				love.graphics.printf(k .. " : " .. v, WINDOW_WIDTH/4, WINDOW_HEIGHT/4 + 50 + i*20, 200, "left")
				i = i + 1
			end
		end 
	end
	love.graphics.printf("No, I keep mine.", WINDOW_WIDTH/4, WINDOW_HEIGHT/8 + 40, 130, "left")
	love.graphics.printf("Yes, such improvement.", WINDOW_WIDTH/4 + 160, WINDOW_HEIGHT/8 + 40, 200, "left")
	love.graphics.rectangle("line", WINDOW_WIDTH/4-5 + 160*self.choice, WINDOW_HEIGHT/8+25, 160, 30)
end

function Tournament:newFight()
	self.goalDisplay = 0
	engine.screen.player.life = engine.screen.player.maxLife
	engine.screen.player.mana = engine.screen.player.maxMana
	engine.screen.player.isDeath = false
	self.arena = Arena:new(self.listPower, self.victory)
end

function Tournament:onQuit()
end

return Tournament