-- MAIN GAME
function maingame_draw()
  draw_map() -- [tilemap.lua]
  draw_objects() -- [objects]
  draw_map_foreground() -- [tilemap.lua]
end

function maingame_update(dt)
  speed = 200 * dt
  update_camera() -- [tilemap.lua]
end

-- DIALOG
function dialog_draw()
  if dialog_timer <= 0 then
    draw_dialog_text() -- [text.lua]
  end
end

function dialog_update(dt)
  dialog_update_timer(dt) -- [text.lua]
end