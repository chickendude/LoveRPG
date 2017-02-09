require "tilemap"
require "text"
require "objects"
require "states"

-- INIT
camera = {}
function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  camera.x = 0
  camera.y = 0
  camera.width = 16 * 20
  camera.height = 16 * 16
  love.window.setMode(camera.width, camera.height)
  gbuf = love.graphics.newCanvas(camera.width, camera.height)
  gamestate = gamestates.maingame
end

-- DATA -------------------------------------------------
tilemaps = {
  demoland = require "maps/demoland",
  demoland_house1 = require "maps/demoland_house1",
}
reset_map_defaults() -- [tilemap.lua]
load_map("demoland") -- [tilemap.lua]

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
  openTextBox = function() open_demo_text_box() end -- [text.lua]
}

key_actions = {
  escape = "quit",
  up = "moveUp",
  down = "moveDown",
  left = "moveLeft",
  right = "moveRight",
  x = "openTextBox",
}

keys_pressed = {}

gamestates = {
  intro = {},
  menu = {},
  dialog = {draw = dialog_draw, update = dialog_update},
  maingame = {draw = maingame_draw, update = maingame_update},
}

-- CODE -------------------------------------------------
function love.draw()
  gbuf:renderTo(function()
    gamestate.draw()
  end)
  love.graphics.setColor(255, 255, 255);
  love.graphics.draw(gbuf)
end

function love.update(dt)
  gamestate.update(dt)
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