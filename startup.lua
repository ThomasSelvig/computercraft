-- Structure Builder for ComputerCraft Turtles
-- Takes a blueprint and constructs a building
-- Version information
local VERSION = "1.0.2"

-- Load utilities
local utils = require("utils")

-- Blueprint format: A 3D table of blocks to place
-- Each entry: {x, y, z, blockName}
-- Where x,y,z are relative coordinates from start position
local blueprint = {}

-- Global variables
local facing = 0 -- 0=north, 1=east, 2=south, 3=west
local posX, posY, posZ = 0, 0, 0
local startX, startY, startZ = 0, 0, 0
local dropOffChestDir = "down"

-- Function to create a simple cube structure blueprint
function createCube(width, height, length, blockName)
    local result = {}

    for x = 0, width - 1 do
        for y = 0, height - 1 do
            for z = 0, length - 1 do
                -- Only add exterior blocks for hollow structures
                if x == 0 or x == width - 1 or y == 0 or y == height - 1 or z == 0 or z == length - 1 then
                    table.insert(result, {x, y, z, blockName})
                end
            end
        end
    end

    return result
end

-- Function to create a platform/floor
function createPlatform(width, length, blockName)
    local result = {}

    for x = 0, width - 1 do
        for z = 0, length - 1 do
            table.insert(result, {x, 0, z, blockName})
        end
    end

    return result
end

-- Function to create a wall
function createWall(width, height, isXAxis, blockName)
    local result = {}

    if isXAxis then
        -- Wall along X axis
        for x = 0, width - 1 do
            for y = 0, height - 1 do
                table.insert(result, {x, y, 0, blockName})
            end
        end
    else
        -- Wall along Z axis
        for z = 0, height - 1 do
            for y = 0, height - 1 do
                table.insert(result, {0, y, z, blockName})
            end
        end
    end

    return result
end

-- Function to select an inventory slot with the specified block
function selectBlock(blockName)
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if item and item.name:find(blockName) then
            return true
        end
    end

    print("Block not found: " .. blockName)
    return false
end

-- Function to check inventory and return to refill if needed
function checkInventory()
    -- Count empty slots (reserve slot 1 for fuel)
    local emptySlots = 0
    for slot = 2, 16 do
        if turtle.getItemCount(slot) == 0 then
            emptySlots = emptySlots + 1
        end
    end

    -- If we have at least one empty slot, we're good
    return emptySlots > 0
end

-- Function to drop off items and return to building
function dropOffItems()
    print("Inventory full, dropping off items...")

    -- Save current position and orientation
    local savedX, savedY, savedZ = posX, posY, posZ
    local savedFacing = facing

    -- Return home using utility function's movement tracking
    utils.withTrackedMovements(function()
        -- The turtle will automatically return to starting position
        -- after this function completes
    end)

    -- Drop off items into chest
    print("Dropping items into chest...")

    -- Keep slot 1 for fuel, drop everything else
    for slot = 2, 16 do
        turtle.select(slot)
        local count = turtle.getItemCount(slot)
        if count > 0 then
            if dropOffChestDir == "down" then
                turtle.dropDown()
            elseif dropOffChestDir == "up" then
                turtle.dropUp()
            else
                turtle.drop() -- Forward
            end
        end
    end

    -- Need to navigate back to the saved position
    -- This would ideally be handled by a pathfinding algorithm

    print("Resumed building operation")
    return true
end

