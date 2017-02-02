-- file: text.lua - text routine

-- draw to (x, y)
-- wrap to x pos
--

-- put_string = love.graphics.printf
function put_string (text, x, y , limit, align)
   align = align or "left"
   love.graphics.printf(text, x, y, limit, align)
end
