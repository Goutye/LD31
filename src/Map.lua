local class = require 'middleclass'

local Map = class('Map')
local Tileset = require 'Tileset'

function Map:initialize(id, arenaMode)
	local image = nil
	
	self.id = id

	if arenaMode ~= nil then
		self.arenaMode = true
		image = love.image.newImageData("assets/map/arena"..id..".png")
		self.id = 2+self.id
	else
		self.arenaMode = false
		image = love.image.newImageData("assets/map/map"..id..".png")
	end
	local r,g,b

	self.tileset = Tileset:new()
	self.h = image:getHeight()
	self.w = image:getWidth()
	self.map = {}
	self.image = {}
	self.image.x = nil 
	self.image.y = nil

	self.area = {}
	self.areaGoal = {}
	for i = 0, 3 do
		self.area[i] = 0
		self.areaGoal[i] = 0
	end
	if self.id == 1 then
		self.area[0] = 1
		self.areaGoal[0] = 1
	else
		self.arena = 0
	end

	if not self.arenaMode then
		if self.id == 1 then
			self:load1(image)
		elseif self.id == 2 then
			self:load2(image)
		end
	else
		if self.id == 3 then
			self.arena = 0
			self:loadArena1(image)
		elseif self.id == 2 then
			self:load2(image)
		end
	end
end

function Map:load1(image)
	for i = 0, self.w-1 do
		self.map[i] = {}

		for j = 0, self.h-1 do
			r,g,b,_ = image:getPixel(i,j)

			self.map[i][j] = 0

			if r == 200 and g == 200 and b == 200 then
				self.map[i][j] = 0;
			elseif r ==0 and g ==100 and b ==0 then
				self.map[i][j] = 2;
			elseif r ==0 and g ==0 and b ==100 then
				self.map[i][j] = 1;
			elseif r ==100 and g ==100 and b ==200 then
				self.map[i][j] = 3;
			elseif r ==100 and g ==200 and b ==200 then
				self.map[i][j] = 4;
			elseif r ==0 and g ==0 and b ==0 then
				self.map[i][j] = 7;
			elseif r ==100 and g ==100 and b ==100 then
				self.map[i][j] = 5;
			elseif r ==111 and g ==111 and b ==111 then
				self.map[i][j] = 6;
			elseif r ==100 and g ==0 and b ==0 then
				self.map[i][j] = 8;
			elseif r ==255 and g ==255 and b ==255 then
				self.map[i][j] = 9;
			elseif r ==0 and g ==0 and b ==50 then
				self.map[i][j] = 10
			elseif r ==0 and g ==50 and b ==0 then
				self.map[i][j] = 11
			elseif r ==50 and g==0 and b ==0 then
				self.map[i][j] = 12
			else
				self.map[i][j] = 0
			end
		end
	end
end

function Map:load2(image)
	for i = 0, self.w-1 do
		self.map[i] = {}

		for j = 0, self.h-1 do
			r,g,b,_ = image:getPixel(i,j)

			self.map[i][j] = 0

			if r == 200 and g == 200 and b == 200 then
				self.map[i][j] = 1;
			elseif r ==0 and g ==100 and b ==0 then
				self.map[i][j] = 2;
			elseif r ==0 and g ==0 and b ==100 then
				self.map[i][j] = 3;
			elseif r ==0 and g ==200 and b ==0 then
				self.map[i][j] = 5;
			elseif r ==0 and g ==0 and b ==200 then
				self.map[i][j] = 7;
			elseif r ==111 and g ==111 and b ==111 then
				self.map[i][j] = 6;
			elseif r ==100 and g ==0 and b ==0 then
				self.map[i][j] = 8;
			elseif r ==255 and g ==255 and b ==255 then
				self.map[i][j] = 0;
			elseif r ==0 and g ==0 and b ==50 then
				self.map[i][j] = 4
			else
				self.map[i][j] = 0
			end
		end
	end
end