-- Function to navigate to a specific position
function navigateTo(targetX, targetY, targetZ)
    -- Calculate relative movement
    local dx = targetX - posX
    local dy = targetY - posY
    local dz = targetZ - posZ

    -- Move vertically first (y-axis)
    while dy > 0 do
        if turtle.up() then
            posY = posY + 1
            dy = dy - 1
        else
            -- Try to clear the way
            if turtle.detectUp() then
                turtle.digUp()
                sleep(0.5)
            else
                sleep(1.0) -- Wait for entity to move
            end
        end
    end

    while dy < 0 do
        if turtle.down() then
            posY = posY - 1
            dy = dy + 1
        else
            -- Try to clear the way
            if turtle.detectDown() then
                turtle.digDown()
                sleep(0.5)
            else
                sleep(1.0) -- Wait for entity to move
            end
        end
    end

    -- Turn to face the correct X direction
    local targetFacing
    if dx > 0 then
        targetFacing = 1 -- East
    elseif dx < 0 then
        targetFacing = 3 -- West
    end

    if targetFacing ~= nil then
        turnToFace(targetFacing)

        -- Move along X axis
        local stepX = dx > 0 and 1 or -1
        for i = 1, math.abs(dx) do
            if not turtle.forward() then
                -- Try to clear the way
                if turtle.detect() then
                    turtle.dig()
                    sleep(0.5)
                else
                    sleep(1.0) -- Wait for entity to move
                end

                -- Try again
                if turtle.forward() then
                    posX = posX + stepX
                else
                    print("Failed to move along X axis")
                    return false
                end
            else
                posX = posX + stepX
            end
        end
    end

    -- Turn to face the correct Z direction
    if dz > 0 then
        targetFacing = 2 -- South
    elseif dz < 0 then
        targetFacing = 0 -- North
    end

    if targetFacing ~= nil then
        turnToFace(targetFacing)

        -- Move along Z axis
        local stepZ = dz > 0 and 1 or -1
        for i = 1, math.abs(dz) do
            if not turtle.forward() then
                -- Try to clear the way
                if turtle.detect() then
                    turtle.dig()
                    sleep(0.5)
                else
                    sleep(1.0) -- Wait for entity to move
                end

                -- Try again
                if turtle.forward() then
                    posZ = posZ + stepZ
                else
                    print("Failed to move along Z axis")
                    return false
                end
            else
                posZ = posZ + stepZ
            end
        end
    end

    return true
end

-- Function to turn the turtle to face a specific direction
function turnToFace(direction)
    -- Find the shortest turn direction
    local diff = (direction - facing) % 4

    if diff == 1 then
        -- Turn right once
        turtle.turnRight()
    elseif diff == 2 then
        -- Turn right twice (180 degrees)
        turtle.turnRight()
        turtle.turnRight()
    elseif diff == 3 then
        -- Turn left once (equivalent to turning right 3 times)
        turtle.turnLeft()
    end

    facing = direction
end

-- Function to place a block
function placeBlock(direction, blockName)
    if not selectBlock(blockName) then
        return false
    end

    local success = false
    if direction == "up" then
        success = turtle.placeUp()
    elseif direction == "down" then
        success = turtle.placeDown()
    else
        success = turtle.place()
    end

    if not success then
        print("Failed to place " .. blockName .. " " .. direction)
    end

    return success
end

-- Determine the best direction to place a block from
function findPlacementDirection(x, y, z)
    -- Check all six possible directions
    local checks = {{x, y + 1, z, "down"}, -- From above
    {x, y - 1, z, "up"}, -- From below
    {x + 1, y, z, "west"}, -- From east
    {x - 1, y, z, "east"}, -- From west
    {x, y, z + 1, "north"}, -- From south
    {x, y, z - 1, "south"} -- From north
    }

    -- This is a simplified approach - we could be more sophisticated
    -- by checking which positions are already accessible
    return checks[1] -- Default to placing from above
end

