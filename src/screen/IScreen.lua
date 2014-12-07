local class = require 'middleclass'

local IScreen = class('IScreen')

function IScreen:initialize()
end

function IScreen:update(dt)
end

function IScreen:draw()
end

function IScreen:onQuit()
end

return IScreen