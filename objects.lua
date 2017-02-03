function draw_player()
	love.graphics.draw(player.sprite, player.x - camera.x, player.y - camera.y)
end

function draw_objects()
	for i = 1, #objects do
		x = objects[i].x
		y = objects[i].y
		--		love.graphics.draw(player.sprite, x - camera.x, y - camera.y)
	end
end

function draw_npcs()
	for i = 1, #npcs.list do
		-- todo: update NPC movement
		x = npcs.list[i].x
		y = npcs.list[i].y
		local sprite_id = npcs.list[i].gid - npcs.sprite_first_gid + 1 -- remember Lua starts indices at 1...
		local sprite = npcs.sprites[sprite_id].sprite
		love.graphics.draw(npcs.sprite_sheet, sprite, x - camera.x, y - camera.y)
	end
end