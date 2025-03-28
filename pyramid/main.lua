-- computercraft turtle function to build a 3d pyramid
function pyramid(n)
    local function moveForward()
        while not turtle.forward() do
            if turtle.detect() then
                turtle.dig()
            else
                turtle.attack()
            end
        end
    end

    local function moveUp()
        while not turtle.up() do
            if turtle.detectUp() then
                turtle.digUp()
            else
                turtle.attackUp()
            end
        end
    end

    local function moveDown()
        while not turtle.down() do
            if turtle.detectDown() then
                turtle.digDown()
            else
                turtle.attackDown()
            end
        end
    end

    local function placeBlock()
        turtle.placeDown()
    end

    local function buildLayer(size)
        for i = 1, 4 do
            for j = 1, size - 1 do -- Reduced by 1 to avoid extra move
                placeBlock()
                moveForward()
            end
            placeBlock() -- Place final block without moving
            if i < 4 then -- Only turn for the first 3 sides
                turtle.turnRight()
            end
        end
    end

    local function buildPyramid(n)
        local startHeight = n -- Remember starting height for return journey
        for i = 1, n do
            local layerSize = n - i + 1
            buildLayer(layerSize)
            if i < n then -- Don't move up after last layer
                moveUp()
                turtle.turnRight()
                moveForward()
                turtle.turnLeft()
                moveForward()
            end
        end

        -- Return to starting position
        for i = 1, startHeight - 1 do
            moveDown()
        end
    end

    -- Input validation
    n = tonumber(n)
    if not n or n < 1 then
        print("Please enter a valid positive number")
        return
    end

    buildPyramid(n)
end

print("Enter the number of layers for the pyramid:")
local n = read()
pyramid(n)
