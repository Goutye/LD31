local class = require 'middleclass'

local Tileset = class('Tileset')

Tileset.static.TILESIZE = 32

function Tileset:initialize()
	self.world = {}
	self.world[1] = {}
	self.world[2] = {}
	self.world[3] = {}

	self.world[1][0] = {tile = love.graphics.newImage("assets/tileset/house.png"), info = 0}
	self.world[1][1] = {tile = love.graphics.newImage("assets/tileset/walll.png"), info = 1}
	self.world[1][2] = {tile = love.graphics.newImage("assets/tileset/wallr.png"), info = 1}
	self.world[1][3] = {tile = love.graphics.newImage("assets/tileset/door.png"), info = 1}
	self.world[1][4] = {tile = love.graphics.newImage("assets/tileset/dooru.png"), info = 1}
	self.world[1][5] = {tile = love.graphics.newImage("assets/tileset/doord.png"), info = 1}
	self.world[1][6] = {tile = love.graphics.newImage("assets/tileset/doorout.png"), info = 1}
	self.world[1][7] = {tile = love.graphics.newImage("assets/tileset/wall.png"), info = 1}
	self.world[1][8] = {tile = love.graphics.newImage("assets/tileset/wallout.png"), info = 1}
	self.world[1][9] = {tile = love.graphics.newImage("assets/tileset/snow.png"), info = 0}
	self.world[1][10] = {tile = love.graphics.newImage("assets/tileset/corner.png"), info = 1}
	self.world[1][11] = {tile = love.graphics.newImage("assets/tileset/stair.png"), info = 2}
	self.world[1][12] = {tile = love.graphics.newImage("assets/tileset/staird.png"), info = 3}

	self.world[2][0] = {tile = love.graphics.newImage("assets/tileset/snow.png"), info = 0}
	self.world[2][1] = {tile = love.graphics.newImage("assets/tileset/roof.png"), info = 1}
	self.world[2][2] = {tile = love.graphics.newImage("assets/tileset/roofl.png"), info = 1}
	self.world[2][3] = {tile = love.graphics.newImage("assets/tileset/roofr.png"), info = 1}
	self.world[2][4] = {tile = love.graphics.newImage("assets/tileset/roofcorner.png"), info = 1}
	self.world[2][5] = {tile = love.graphics.newImage("assets/tileset/rooflcorner.png"), info = 1}
	self.world[2][6] = {tile = love.graphics.newImage("assets/tileset/doorout.png"), info = 1}
	self.world[2][7] = {tile = love.graphics.newImage("assets/tileset/roofrcorner.png"), info = 1}
	self.world[2][8] = {tile = love.graphics.newImage("assets/tileset/wallout.png"), info = 1}

	self.world[3][0] = {tile = love.graphics.newImage("assets/tileset/snow.png"), info = 0}
	self.world[3][1] = {tile = love.graphics.newImage("assets/tileset/roofbreak.png"), info = 1}
	self.world[3][2] = {tile = love.graphics.newImage("assets/tileset/debris.png"), info = 1}
	self.world[3][3] = {tile = love.graphics.newImage("assets/tileset/wallbreak.png"), info = 1}
	self.world[3][8] = {tile = love.graphics.newImage("assets/tileset/wallout.png"), info = 1}
end

function Tileset:drawTile(idWorld, idTile, x, y)
	love.graphics.draw(self.world[idWorld][idTile].tile, x, y)
end

function Tileset:getInfo(idWorld, idTile)
	return self.world[idWorld][idTile].info
end

return Tileset