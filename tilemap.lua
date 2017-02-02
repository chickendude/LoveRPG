-- functions to manipulate the tilemap

function load_map(tilemap_name)
	tilemap_data = tilemaps[tilemap_name]

	tilemap.width = tilemap_data.layers[1].width
	tilemap.height = tilemap_data.layers[1].height
	for i = 1, #tilemap_data.layers - 1 do
		tilemap.layer[i] = tilemap_data.layers[i]
	end
	objects = tilemap_data.layers[#tilemap_data.layers].objects -- load objects
	-- load tile images
	local tile_data = tilemap_data.tilesets[1]
	local tile_count = tile_data.tilecount
	tiles = tile_data.tiles
	sprite_sheet = love.graphics.newImage("maps/" .. tile_data.image)
	for i = 1, tile_count do
		local x = ((i - 1) * 16) % tile_data.imagewidth
		local y = math.floor((i - 1) * 16 / tile_data.imagewidth) * 16
		tiles[i].sprite = love.graphics.newQuad(x, y, 16, 16, sprite_sheet:getDimensions())
	end
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
	for i = 1, #objects do
		local x2 = objects[i].x
		local y2 = objects[i].y
		local w2 = objects[i].width
		local h2 = objects[i].height

		if x < x2 + w2 and
				x2 < x + width and
				y < y2 + h2 and
				y2 < y + height then

			if objects[i].type == "warp" then
				player.x = objects[i].properties["x"] * 16
				player.y = objects[i].properties["y"] * 16 - 8
				load_map(objects[i].properties["map"])
				return
			end
		end
	end
end