local class = require 'middleclass'

local EndScreen = class('EndScreen')

function EndScreen:initialize(GS)
	self.GS = GS
	self.win = true
	self.sentence = "THANKS\nFOR\nPLAYING !"

	if self.win then
		--love.audio.play(engine.music.win)
	else
		--love.audio.play(engine.music.lose)
	end
end

function EndScreen:update(dt)
	if mouse:isReleased("l") then
		engine:screen_setNext(TitleScreen:new())
	end
end

function EndScreen:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 0 , 0, WINDOW_WIDTH, WINDOW_HEIGHT)
	love.graphics.setColor(255,255,255)
	love.graphics.printf("Complete the Frozen introdution and keeping his ears alive : ", 50, 100, 500)
	love.graphics.printf("Build The Snowman : ", 50, 150, 300)
	love.graphics.printf("Defeat The Snowman : ", 50, 200, 300)
	--love.graphics.printf("Lose, try again and defeat The Snowman : ", 50, 250)
	love.graphics.setFont(engine.font60)
	if self.GS.player.hasSpokenToElsa and self.GS.player.hasSpokenToPoupee and not self.GS.player.isDeadByRide then
		engine:printOutLineGreen("SUCCESS", 420, 50)
	else
		engine:printOutLineRed("FAILED", 540, 50)
	end
	if self.GS.player.hasBuiltTheSnowman then
		engine:printOutLineGreen("SUCCESS", 280, 100)
	else
		engine:printOutLineRed("FAILED", 280, 100)
	end
	if self.GS.player.defeatTheSnowman then
		engine:printOutLineGreen("SUCCESS", 250, 150)
	else
		engine:printOutLineRed("FAILED", 250, 150)
	end

	love.graphics.setFont(engine.fontTitle)
	love.graphics.print(self.sentence, WINDOW_WIDTH/2- 130, 330, math.rad(-15))

	love.graphics.setFont(engine.font14)
	--Stat
	if self.GS.tournament ~= nil then
		love.graphics.printf("Victory : " .. self.GS.tournament.victory, 50, 300, 200)
		love.graphics.printf("Lose : " .. (self.GS.tournament.lose.int + self.GS.tournament.lose.str), 50, 350, 200)
	end
end

function EndScreen:onQuit()
end

return EndScreen