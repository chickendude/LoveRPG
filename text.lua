-- file: text.lua - text routine


function put_string (text, x, y , limit, align)
   align = align or "left"
   love.graphics.printf(text, x, y, limit, align)
end

--
function draw_box(x, y, width, height, mode, colour)
   mode = mode or "fill"
   colour = colour or {255,255,0,255}
   love.graphics.rectangle( mode, x, y, width, height)
end

--function draw_textbox(text, align_h, align_v)
--end
