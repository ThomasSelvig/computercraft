-- Structure Builder for ComputerCraft Turtles
-- Takes a blueprint and constructs a building

-- Version information
local VERSION = "1.1.0"

-- Load utilities
local utils = require("utils")

-- Blueprint format: A 3D table of blocks to place
-- Each entry: {x, y, z, blockName}
-- Where x,y,z are relative coordinates from start position
local blueprint = {}

-- Global variables
local facing = 0  -- 0=north, 1=east, 2=south, 3=west
local posX, posY, posZ = 0, 0, 0
local startX, startY, startZ = 0, 0, 0
local buildSizeX, buildSizeY, buildSizeZ = 0, 0, 0
local dropOffChestDir = "down"
local buildCoords = {}  -- Track occupied coordinates

-- Function to create a simple cube structure blueprint with optimized path
function createCube(width, height, length, blockName)
    local result = {}
    buildSizeX, buildSizeY, buildSizeZ = width, height, length
    
    -- Bottom face (y=0)
    for x = 0, width-1 do
        for z = 0, length-1 do
            if x == 0 or x == width-1 or z == 0 or z == length-1 then
                table.insert(result, {x, 0, z, blockName})
            end
        end
    end
    
    -- Top face (y=height-1)
    for x = 0, width-1 do
        for z = 0, length-1 do
            if x == 0 or x == width-1 or z == 0 or z == length-1 then
                table.insert(result, {x, height-1, z, blockName})
            end
        end
    end
    
    -- Remaining vertical edges
    for y = 1, height-2 do
        -- Four vertical edges
        table.insert(result, {0, y, 0, blockName})
        table.insert(result, {width-1, y, 0, blockName})
        table.insert(result, {0, y, length-1, blockName})
        table.insert(result, {width-1, y, length-1, blockName})
        
        -- Side walls if needed
        for x = 1, width-2 do
            table.insert(result, {x, y, 0, blockName})
            table.insert(result, {x, y, length-1, blockName})
        end
        
        for z = 1, length-2 do
            table.insert(result, {0, y, z, blockName})
            table.insert(result, {width-1, y, z, blockName})
        end
    end
    
    return result
end

-- Function to create a platform/floor with optimized path
function createPlatform(width, length, blockName)
    local result = {}
    buildSizeX, buildSizeY, buildSizeZ = width, 1, length
    
    -- Build in rows for optimal movement
    for z = 0, length-1 do
        for x = 0, width-1 do
            table.insert(result, {x, 0, z, blockName})
        end
    end
    
    return result
end

-- Function to create a wall with optimized path
function createWall(width, height, isXAxis, blockName)
    local result = {}
    
    if isXAxis then
        buildSizeX, buildSizeY, buildSizeZ = width, height, 1
        
        -- Build wall along X axis, row by row from bottom to top
        for y = 0, height-1 do
            for x = 0, width-1 do
                table.insert(result, {x, y, 0, blockName})
            end
        end
    else
        buildSizeX, buildSizeY, buildSizeZ = 1, height, width
        
        -- Build wall along Z axis, row by row from bottom to top
        for y = 0, height-1 do
            for z = 0, width-1 do
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

-- Function to move safely without hitting the structure
function safeNavigateHome()
    print("Navigating safely back to home...")
    
    -- First move up and out of the structure
    local moveUpNeeded = buildSizeY + 2 - (posY - startY)
    if moveUpNeeded > 0 then
        for i = 1, moveUpNeeded do
            if not turtle.up() then
                -- Try to clear the way
                if turtle.detectUp() then
                    turtle.digUp()
                    sleep(0.5)
                end
                turtle.up()
            end
            posY = posY + 1
        end
    end
    
    -- Now move outside the structure horizontally
    -- Choose the closest boundary to exit
    local distanceToMinX = posX - startX
    local distanceToMaxX = startX + buildSizeX - posX
    local distanceToMinZ = posZ - startZ
    local distanceToMaxZ = startZ + buildSizeZ - posZ
    
    local minDistance = math.min(distanceToMinX, distanceToMaxX, distanceToMinZ, distanceToMaxZ)
    
    if minDistance == distanceToMinX then
        -- Move to minimum X (west)
        turnToFace(3) -- Face west
        for i = 1, distanceToMinX + 2 do
            if not turtle.forward() then
                if turtle.detect() then
                    turtle.dig()
                    sleep(0.5)
                end
                turtle.forward()
            end
            posX = posX - 1
        end
    elseif minDistance == distanceToMaxX then
        -- Move to maximum X (east)
        turnToFace(1) -- Face east
        for i = 1, distanceToMaxX + 2 do
            if not turtle.forward() then
                if turtle.detect() then
                    turtle.dig()
                    sleep(0.5)
                end
                turtle.forward()
            end
            posX = posX + 1
        end
    elseif minDistance == distanceToMinZ then
        -- Move to minimum Z (north)
        turnToFace(0) -- Face north
        for i = 1, distanceToMinZ + 2 do
            if not turtle.forward() then
                if turtle.detect() then
                    turtle.dig()
                    sleep(0.5)
                end
                turtle.forward()
            end
            posZ = posZ - 1
        end
    else
        -- Move to maximum Z (south)
        turnToFace(2) -- Face south
        for i = 1, distanceToMaxZ + 2 do
            if not turtle.forward() then
                if turtle.detect() then
                    turtle.dig()
                    sleep(0.5)
                end
                turtle.forward()
            end
            posZ = posZ + 1
        end
    end
    
    -- Now navigate back to the starting point
    return navigateTo(startX, startY, startZ)
end

