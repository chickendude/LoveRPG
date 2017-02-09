-- file: text.lua - text routine


function draw_text(text, x, y, limit, align)
  align = align or "left"
  love.graphics.setColor{0, 0, 0, 255 }
  love.graphics.printf(text, x, y, limit, align)
end

function draw_box(x, y, width, height, rgba, mode)
  rgba = rgba or { 10, 10, 230, 255 } -- some shade of blue
  mode = mode or "fill"
  love.graphics.setColor(rgba)
  love.graphics.rectangle(mode, x, y, width, height)
end

function draw_dialoguebox(text)
  gamestate = gamestates.dialog
  text = text or " "
  local box_h = 8 * 4
  local text_w = camera.width - 16
  local colour = { 255, 155, 50, 255 }
--  draw_box(0, camera.height - box_h, camera.width, box_h, colour)
  draw_text(text, 0, camera.height - box_h, text_w)
end

function draw_menubox(menu)
  menu = menu or " "
  local colour = { 0, 0, 0, 255 }
  local mbw = 8 * 16
  draw_box(camera.width - mbw, mbw, camera.height, colour)
end

function open_demo_text_box()
  draw_dialoguebox("hello!")
end