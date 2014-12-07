local class = require 'middleclass'

local Items = class('Items')

Items.static.SORT = {{name = 'Interruptball', coutMana = 5, damage = 2, castTime = 0.5, canInterrupt = true},
					{name = 'Divine Prayer', coutMana = 10, damage = 10, castTime = 5, canInterrupt = false}}
Items.static.DIST = {{name = 'Shield', coutMana = 0, resistance = 2},
					{name = 'Fireball', coutMana = 5, damage = 5, castTime = 1, canInterrupt = false}}
Items.static.HAND = {{name = 'Dagger', damage = 2, castTime = 0.2, canInterrupt = false},
					{name = 'Sword', damage = 8, castTime = 1, canInterrupt = false}}

function Items:initialize()
end

function Items:update(dt)
end

function Items:getRandomSort(i)
	item = nil
	repeat
		item = Items.SORT[love.math.random(1,#Items.SORT)]
	until i == nil or item.name ~= i.name
	return item
end

function Items:getRandomDist(i)
	item = nil
	repeat
		item = Items.DIST[love.math.random(1,#Items.DIST)]
	until i == nil or item.name ~= i.name
	return item
end

function Items:getRandomHand(i)
	item = nil
	repeat
		item = Items.HAND[love.math.random(1,#Items.HAND)]
	until i == nil or item.name ~= i.name
	return item
end

function Items:draw()
end

function Items:onQuit()
end

return Items