-- Function to drop off items and return to building
function dropOffItems(lastX, lastY, lastZ, lastFacing)
    print("Inventory full, dropping off items...")
    
    -- Save current position and orientation
    local savedX, savedY, savedZ = posX, posY, posZ
    local savedFacing = facing
    
    -- Safely navigate back to home to avoid hitting the structure
    safeNavigateHome()
    
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
    
    turtle.select(1) -- Go back to fuel slot
    
    -- Navigate back to the saved position
    print("Returning to building position...")
    if navigateTo(savedX, savedY, savedZ) then
        turnToFace(savedFacing)
        print("Resumed building operation")
        return true
    else
        print("Failed to return to building position")
        return false
    end
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

-- Get key for tracking placed blocks
function getCoordKey(x, y, z)
    return x .. "," .. y .. "," .. z
end

-- Mark a position as having a block
function markBuilt(x, y, z)
    buildCoords[getCoordKey(x, y, z)] = true
end

-- Check if a position has a block
function isBuilt(x, y, z)
    return buildCoords[getCoordKey(x, y, z)] == true
end

-- Determine the best direction to place a block from, avoiding going through the structure
function findOptimalPlacementDirection(x, y, z)
    -- Potential placement directions in preferential order (prefer placing from outside)
    local possibleDirections = {
        { dx=0, dy=1, dz=0, dir="down" },   -- From above
        { dx=0, dy=-1, dz=0, dir="up" },    -- From below
        { dx=1, dy=0, dz=0, dir="west" },   -- From east
        { dx=-1, dy=0, dz=0, dir="east" },  -- From west
        { dx=0, dy=0, dz=1, dir="north" },  -- From south
        { dx=0, dy=0, dz=-1, dir="south" }  -- From north
    }
    
    -- Check each direction, starting with the most optimal
    for _, direction in ipairs(possibleDirections) do
        local checkX = x + direction.dx
        local checkY = y + direction.dy
        local checkZ = z + direction.dz
        
        -- If this position is outside the structure or not built yet, use it
        if not isBuilt(checkX, checkY, checkZ) then
            return {
                x = checkX,
                y = checkY,
                z = checkZ,
                dir = direction.dir
            }
        end
    end
    
    -- If no good direction found, default to placing from above
    return {
        x = x,
        y = y + 1,
        z = z,
        dir = "down"
    }
end

-- Optimize the order of blocks to minimize travel distance
function optimizeBlueprint()
    -- First pass: sort by layers (y-coordinate) from bottom to top
    table.sort(blueprint, function(a, b)
        if a[2] == b[2] then
            -- Within the same layer, prefer nearby blocks
            -- Sort by Z, then X for each row
            if a[3] == b[3] then
                return a[1] < b[1]  -- Sort by X within the same Z
            end
            return a[3] < b[3]  -- Sort by Z within the same layer
        end
        return a[2] < b[2]  -- Sort by Y (height) first
    end)
    
    -- Initialize buildCoords tracker
    buildCoords = {}
    
    return true
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
    
    -- Optimize the blueprint for efficient building
    optimizeBlueprint()
    
    print("Starting construction...")
    print("Total blocks to place: " .. #blueprint)
    
    -- Build the structure
    for i, block in ipairs(blueprint) do
        local x, y, z, blockName = block[1], block[2], block[3], block[4]
        
        -- Convert blueprint coordinates to world coordinates
        local worldX = startX + x
        local worldY = startY + y
        local worldZ = startZ + z
        
        -- Check inventory before building
        if not checkInventory() then
            if not dropOffItems(worldX, worldY, worldZ, facing) then
                print("Failed to drop off items, aborting")
                return false
            end
        end
        
        -- Find the optimal placement position
        local placement = findOptimalPlacementDirection(x, y, z)
        local placeX = startX + placement.x
        local placeY = startY + placement.y
        local placeZ = startZ + placement.z
        local placeDir = placement.dir
        
        -- Navigate to the placement position
        if navigateTo(placeX, placeY, placeZ) then
            -- Turn to face the right direction for placement
            local facingDir
            if placeDir == "east" then facingDir = 1
            elseif placeDir == "south" then facingDir = 2
            elseif placeDir == "west" then facingDir = 3
            elseif placeDir == "north" then facingDir = 0
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
                markBuilt(x, y, z)  -- Mark this position as having a block
            else
                print("Failed to place block " .. i .. "/" .. #blueprint)
            end
        else
            print("Failed to navigate to placement position for block " .. i)
        end
    end
    
    -- Return to starting position, making sure to avoid the structure
    print("Construction complete! Returning to starting position...")
    safeNavigateHome()
    
    return true
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

-- Function to check for updates
function checkForUpdates()
    print("Checking for updates...")
    return utils.checkForUpdates("Structure Builder", VERSION)
end

-- Main program
function main()
    print("ComputerCraft Structure Builder v" .. VERSION)
    print("1. Build a cube")
    print("2. Build a platform")
    print("3. Build a wall")
    print("4. Load blueprint from file")
    print("5. Check for updates")
    
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
        
        -- Determine structure size from loaded blueprint
        buildSizeX, buildSizeY, buildSizeZ = 0, 0, 0
        for _, block in ipairs(blueprint) do
            buildSizeX = math.max(buildSizeX, block[1] + 1)
            buildSizeY = math.max(buildSizeY, block[2] + 1)
            buildSizeZ = math.max(buildSizeZ, block[3] + 1)
        end
    elseif choice == 5 then
        -- Check for updates
        checkForUpdates()
        return
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
    print("Structure dimensions: " .. buildSizeX .. "x" .. buildSizeY .. "x" .. buildSizeZ)
    
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