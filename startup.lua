-- Structure Builder Turtle
-- A ComputerCraft turtle program for building configurable structures
local utils = require("utils")

-- Script version and update info
local SCRIPT_NAME = "StructureBuilder"
local VERSION = "1.0.1"

-- Movement functions with error handling
local function moveForward()
    local success = false
    local attempts = 0
    while not success and attempts < 5 do
        success = turtle.forward()
        if not success then
            if turtle.detect() then
                turtle.dig()
                sleep(0.5) -- Wait for blocks to fall
            else
                -- Something else is blocking, like an entity
                sleep(1)
            end
        end
        attempts = attempts + 1
    end
    return success
end

local function moveUp()
    local success = false
    local attempts = 0
    while not success and attempts < 5 do
        success = turtle.up()
        if not success then
            if turtle.detectUp() then
                turtle.digUp()
                sleep(0.5)
            else
                sleep(1)
            end
        end
        attempts = attempts + 1
    end
    return success
end

local function moveDown()
    local success = false
    local attempts = 0
    while not success and attempts < 5 do
        success = turtle.down()
        if not success then
            if turtle.detectDown() then
                turtle.digDown()
                sleep(0.5)
            else
                sleep(1)
            end
        end
        attempts = attempts + 1
    end
    return success
end

local function turnLeft()
    return turtle.turnLeft()
end

local function turnRight()
    return turtle.turnRight()
end

-- Use the withTrackedMovements function from utils module with our movement functions
local function withTrackedMovements(fn)
    -- Create wrapper functions that use our error-handling movement functions
    local originalForward = turtle.forward
    local originalUp = turtle.up
    local originalDown = turtle.down
    
    -- Replace turtle's basic movement with our error-handling functions
    turtle.forward = moveForward
    turtle.up = moveUp
    turtle.down = moveDown
    
    -- Call utils' tracking function
    local result = utils.withTrackedMovements(fn)
    
    -- Restore original turtle functions
    turtle.forward = originalForward
    turtle.up = originalUp
    turtle.down = originalDown
    
    return result
end

-- Inventory management
local function selectItem(name)
    -- First try exact match
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and (item.name == name or string.find(item.name, name, 1, true)) then
            turtle.select(i)
            return true
        end
    end

    -- Then try any item if name is generic
    if name == "block" then
        for i = 1, 16 do
            if turtle.getItemCount(i) > 0 then
                turtle.select(i)
                return true
            end
        end
    end

    -- Look for common building blocks
    if name == "block" then
        local buildingBlocks = {"log", "planks", "wood", "stone", "cobblestone", "dirt", "sand"}
        for _, blockType in ipairs(buildingBlocks) do
            for i = 1, 16 do
                local item = turtle.getItemDetail(i)
                if item and string.find(item.name:lower(), blockType:lower()) then
                    turtle.select(i)
                    return true
                end
            end
        end
    end

    return false
end

local function countItem(name)
    local total = 0

    -- Count specific items if name is specific
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and (item.name == name or string.find(item.name, name, 1, true)) then
            total = total + item.count
        end
    end

    -- If looking for any block and no specific items found, count everything
    if name == "block" and total == 0 then
        for i = 1, 16 do
            total = total + turtle.getItemCount(i)
        end
    end

    return total
end

local function placeBlock()
    return turtle.place()
end

local function placeBlockDown()
    return turtle.placeDown()
end

local function placeBlockUp()
    return turtle.placeUp()
end

-- Basic geometric shapes
local function buildCube(size, blockType)
    print("Building a cube of size " .. size .. " with " .. blockType)

    local requiredBlocks = size * size * size - (size - 2) * (size - 2) * (size - 2)

    if countItem(blockType) < requiredBlocks then
        print("Not enough materials! Need " .. requiredBlocks .. " " .. blockType)
        return false
    end

    return withTrackedMovements(function()
        selectItem(blockType)

        -- Base layer (y=0)
        -- Always start by placing the first block down
        placeBlockDown()

        -- Use a snake pattern to cover the base
        for z = 1, size do
            -- In each row, place blocks and move forward
            for x = 1, size do
                -- Place blocks only at the edges (hollow cube)
                if z == 1 or z == size or x == 1 or x == size then
                    placeBlockDown()
                end

                -- Move forward if not at the end of the row
                if x < size then
                    moveForward()
                end
            end

            -- At the end of each row (except the last one),
            -- turn to go back in the opposite direction
            if z < size then
                if z % 2 == 1 then
                    -- Turn right at the end of odd-numbered rows
                    turnRight()
                    moveForward()
                    turnRight()
                else
                    -- Turn left at the end of even-numbered rows
                    turnLeft()
                    moveForward()
                    turnLeft()
                end
            end
        end

        -- Now we should be at the corner where we started (x,z) = (0,0)

        -- Middle layers (y=1 to y=size-2)
        for y = 1, size - 2 do
            -- Move up to next layer
            moveUp()

            -- Now build each layer in same snake pattern
            for z = 1, size do
                for x = 1, size do
                    -- Only place blocks at the edges
                    if z == 1 or z == size or x == 1 or x == size then
                        placeBlock()
                    end

                    -- Move forward if not at the end of the row
                    if x < size then
                        moveForward()
                    end
                end

                -- Navigate to next row
                if z < size then
                    if z % 2 == 1 then
                        turnRight()
                        moveForward()
                        turnRight()
                    else
                        turnLeft()
                        moveForward()
                        turnLeft()
                    end
                end
            end
        end

        -- Top layer (y=size-1)
        moveUp()

        -- Build the top layer in same snake pattern
        for z = 1, size do
            for x = 1, size do
                -- Place blocks only at the edges
                if z == 1 or z == size or x == 1 or x == size then
                    placeBlockUp()
                end

                -- Move forward if not at the end of the row
                if x < size then
                    moveForward()
                end
            end

            -- Navigate to next row
            if z < size then
                if z % 2 == 1 then
                    turnRight()
                    moveForward()
                    turnRight()
                else
                    turnLeft()
                    moveForward()
                    turnLeft()
                end
            end
        end

        return true
    end)
