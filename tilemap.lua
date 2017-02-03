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
			objects = tilemap_data.layers[i].objects -- load objects
		elseif type == "npcs" then
			npcs.list = tilemap_data.layers[i].objects -- load npcs
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
	check_action(player.x, player.y - speed)
	if check_passable(player.x + player.overlapX, player.y + player.overlapY - speed) and
			check_passable(player.x + player.width - player.overlapX - 1, player.y + player.overlapY - speed) then
		player.y = math.max(player.y - speed, 0)
	else
		player.y = math.floor(player.y / 16) * 16 + 16 - player.overlapY
	end
end

function move_down(speed)
	player.direction = "down"
	check_action(player.x, player.y + speed)
	if check_passable(player.x + player.overlapX, player.y + player.height + speed) and
			check_passable(player.x + player.width - player.overlapX - 1, player.y + player.height + speed) then
		player.y = math.min(player.y + speed, tilemap.height * 16 - player.height)
	else
		player.y = math.floor((player.y + player.height + speed) / 16) * 16 - player.height
	end
end

function move_left(speed)
	check_action(player.x - speed, player.y)
	player.direction = "left"
	if check_passable(player.x + player.overlapX - speed, player.y + player.overlapY + 1) and
			check_passable(player.x + player.overlapX - speed, player.y + player.height - 1) then
		player.x = math.max(player.x - speed, 0)
	else
		player.x = math.floor((player.x - speed) / 16) * 16 + player.width - player.overlapX
	end
end

function move_right(speed)
	check_action(player.x + speed, player.y)
	player.direction = "right"
	if check_passable(player.x + player.width - player.overlapX + speed, player.y + player.overlapY + 1) and
			check_passable(player.x + player.width - player.overlapX + speed, player.y + player.height - 1) then
		player.x = math.min(player.x + speed, tilemap.width * 16 - player.width)
	else
		player.x = math.floor((player.x + speed) / 16) * 16 + player.overlapX
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

function check_passable(x, y)
	y = math.floor(y / 16)
	x = math.floor(x / 16) + 1 -- because indices start at 1 *facepalm*

	passable = true
	for i = 1, #tilemap.layer do
		print(i)
		local tile_id = tilemap.layer[i].data[y * tilemap.width + x]
		if (tile_id ~= nil and tile_id ~= 0) then
			if not tiles[tile_id].properties["passable"] then
				passable = false
			end
		end
	end
	return passable
end

function check_action(x, y)
	y = y + player.overlapY
	x = x + player.overlapX
	local width = player.width - player.overlapX * 2
	local height = player.height - player.overlapY
	for i = 1, #actions do
		local x2 = actions[i].x
		local y2 = actions[i].y
		local w2 = actions[i].width
		local h2 = actions[i].height

		if x < x2 + w2 and
				x2 < x + width and
				y < y2 + h2 and
				y2 < y + height then

			if actions[i].type == "warp" then
				player.x = actions[i].properties["x"] * 16
				player.y = actions[i].properties["y"] * 16 - 8
				load_map(actions[i].properties["map"])
				return
			end
		end
	end
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