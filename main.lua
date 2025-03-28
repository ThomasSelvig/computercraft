require("utils.lua")
local size = 10
for i = 1, 4 do
    for j = 1, size - 1 do -- Reduced by 1 to avoid extra move
        turtle.digDown()
        turtle.digUp()
        turtle.dig()
        turtle.forward()
    end
    if i < 4 then -- Only turn for the first 3 sides
        turtle.turnRight()
    end
end
