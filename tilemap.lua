-- functions to manipulate the tilemap

function load_map(tilemap_name)
  reset_map_defaults()

  tilemap_data = tilemaps[tilemap_name]

  tilemap.width = tilemap_data.layers[1].width
  tilemap.height = tilemap_data.layers[1].height
  for i = 1, #tilemap_data.layers do
    local type = tilemap_data.layers[i].name
    if type == "actions" then
      actions = tilemap_data.layers[i].objects -- load map actions
    elseif type == "objects" then
      -- objects and npcs get stored with y pointing to the bottom of the sprite, not the top, so we have to account for this
      local obj_objects = tilemap_data.layers[i].objects -- load npcs
      for j = 1, #obj_objects do
        objects[j] = {}
        objects[j].x = obj_objects[j].x
        objects[j].y = obj_objects[j].y - obj_objects[j].height
        objects[j].width = obj_objects[j].width
        objects[j].height = obj_objects[j].height
        objects[j].gid = obj_objects[j].gid
      end
    elseif type == "npcs" then
      local npc_objects = tilemap_data.layers[i].objects -- load npcs
      for j = 1, #npc_objects do
        npcs.list[j] = {}
        npcs.list[j].x = npc_objects[j].x
        npcs.list[j].y = npc_objects[j].y - npc_objects[j].height
        npcs.list[j].width = npc_objects[j].width
        npcs.list[j].height = npc_objects[j].height
        npcs.list[j].gid = npc_objects[j].gid
        npcs.list[j].velX = 0
        npcs.list[j].velY = 0
      end
    else
      tilemap.layer[i] = tilemap_data.layers[i]
    end
  end

  -- load tile and npc sprites
  for i = 1, #tilemap_data.tilesets do
    local tileset = tilemap_data.tilesets[i]
    local results = get_sprites_from_spritesheet(tileset)
    if tileset.name == "tileset" then
      tiles = results[1]
      sprite_sheet = results[2]
    elseif tileset.name == "NPCs" then
      npcs.sprites = results[1]
      npcs.sprite_sheet = results[2]
      npcs.sprite_first_gid = tileset.firstgid
    end
  end
end

function get_sprites_from_spritesheet(tile_data)
  local tile_count = tile_data.tilecount
  local w = tile_data.grid.width
  local h = tile_data.grid.height
  local tile_list = tile_data.tiles
  local sprite_sheet = love.graphics.newImage("maps/" .. tile_data.image)
  for i = 1, tile_count do
    local x = ((i - 1) * w) % tile_data.imagewidth
    local y = math.floor((i - 1) * h / tile_data.imagewidth) * h
    tile_list[i].sprite = love.graphics.newQuad(x, y, w, h, sprite_sheet:getDimensions())
  end
  return { tile_list, sprite_sheet }
end

function draw_map_layer(layer)
  for y = 0, camera.height / 16 do
    local tileY = math.floor(camera.y / 16) + y
    local screenY = y * 16 - (camera.y % 16)
    for x = 0, camera.width / 16 do
      local tileX = math.floor(camera.x / 16) + x
      local screenX = x * 16 - camera.x % 16
      -- load tile from tilemap data, add one because lua starts indices at 1 (-_-)
      local tile_id = tilemap.layer[layer].data[(tileY * tilemap.width + tileX) + 1]
      if tiles[tile_id] ~= nil then
        local tile = tiles[tile_id].sprite
        love.graphics.draw(sprite_sheet, tile, screenX, screenY)
      end
    end
  end
end

function draw_map()
  for i = 1, #tilemap.layer do
    if tilemap.layer[i].name ~= "foreground" then
      draw_map_layer(i)
    end
  end
end

