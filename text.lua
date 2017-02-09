-- file: text.lua - text routine

function draw_text(text, x, y, limit, align)
  align = align or "left"
  limit = limit or camera.width
  love.graphics.setColor { 0, 90, 0, 255 }
  love.graphics.printf(text, x, y, limit, align)
end

function draw_box(x, y, width, height, rgba, mode)
  rgba = rgba or { 10, 10, 230, 255 } -- some shade of blue
  mode = mode or "fill"
  love.graphics.setColor(rgba)
  love.graphics.rectangle(mode, x, y, width, height)
end

function draw_dialoguebox()
  local box_h = 12 * 4
  local colour = { 255, 155, 50, 255 }
  draw_box(0, camera.height - box_h, camera.width, box_h, colour)
end

function draw_dialoguebox_letter(letter, col, row)
  local box_h = 12 * 4
  local x = col * 7
  local y = row * 12
  draw_text(letter, 4 + x, 6 + camera.height - box_h + y)
end

function draw_menubox(menu)
  menu = menu or " "
  local colour = { 0, 0, 0, 255 }
  local mbw = 8 * 16
  draw_box(camera.width - mbw, mbw, camera.height, colour)
end

dialog_text = ""
text_index = 1
text_row = 0
function draw_dialog_text()
  if text_index == 1 and text_row == 0 then
    draw_dialoguebox()
  end
  local text = dialog_text[text_row + 1]:sub(1, text_index)
  if (text_index <= #dialog_text[text_row + 1]) then
    draw_dialoguebox_letter(text:sub(text_index, text_index), text_index - 1, text_row)
  elseif text_row < #dialog_text and text_row < 2 then
    text_row = text_row + 1
    text_index = 0
  end
  -- update index and reset timer
  text_index = text_index + 1
  dialog_timer = 0.04
end

function dialog_update_timer(dt)
  dialog_timer = dialog_timer - dt
end

function prepare_dialog(text)
  gamestate = gamestates.dialog
  width, dialog_text = font:getWrap(text, camera.width - 8)
  print(width..dialog_text[1]..camera.width - 8)
  print(width..dialog_text[2])
  print(width..dialog_text[3])
  dialog_timer = 0.04
end

function open_demo_text_box()
  prepare_dialog("Hello! Welcome to the dark side of the moon! I hope you enjoy your stay here, i'm a little busy now but i will return to show you around later! Cya around!")
end