end

local function buildPlatform(length, width, blockType)
    print("Building a platform of " .. length .. "x" .. width .. " with " .. blockType)

    local requiredBlocks = length * width

    if countItem(blockType) < requiredBlocks then
        print("Not enough materials! Need " .. requiredBlocks .. " " .. blockType)
        return false
    end

    return withTrackedMovements(function()
        selectItem(blockType)

        -- Always start by placing the first block
        placeBlockDown()

        -- Use a snake pattern to cover the platform
        for z = 1, width do
            for x = 1, length do
                placeBlockDown()
                if x < length then
                    moveForward()
                end
            end

            if z < width then
                if z % 2 == 1 then
                    turnLeft()
                    moveForward()
                    turnLeft()
                else
                    turnRight()
                    moveForward()
                    turnRight()
                end
            end
        end

        return true
    end)
end

local function buildWall(length, height, blockType)
    print("Building a wall of " .. length .. "x" .. height .. " with " .. blockType)

    local requiredBlocks = length * height

    if countItem(blockType) < requiredBlocks then
        print("Not enough materials! Need " .. requiredBlocks .. " " .. blockType)
        return false
    end

    return withTrackedMovements(function()
        selectItem(blockType)

        -- Build the wall row by row
        for y = 1, height do
            -- For each row, place blocks from left to right
            for x = 1, length do
                placeBlock()

                -- Move forward if not at the end of the row
                if x < length then
                    moveForward()
                end
            end

            -- If not at the top row, move back to start and up one level
            if y < height then
                -- Move back to start of row
                for i = 1, length - 1 do
                    turtle.back()
                end

                -- Move up one level
                moveUp()
            end
        end

        return true
    end)
end

local function buildPyramid(size, blockType)
    print("Building a pyramid of size " .. size .. " with " .. blockType)

    local requiredBlocks = 0
    for i = 0, size - 1 do
        requiredBlocks = requiredBlocks + (size - i) * (size - i)
    end

    if countItem(blockType) < requiredBlocks then
        print("Not enough materials! Need " .. requiredBlocks .. " " .. blockType)
        return false
    end

    return withTrackedMovements(function()
        selectItem(blockType)

        -- Start at bottom layer and work upward
        for level = 1, size do
            local currentSize = size - level + 1

            -- Place blocks in a snake pattern
            for z = 1, currentSize do
                for x = 1, currentSize do
                    placeBlockDown()

                    -- Move forward if not at the end of the row
                    if x < currentSize then
                        moveForward()
                    end
                end

                -- Navigate to next row if not the last row
                if z < currentSize then
                    if z % 2 == 1 then
                        turnLeft()
                        moveForward()
                        turnLeft()
                    else
                        turnRight()
                        moveForward()
                        turnRight()
                    end
                end
            end

            -- If not at the top layer, move up and into position for next layer
            if level < size then
                -- Navigate to next layer start position (inward by 1 in x and z)
                moveUp()
                moveForward()
                turnRight()
                moveForward()
                turnRight()
            end
        end

        return true
    end)
end