function draw_map_foreground()
  if tilemap.layer[#tilemap.layer].name == "foreground" then
    draw_map_layer(#tilemap.layer)
  end
end

function move_up(speed)
  player.direction = "up"
  hbox = get_player_hitbox()
  hbox.y = hbox.y - speed
  check_action(player.x, player.y - speed)
  if check_passable(hbox) then
    player.y = math.max(player.y - speed, 0)
  else
    --		player.y = math.floor(player.y)
  end
end

function move_down(speed)
  player.direction = "down"
  hbox = get_player_hitbox()
  hbox.y = hbox.y + speed
  check_action(player.x, player.y + speed)
  if check_passable(hbox) then
    player.y = math.min(player.y + speed, tilemap.height * 16 - player.height)
  else
    --		player.y = math.floor((player.y + player.height + speed) / 16) * 16 - player.height - 1
  end
end

function move_left(speed)
  check_action(player.x - speed, player.y)
  player.direction = "left"
  hbox = get_player_hitbox()
  hbox.x = hbox.x - speed
  check_action(player.x - speed, player.y)
  if check_passable(hbox) then
    player.x = math.max(player.x - speed, 0)
  else
    --		player.x = math.floor((player.x - speed) / 16) * 16 + player.width - player.overlapX
  end
end

function move_right(speed)
  check_action(player.x + speed, player.y)
  player.direction = "right"
  hbox = get_player_hitbox()
  hbox.x = hbox.x + speed
  check_action(player.x + speed, player.y)
  if check_passable(hbox) then
    player.x = math.min(player.x + speed, tilemap.width * 16 - player.width)
  else
    --		player.x = math.floor((player.x + speed) / 16) * 16 + player.overlapX - 1
  end
end

function update_camera()
  camera.x = math.max(0, (player.x + player.width / 2) - (camera.width / 2))
  camera.x = math.min(camera.x, tilemap.width * 16 - camera.width)
  camera.x = math.floor(camera.x)
  camera.y = math.max(0, (player.y + player.height / 2) - (camera.height / 2))
  camera.y = math.min(camera.y, tilemap.height * 16 - camera.height)
  camera.y = math.floor(camera.y)
end

function check_passable(hbox)
  passable = check_npc_collision(hbox) and check_object_collision(hbox)
  x1 = math.floor(hbox.x / 16) + 1
  x2 = math.floor((hbox.x + hbox.w) / 16) + 1
  y1 = math.floor(hbox.y / 16)
  y2 = math.floor((hbox.y + hbox.h) / 16)

  coords = {
    { x = x1, y = y1 },
    { x = x2, y = y1 },
    { x = x1, y = y2 },
    { x = x2, y = y2 },
  }

  for j = 1, #coords do
    x = coords[j].x
    y = coords[j].y
    for i = 1, #tilemap.layer do
      local tile_id = tilemap.layer[i].data[y * tilemap.width + x]
      if (tile_id ~= nil and tile_id ~= 0) then
        if not tiles[tile_id].properties["passable"] then
          passable = false
        end
      end
    end
  end
  return passable
end

function check_npc_collision(hbox)
  can_pass = true
  for i = 1, #npcs.list do
    npc = npcs.list[i]
    if check_collision(hbox.x, hbox.y, hbox.w, hbox.h, npc.x, npc.y + player.overlapY, npc.width, npc.height - player.overlapY) then
      can_pass = false
    end
  end
  return can_pass
end

function check_object_collision(hbox)
  can_pass = true
  for i = 1, #objects do
    object = objects[i]
    if check_collision(hbox.x, hbox.y, hbox.w, hbox.h, object.x, object.y, object.width, object.height) then
      can_pass = false
    end
  end
  return can_pass
end

function check_action(x, y)
  y = y + player.overlapY
  x = x + player.overlapX
  local width = player.width - player.overlapX * 2
  local height = player.height - player.overlapY
  for i = 1, #actions do
    if check_collision(x, y, width, height, actions[i].x, actions[i].y, actions[i].width, actions[i].height) then
      if actions[i].type == "warp" then
        player.x = actions[i].properties["x"] * 16
        player.y = actions[i].properties["y"] * 16 - 8
        load_map(actions[i].properties["map"])
        return
      end
    end
  end
end

function check_collision(x, y, w, h, x2, y2, w2, h2)
  return x < x2 + w2 and
      x2 < x + w and
      y < y2 + h2 and
      y2 < y + h
end

function reset_map_defaults()
  tilemap = {
    layer = {}
  }
  tiles = {}
  objects = {}
  npcs = {
    sprites = {},
    sprite_sheet = "",
    list = {},
  }
  actions = {}
end