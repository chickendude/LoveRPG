function draw_player()
	love.graphics.draw(player.sprite, player.x - camera.x, player.y - camera.y)
end

-- objects and npcs get stored with y pointing to the bottom of the sprite, not the top, so we have to account for this
function draw_objects()
	for i = 1, #objects do
		x = objects[i].x
		y = objects[i].y - objects[i].height
		local sprite_id = objects[i].gid
		local tile = tiles[sprite_id].sprite
		love.graphics.draw(sprite_sheet, tile, x - camera.x, y - camera.y)
	end
end

-- objects and npcs get stored with y pointing to the bottom of the sprite, not the top, so we have to account for this
function draw_npcs()
	for i = 1, #npcs.list do
		-- todo: update NPC movement
		x = npcs.list[i].x
		y = npcs.list[i].y - npcs.list[i].height
		local sprite_id = npcs.list[i].gid - npcs.sprite_first_gid + 1 -- remember Lua starts indices at 1...
		local sprite = npcs.sprites[sprite_id].sprite
		love.graphics.draw(npcs.sprite_sheet, sprite, x - camera.x, y - camera.y)
	end
end