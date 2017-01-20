require "tilemap"
require "objects"

-- INIT
camera = {}
function love.load(arg)
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	camera.x = 0
	camera.y = 0
	camera.width = 16 * 20
	camera.height = 16 * 16
	love.window.setMode(camera.width, camera.height)
end

-- DATA -------------------------------------------------
tilemap_data = require "maps/demoland"
tilemap = tilemap_data.layers[1]
objects = tilemap_data.layers[#tilemap_data.layers].objects -- load objects
print(objects[1].x)
-- load tile images
local tile_data = tilemap_data.tilesets[1]
sprite_sheet = love.graphics.newImage("maps/" .. tile_data.image)
local tile_count = tile_data.tilecount
tiles = tile_data.tiles
for i = 1, tile_count do
	local x = ((i - 1) * 16) % tile_data.imagewidth
	local y = math.floor((i - 1) * 16 / tile_data.imagewidth) * 16
	tiles[i].sprite = love.graphics.newQuad(x, y, 16, 16, sprite_sheet:getDimensions())
end

-- player data
player = {
	x = 3 * 16,
	y = 3 * 16,
	direction = "down",
	overlapY = 14, -- how many pixels of player's head overlap a tile
	overlapX = 2, -- how many pixels of player's side overlap a tile
	height = 24,
	width = 16,
	sprite = love.graphics.newImage("maps/character.png")
}

-- KEYS -------------------------------------------------
key_bindings = {
	quit = function() love.event.quit() end,
	moveUp = function() move_up(speed) end, -- [tilemap.lua]
	moveDown = function() move_down(speed) end, -- [tilemap.lua]
	moveLeft = function() move_left(speed) end, -- [tilemap.lua]
	moveRight = function() move_right(speed) end, -- [tilemap.lua]
}

key_actions = {
	escape = "quit",
	up = "moveUp",
	down = "moveDown",
	left = "moveLeft",
	right = "moveRight",
}

keys_pressed = {}

-- CODE -------------------------------------------------
function love.draw()
	draw_map() -- [tilemap.lua]
	draw_objects() -- [objects]
end

function love.update(dt)
	speed = 200 * dt
	check_keys(speed)
	update_camera() -- [tilemap.lua]
end

function love.keypressed(key)
	if key_actions[key] ~= nil then
		keys_pressed[key] = true
	end
end

function love.keyreleased(key)
	if key_actions[key] ~= nil then
		keys_pressed[key] = false
	end
end

function check_keys(speed)
	for key, is_pressed in pairs(keys_pressed) do
		if is_pressed then
			local key_binding = key_actions[key]
			handle_input(key_binding, speed)
		end
	end
end

function handle_input(key_binding, speed)
	local action = key_bindings[key_binding]
	if action then
		return action(speed)
	end
end