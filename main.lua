require "src.tilemap"
require "src.text"
require "src.objects"
require "src.states"
require "src.menu"

-- INIT
camera = {}
gamestate = nil
function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  camera.x = 0
  camera.y = 0
  camera.width = 16 * 20
  camera.height = 16 * 16
  love.window.setMode(camera.width, camera.height)
  gbuf = love.graphics.newCanvas(camera.width, camera.height)
  gamestate = gamestates.maingame
  font = love.graphics.setNewFont('font/LiberationMono-Regular.ttf', 12)
end

-- DATA -------------------------------------------------
tilemaps = {
  demoland = require "maps/demoland",
  demoland_house1 = require "maps/demoland_house1",
}
reset_map_defaults() -- [tilemap.lua]
load_map("demoland") -- [tilemap.lua]

-- menu
menu_options = {"Items", "Equipment", "Stats", "Exit"}

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
keys_pressed = {}

gamestates = {
  intro = {},
  menu = {
    draw = menu_draw,
    update = menu_update,
    key_bindings = {
      quit = function() love.event.quit() end,
      quitMenu = function() quit_menu() end,
    },
    key_actions = {
      escape = "quit",
      z = "quitMenu",
    }
  },
  dialog = {
    draw = dialog_draw,
    update = dialog_update,
    key_bindings = {
      quit = function() love.event.quit() end,
      confirm = function() dialog_confirm() end,
      cancel = function() dialog_cancel() end,
    },
    key_actions = {
      escape = "quit",
      x = "confirm",
      z = "cancel",
    }
  },
  maingame = {
    draw = maingame_draw,
    update = maingame_update,
    key_bindings = {
      quit = function() love.event.quit() end,
      moveUp = function() move_up(speed) end, -- [tilemap.lua]
      moveDown = function() move_down(speed) end, -- [tilemap.lua]
      moveLeft = function() move_left(speed) end, -- [tilemap.lua]
      moveRight = function() move_right(speed) end, -- [tilemap.lua]
      openTextBox = function() open_demo_text_box() end, -- [text.lua]
      openMenu = function() open_menu() end, -- [menu.lua]
    },
    key_actions = {
      escape = "quit",
      up = "moveUp",
      down = "moveDown",
      left = "moveLeft",
      right = "moveRight",
      x = "openTextBox",
      ["return"] = "openMenu",
    }
  },
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
  check_keys(dt)
end

function love.keypressed(key)
  if gamestate.key_actions[key] ~= nil then
    keys_pressed[key] = true
  end
end

function love.keyreleased(key)
  if keys_pressed[key] ~= nil then
    keys_pressed[key] = false
  end
end

function check_keys(speed)
  for key, is_pressed in pairs(keys_pressed) do
    if is_pressed then
      local key_binding = gamestate.key_actions[key]
      handle_input(key_binding, speed)
    end
  end
end

function handle_input(key_binding, speed)
  local action = gamestate.key_bindings[key_binding]
  if action then
    return action(speed)
  end
end
