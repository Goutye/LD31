local class = require 'middleclass'

local Music = class('Music')

function Music:initialize()
	self.anna = {}
	self.anna['begin'] = love.audio.newSource("assets/music/AnnaBegin.ogg")
	self.anna['beginP2'] = love.audio.newSource("assets/music/anna.ogg")
	self.anna['ride'] = love.audio.newSource("assets/music/annaRide.ogg")
	self.anna['toctoc'] = love.audio.newSource("assets/music/toctoc.ogg")
	self.anna.elsa = love.audio.newSource("assets/music/elsa.ogg")
	self.anna.poupee = love.audio.newSource("assets/music/poupee.ogg")


	self.sfx = {}
	self.sfx.cast = love.audio.newSource("assets/sfx/cast.wav")
	self.sfx.explode = love.audio.newSource("assets/sfx/explode.wav")
	self.sfx.fire = love.audio.newSource("assets/sfx/fire.wav")
	self.sfx.projectile = love.audio.newSource("assets/sfx/projectile.wav")
	self.sfx.hit = love.audio.newSource("assets/sfx/hit.wav")
	self.sfx.sword = love.audio.newSource("assets/sfx/sword.wav")
	

	self.main = {}
	self.asset = {}
	self.mainid = 1
	self.oldid = 1
	self.assetid = 1
	self.nextMusic = false

	self.debut = love.audio.newSource("assets/music/music_neige.ogg")
	self.debut:setLooping(true)
	self.debut:play()

	for i = 1,3 do
		self.main[i] = love.audio.newSource("assets/music/main"..i..".ogg")
		self.main[i]:setLooping(false)
		self.main[i]:setVolume(0.2)
	end
	for i = 1,2 do
		self.asset[i] = love.audio.newSource("assets/music/asset"..i..".ogg")
		self.asset[i]:setLooping(false)
		self.asset[i]:setVolume(0.2)
	end
	for _,e in pairs(self.anna) do
	end

	self.arena = false
end

function Music:update(dt)
	if engine.screen.arenaMode then
		if not self.arena then
			self.arena = true
			self.debut:stop()
		end
		if self.main[self.oldid]:isPlaying() then
		else
			self.nextMusic = false
			self:playRandom()
		end
	else
		local bool = false
		for _,e in pairs(self.anna) do
			if e:isPlaying() then
				bool = true
			end
		end

		if bool then
			self.debut:setVolume(0.1)
			engine.screen.player.canMove = false
		elseif not self.hasBuiltTheSnowman then
			self.debut:setVolume(1)
			if engine.screen.player ~= nil then
				engine.screen.player.canMove = true
			end
		end
	end
end

function Music:next()
	self.main[self.mainid]:setLooping(false)
	self.asset[self.assetid]:setLooping(false)
	self.nextMusic = true
end

function Music:playRandom()
	self.oldid = self.mainid
	local i
	repeat
		i = love.math.random(1,3)
	until self.mainid ~= i
	self.mainid = i
	self.assetid = love.math.random(1,2)
	repeat
		i = love.math.random(1,2)
	until self.assetid ~= i
	self.mainid = i
	self.main[self.mainid]:play()
	self.main[self.mainid]:setLooping(true)
	self.asset[self.assetid]:play()
	self.asset[self.assetid]:setLooping(true)
end

function Music:draw()
end

function Music:onQuit()
end

return Music