require("utils")
local env = require("env")

-- example of how to quickly destroy your ring of obsidian
-- local size = 10
-- for i = 1, 4 do
--     for j = 1, size - 1 do -- Reduced by 1 to avoid extra move
--         turtle.digDown()
--         turtle.digUp()
--         turtle.dig()
--         turtle.forward()
--     end
--     if i < 4 then -- Only turn for the first 3 sides
--         turtle.turnRight()
--     end
-- end

-- for y = 1, 12 do
--     for x = 1, 12 do
--         for z = 1, 12 do
--             turtle.digDown()
--             turtle.digUp()
--             walk("fw")
--         end
--         turtle.turnRight()
--     end
--     walk("up")
--     walk("up")
--     walk("up")
-- end