-- Main function to build a structure from a blueprint
function buildStructure()
    -- Get GPS coordinates if available
    local x, y, z = gps.locate()
    if x then
        print("Starting position: " .. x .. "," .. y .. "," .. z)
        startX, startY, startZ = x, y, z
        posX, posY, posZ = x, y, z
    else
        print("GPS not available. Using relative coordinates.")
    end

    -- Sort blocks by height (bottom to top is usually best for building)
    table.sort(blueprint, function(a, b)
        if a[2] == b[2] then
            if a[1] == b[1] then
                return a[3] < b[3]
            end
            return a[1] < b[1]
        end
        return a[2] < b[2]
    end)

    print("Starting construction...")
    print("Total blocks to place: " .. #blueprint)

    -- Use our utility function to track movements
    return utils.withTrackedMovements(function()
        for i, block in ipairs(blueprint) do
            local x, y, z, blockName = block[1], block[2], block[3], block[4]

            -- Convert blueprint coordinates to world coordinates
            local worldX = startX + x
            local worldY = startY + y
            local worldZ = startZ + z

            -- Check inventory before building
            if not checkInventory() then
                dropOffItems()
            end

            -- Find the best position to place from
            local placement = findPlacementDirection(x, y, z)
            local placeX = worldX + (placement[1] - x)
            local placeY = worldY + (placement[2] - y)
            local placeZ = worldZ + (placement[3] - z)
            local placeDir = placement[4]

            -- Navigate to the placement position
            if navigateTo(placeX, placeY, placeZ) then
                -- Turn to face the right direction for placement
                local facingDir
                if placeDir == "east" then
                    facingDir = 1
                elseif placeDir == "south" then
                    facingDir = 2
                elseif placeDir == "west" then
                    facingDir = 3
                elseif placeDir == "north" then
                    facingDir = 0
                end

                if facingDir ~= nil then
                    turnToFace(facingDir)
                end

                -- Place the block
                local success
                if placeDir == "up" then
                    success = placeBlock("up", blockName)
                elseif placeDir == "down" then
                    success = placeBlock("down", blockName)
                else
                    success = placeBlock("forward", blockName)
                end

                if success then
                    print("Placed block " .. i .. "/" .. #blueprint)
                else
                    print("Failed to place block " .. i .. "/" .. #blueprint)
                end
            else
                print("Failed to navigate to placement position for block " .. i)
            end
        end

        print("Construction complete!")
        return true
    end)
end

-- Load a blueprint from file
function loadBlueprint(filename)
    local file = fs.open(filename, "r")
    if not file then
        print("Error: Could not open blueprint file")
        return false
    end

    local content = file.readAll()
    file.close()

    -- Parse the blueprint content
    local loaded = textutils.unserialize(content)
    if type(loaded) ~= "table" then
        print("Error: Invalid blueprint format")
        return false
    end

    blueprint = loaded
    return true
end

-- Save a blueprint to file
function saveBlueprint(filename)
    local file = fs.open(filename, "w")
    if not file then
        print("Error: Could not create blueprint file")
        return false
    end

    local content = textutils.serialize(blueprint)
    file.write(content)
    file.close()

    return true
end

-- Main program
function main()
    print("ComputerCraft Structure Builder v" .. VERSION)
    print("1. Build a cube")
    print("2. Build a platform")
    print("3. Build a wall")
    print("4. Load blueprint from file")

    write("Enter choice: ")
    local choice = tonumber(read())

    if choice == 1 then
        write("Enter width: ")
        local width = tonumber(read()) or 5

        write("Enter height: ")
        local height = tonumber(read()) or 5

        write("Enter length: ")
        local length = tonumber(read()) or 5

        write("Enter block name (e.g. 'stone'): ")
        local blockName = read() or "stone"

        blueprint = createCube(width, height, length, blockName)

        write("Save blueprint? (y/n): ")
        local saveChoice = read():lower()
        if saveChoice == "y" then
            write("Enter filename: ")
            local filename = read()
            saveBlueprint(filename)
        end

    elseif choice == 2 then
        write("Enter width: ")
        local width = tonumber(read()) or 5

        write("Enter length: ")
        local length = tonumber(read()) or 5

        write("Enter block name (e.g. 'stone'): ")
        local blockName = read() or "stone"

        blueprint = createPlatform(width, length, blockName)

    elseif choice == 3 then
        write("Enter width: ")
        local width = tonumber(read()) or 5

        write("Enter height: ")
        local height = tonumber(read()) or 5

        write("Build along X axis? (y/n): ")
        local isXAxis = read():lower() == "y"

        write("Enter block name (e.g. 'stone'): ")
        local blockName = read() or "stone"

        blueprint = createWall(width, height, isXAxis, blockName)

    elseif choice == 4 then
        write("Enter blueprint filename: ")
        local filename = read()

        if not loadBlueprint(filename) then
            print("Failed to load blueprint")
            return
        end
    else
        print("Invalid choice")
        return
    end

    -- Check if blueprint was loaded/created
    if not blueprint or #blueprint == 0 then
        print("No blueprint loaded or created")
        return
    end

    print("Blueprint loaded with " .. #blueprint .. " blocks")

    write("Enter chest direction for item drop-off (down/up/forward, default down): ")
    local dropDir = read()
    dropOffChestDir = dropDir ~= "" and dropDir or "down"

    -- Check fuel
    local fuelLevel = turtle.getFuelLevel()
    local fuelNeeded = #blueprint * 4 -- Rough estimate, 4 moves per block
    print("Fuel level: " .. fuelLevel)
    print("Estimated fuel needed: " .. fuelNeeded)

    if fuelLevel < fuelNeeded and fuelLevel ~= "unlimited" then
        print("Warning: Fuel may be insufficient")
        write("Continue anyway? (y/n): ")
        if read():lower() ~= "y" then
            return
        end
    end

    -- Start building
    write("Start building? (y/n): ")
    if read():lower() == "y" then
        buildStructure()
    else
        print("Building cancelled")
    end
end

-- Run the main program
main()
