package.path = package.path .. ';src/?.lua'
package.path = package.path .. ';lib/?.lua'

local Mouse = require 'Mouse'
local Keyboard = require 'Keyboard'
local Engine = require 'Engine'

--SCREEN
GameScreen = require 'screen.GameScreen'
--MenuScreen = require 'screen.MenuScreen'
TitleScreen = require 'screen.TitleScreen'
--EndScreen = require 'screen.EndScreen'

--LOCAL VARIABLE
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
keyboard = Keyboard:new()
mouse = Mouse:new()
engine = nil

love.window.setTitle("LD31")
love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
love.graphics.setBackgroundColor(180, 230, 255)

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function love.load()
	engine = Engine:new()
	engine.screen = TitleScreen:new()
end
function love.update(dt)
	engine:update(dt)

	mouse:reset()
	keyboard:reset()
end

function love.draw()
	engine:draw()
	--love.graphics.print("FPS : "..love.timer.getFPS(), WINDOW_WIDTH/2- 130, 10)
end

function love.keypressed(key)
	keyboard:keyPressed(key)
end

function love.keyreleased(key)
	keyboard:keyReleased(key)
end

function love.mousepressed(x, y, button)
    mouse:buttonPressed(x,y,button)
end

function love.mousereleased(x, y, button)
    mouse:buttonReleased(x,y,button)
end