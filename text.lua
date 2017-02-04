-- file: text.lua - text routine


function draw_text(text, x, y , limit, align)
  align = align or "left"
  love.graphics.printf(text, x, y, limit, align)
end

function draw_box(x, y, width, height, mode)
  mode = mode or "fill"
  love.graphics.rectangle(mode, x, y, width, height)
end

function draw_dialoguebox(text)
  local bh = 8*4
  local tw = camera.width - 16

  draw_box(0,camera.height - bh ,camera.width, camera.height - bh)
  draw_text(text, 0, camera.height - bh, tw)
end
