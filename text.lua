-- file: text.lua - text routine


function draw_text(text, x, y , limit, align)
  align = align or "left"
  love.graphics.printf(text, x, y, limit, align)
end

function draw_box(x, y, width, height, mode, rgba)
  mode = mode or "fill"
  rgba = rgba or {10,10,230,255} -- some shade of blue
  love.graphics.setColor(rgba)
  love.graphics.rectangle(mode, x, y, width, height)
end

function draw_dialoguebox(text)
  text = text or " "
  local bh = 8*4
  local tw = camera.width - 16
  local colour = {255,255,0,255}
  draw_box(0,camera.height - bh ,camera.width, camera.height - bh, colour)
  draw_text(text, 0, camera.height - bh, tw)
end

function draw_menubox(menu)
  menu = menu or " "
  local colour = {0,0,0,255}
  local mbw = 8*16
  draw_box(camera.width-mbw, mbw, camera.height, colour)
end