local function buildDome(radius, blockType)
    print("Building a dome of radius " .. radius .. " with " .. blockType)

    -- Approximate block count for a hemisphere
    local requiredBlocks = math.ceil(2 * math.pi * radius * radius / 3)

    if countItem(blockType) < requiredBlocks then
        print("Not enough materials! Need " .. requiredBlocks .. " " .. blockType)
        return false
    end

    return withTrackedMovements(function()
        selectItem(blockType)

        -- Build dome layer by layer from bottom to top
        for y = 0, radius do
            -- At each height, the dome is a circle with a radius that gets smaller as height increases
            local circleRadius = math.floor(math.sqrt(radius * radius - y * y))

            -- Build each layer as a series of rows
            for z = -circleRadius, circleRadius do
                -- For each row, go through each column position
                for x = -circleRadius, circleRadius do
                    -- Calculate if this position should have a block (at the dome's surface)
                    local distanceFromCenter = x * x + z * z
                    local isOnSurface = distanceFromCenter <= radius * radius - y * y and distanceFromCenter >
                                            (radius - 1) * (radius - 1) - y * y

                    -- Place a block if this position is on the dome's surface
                    if isOnSurface then
                        placeBlock()
                    end

                    -- Move to next position if not at the end of the row
                    if x < circleRadius then
                        moveForward()
                    end
                end

                -- At end of row, get ready for next row if not the last row
                if z < circleRadius then
                    -- Turn around and head back in the other direction
                    turnRight()
                    turnRight()

                    -- Move forward to the next row
                    moveForward()

                    -- Turn to face the right direction for the next row
                    if z % 2 == 0 then
                        turnLeft()
                    else
                        turnRight()
                    end
                end
            end

            -- Move up to the next layer if not at the top
            if y < radius then
                moveUp()
            end
        end

        return true
    end)
end

-- Structure definitions mapped to building functions
local structures = {
    cube = {
        name = "Cube",
        build = buildCube,
        params = {"size"},
        materials = {{"Building blocks", "block"}}
    },
    platform = {
        name = "Platform",
        build = buildPlatform,
        params = {"length", "width"},
        materials = {{"Building blocks", "block"}}
    },
    wall = {
        name = "Wall",
        build = buildWall,
        params = {"length", "height"},
        materials = {{"Building blocks", "block"}}
    },
    pyramid = {
        name = "Pyramid",
        build = buildPyramid,
        params = {"size"},
        materials = {{"Building blocks", "block"}}
    },
    dome = {
        name = "Dome",
        build = buildDome,
        params = {"radius"},
        materials = {{"Building blocks", "block"}}
    }
}

-- User interface
local function displayMenu()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Structure Builder Turtle v" .. VERSION .. " ===")
    print("Choose a structure to build:")

    local i = 1
    local options = {}
    for key, struct in pairs(structures) do
        print(i .. ". " .. struct.name)
        options[i] = key
        i = i + 1
    end

    print(i .. ". Check for updates")
    print((i + 1) .. ". Exit")

    io.write("> ")
    local choice = tonumber(io.read())

    if choice == i then
        utils.checkForUpdates(SCRIPT_NAME, VERSION)
        sleep(2)
        return displayMenu()
    elseif choice == i + 1 then
        return nil
    elseif choice >= 1 and choice < i then
        return options[choice]
    else
        print("Invalid choice. Try again.")
        sleep(1)
        return displayMenu()
    end
end

local function getParameters(structure)
    local params = {}

    print("Building a " .. structure.name)

    for _, param in ipairs(structure.params) do
        io.write("Enter " .. param .. ": ")
        params[param] = tonumber(io.read())

        if not params[param] or params[param] <= 0 then
            print("Invalid value. Must be a positive number.")
            return getParameters(structure)
        end
    end

    return params
end

local function requestMaterials(structure, params)
    print("Please insert the following materials:")

    local materialsList = {}

    for _, material in ipairs(structure.materials) do
        local description, key = material[1], material[2]

        -- Calculate required amount based on structure and parameters
        local amount = 64 -- Default placeholder
        if structure.name == "Cube" then
            local size = params.size
            amount = size * size * size - (size - 2) * (size - 2) * (size - 2)
        elseif structure.name == "Platform" then
            amount = params.length * params.width
        elseif structure.name == "Wall" then
            amount = params.length * params.height
        elseif structure.name == "Pyramid" then
            local size = params.size
            amount = 0
            for i = 0, size - 1 do
                amount = amount + (size - i) * (size - i)
            end
        elseif structure.name == "Dome" then
            local radius = params.radius
            amount = math.ceil(2 * math.pi * radius * radius / 3)
        end

        print(" - " .. amount .. "x " .. description .. " for " .. structure.name)
        materialsList[key] = {
            description = description,
            amount = amount
        }
    end

    io.write("Press Enter when ready...")
    io.read()

    return true
end

-- Debugging helper
local function debugPrintInventory()
    print("Current inventory:")
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item then
            print(string.format("Slot %d: %s (%d)", i, item.name, item.count))
        end
    end
end

-- Main program
print("Starting " .. SCRIPT_NAME .. " v" .. VERSION)
sleep(1)

-- Check for updates on startup
utils.checkForUpdates(SCRIPT_NAME, VERSION)

while true do
    local structureKey = displayMenu()

    if not structureKey then
        print("Goodbye!")
        break
    end

    local structure = structures[structureKey]
    local params = getParameters(structure)

    if requestMaterials(structure, params) then
        -- Show inventory contents for debugging
        debugPrintInventory()

        -- Prepare arguments for the build function
        local args = {}
        for _, param in ipairs(structure.params) do
            table.insert(args, params[param])
        end

        -- Add material type as the last parameter
        table.insert(args, "block")

        -- Call the build function with unpacked args
        local success = structure.build(table.unpack(args))

        if success then
            print("Structure built successfully!")
        else
            print("Failed to build structure. Check materials and try again.")
        end

        sleep(2)
    end
end
