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
   local limit = camera.width - 20
   local width = camera.width - 10
   local height = 8 * 4
   local x = 0
   local y = camera.height - height

   draw_box(x,y,width,height)
   draw_text(text,x,y,limit)
end
