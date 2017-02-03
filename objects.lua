function draw_player()
	love.graphics.draw(player.sprite, player.x - camera.x, player.y - camera.y)
end

function draw_objects()
	for i = 1, #objects do
		x = objects[i].x
		y = objects[i].y
		local sprite_id = objects[i].gid
		local tile = tiles[sprite_id].sprite
		love.graphics.draw(sprite_sheet, tile, x - camera.x, y - camera.y)
	end
end

function draw_npcs()
	for i = 1, #npcs.list do
		-- todo: handle collisions in NPC movement
		npc = npcs.list[i]
		x = npc.x
		y = npc.y
		npc.x = npc.x + npc.velX
		npc.y = npc.y + npc.velY
		local sprite_id = npcs.list[i].gid - npcs.sprite_first_gid + 1 -- remember Lua starts indices at 1...
		local sprite = npcs.sprites[sprite_id].sprite
		love.graphics.draw(npcs.sprite_sheet, sprite, x - camera.x, y - camera.y)
	end
end

function get_player_hitbox(x,y)
	return {
		x = player.x + player.overlapX,
		y = player.y + player.overlapY,
		w = player.width - player.overlapX * 2,
		h = player.height - player.overlapY,
	}
end