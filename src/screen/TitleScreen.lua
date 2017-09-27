local class = require 'middleclass'

local TitleScreen = class('TitleScreen')

function TitleScreen:initialize()
	self.image = love.graphics.newImage("assets/sprites/MenuBoss.png")
	self.image2 = love.graphics.newImage("assets/sprites/annad.png")
	self.image:setFilter('nearest')
	self.image2:setFilter('nearest')

	self.tuto = love.graphics.newImage("assets/tutoriel.png")
	self.tuto:setFilter('nearest')

	self.onTuto = false
end

function TitleScreen:update(dt)
	if mouse:isReleased(1) or keyboard:isReleased("return") then
		if self.onTuto then
			engine:screen_setNext(GameScreen:new())
		else
			self.onTuto = true
		end
	end
end

function TitleScreen:draw()
	if self.onTuto then
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(self.tuto,0,0)
	else
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(self.image,0,200, 0, 8, 8, 0, 0)
		love.graphics.draw(self.image2,500,300, 0, 4, 4, 0 , 0)

		love.graphics.setColor(0,0,0)
		love.graphics.setFont(engine.font14)
		love.graphics.setColor(255,255,255)
		love.graphics.printf("ENTIRE GAME ON ONE SCREEN - LD31", WINDOW_WIDTH-300, WINDOW_HEIGHT-40, 300, "right")
		love.graphics.printf("A Game made by Goutye", WINDOW_WIDTH-300, WINDOW_HEIGHT-20, 300, "right")
		love.graphics.setFont(engine.fontTitle)
		engine:printOutLine("THE VINDICITE\n      SNOWMAN", 20,20)
		love.graphics.setColor(255,255,255)

		love.graphics.setFont(engine.defaut)
	end
end

function TitleScreen:onQuit()
end

return TitleScreen