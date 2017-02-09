-- MAIN GAME
function maingame_draw()
  draw_map() -- [tilemap.lua]
  draw_objects() -- [objects]
  draw_map_foreground() -- [tilemap.lua]
end

function maingame_update(dt)
  speed = 200 * dt
  check_keys(speed)
  update_camera() -- [tilemap.lua]
end

-- DIALOG
dialog_text = ''
function dialog_draw()
  draw_dialoguebox(dialog_text)
end

function dialog_update()
  a = 1
end