function Map:loadArena1(image)
	for i = 0, self.w-1 do
		self.map[i] = {}

		for j = 0, self.h-1 do
			r,g,b,_ = image:getPixel(i,j)

			self.map[i][j] = 0

			if r == 0 and g == 0 and b == 100 then
				self.map[i][j] = 8;
			elseif r ==255 and g ==255 and b ==255 then
				self.map[i][j] = 0;
			elseif r ==255 and g ==0 and b ==0 then
				self.map[i][j] = 2;
			elseif r ==255 and g ==255 and b ==0 then
				self.map[i][j] = 1;
			elseif r ==0 and g ==255 and b ==0 then
				self.map[i][j] = 3;
			else
				self.map[i][j] = 0
			end
		end
	end
end


function Map:update(dt)
	for i = 0, 3 do
		if self.area[i] > self.areaGoal[i] then
			self.area[i] = self.area[i] - dt
			if self.area[i] <= 0 then
				self.area[i] = self.areaGoal[i]
			end
		elseif self.area[i] < self.areaGoal[i] then
			self.area[i] = self.area[i] + dt
			if self.area[i] >= 1 then
				self.area[i] = self.areaGoal[i]
			end
		end
	end
end

function Map:draw()
	if self.arenaMode then
		self:drawArena()
	else
		if self.id == 1 then
			self:drawArea(3, self.area[3])
			for i = 0, 2 do
				self:drawArea(i, self.area[i])
			end
		else
			self:drawArea(3, self.area[3])
		end
	end
end

function Map:drawArea(id, percent)
	local nbTile = {}
	nbTile.x = math.floor(WINDOW_WIDTH /Tileset.TILESIZE)
	nbTile.y = math.floor(WINDOW_HEIGHT /Tileset.TILESIZE)+1
	love.graphics.setColor(255 * percent, 255 * percent, 255 * percent)
	if id == 0 then
		for i = 0, 4 do
			for j = 15, nbTile.y do
				if posTile.x + i >= 0 and posTile.y + j >= 0 and posTile.x + i < self.w and posTile.y < self.h then
					self.tileset:drawTile(self.id, self.map[posTile.x + i][posTile.y + j], (posTile.x + i)*Tileset.TILESIZE, (posTile.y + j)*Tileset.TILESIZE)
				end
			end
		end 
	elseif id == 1 then
		for i = 0, 3 do
			for j = 0, 14 do
				if posTile.x + i >= 0 and posTile.y + j >= 0 and posTile.x + i < self.w and posTile.y < self.h then
					self.tileset:drawTile(self.id, self.map[posTile.x + i][posTile.y + j], (posTile.x + i)*Tileset.TILESIZE, (posTile.y + j)*Tileset.TILESIZE)
				end
			end
		end
	elseif id == 2 then
		for i = 21, 24 do
			for j = 0, 15 do
				if posTile.x + i >= 0 and posTile.y + j >= 0 and posTile.x + i < self.w and posTile.y < self.h then
					self.tileset:drawTile(self.id, self.map[posTile.x + i][posTile.y + j], (posTile.x + i)*Tileset.TILESIZE, (posTile.y + j)*Tileset.TILESIZE)
				end
			end
		end
	else
		self:drawArena()
	end
	love.graphics.setColor(255,255,255)
end

function Map:drawArena()
	local nbTile = {}
	nbTile.x = math.floor(WINDOW_WIDTH /Tileset.TILESIZE)
	nbTile.y = math.floor(WINDOW_HEIGHT /Tileset.TILESIZE)+1

	posTile = {}
	posTile.x = 0
	posTile.y = 0

	if self.arena == 0 then 
		for i = 0, nbTile.x do
			for j = 0, nbTile.y do
				if posTile.x + i >= 0 and posTile.y + j >= 0 and posTile.x + i < self.w and posTile.y < self.h then
					self.tileset:drawTile(self.id, self.map[posTile.x + i][posTile.y + j], (posTile.x + i)*Tileset.TILESIZE, (posTile.y + j)*Tileset.TILESIZE)
				end
			end
		end
	end
end


function Map:areaFadeIn(id)
	self.areaGoal[id] = 1
end

function Map:areaFadeOut(id)
	self.areaGoal[id] = 0
end

return Map