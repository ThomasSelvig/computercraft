-- Recursive Ore Miner
-- Turtle program that strip mines, recursively follows ore veins, and returns to main path
-- Global variables
local mainPath = {} -- Track main path for returning
local visited = {} -- Track visited blocks to avoid loops
local ores = {"minecraft:coal_ore", "minecraft:iron_ore", "minecraft:gold_ore", "minecraft:diamond_ore",
              "minecraft:emerald_ore", "minecraft:lapis_ore", "minecraft:redstone_ore", "minecraft:copper_ore",
              "create:zinc_ore", "create:tin_ore", "minecraft:deepslate_coal_ore", "minecraft:deepslate_iron_ore",
              "minecraft:deepslate_gold_ore", "minecraft:deepslate_diamond_ore", "minecraft:deepslate_emerald_ore",
              "minecraft:deepslate_lapis_ore", "minecraft:deepslate_redstone_ore", "minecraft:deepslate_copper_ore",
              "create:deepslate_zinc_ore", "create:deepslate_tin_ore", "minecraft:nether_gold_ore",
              "minecraft:nether_quartz_ore"}
local movementPath = {} -- Track all movements for returning home

-- Helper functions
function isOre(blockName)
    if not blockName then
        return false
    end
    for _, ore in ipairs(ores) do
        if blockName:find(ore) then
            return true
        end
    end
    return false
end

function getVisitedKey(x, y, z)
    return x .. "," .. y .. "," .. z
end

function markVisited(x, y, z)
    visited[getVisitedKey(x, y, z)] = true
end

function isVisited(x, y, z)
    return visited[getVisitedKey(x, y, z)] == true
end

function refuel()
    -- Check if fuel is needed
    if turtle.getFuelLevel() < 100 then
        -- Try to refuel with items in inventory
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(1) then
                print("Refueled with item in slot " .. i)
                break
            end
        end
    end
    turtle.select(1)
end

function moveForward()
    refuel()
    if not turtle.forward() then
        turtle.dig()
        return turtle.forward()
    end
    return true
end

function moveUp()
    refuel()
    if not turtle.up() then
        turtle.digUp()
        return turtle.up()
    end
    return true
end

function moveDown()
    refuel()
    if not turtle.down() then
        turtle.digDown()
        return turtle.down()
    end
    return true
end

function turnRight()
    turtle.turnRight()
    table.insert(movementPath, "turnLeft") -- Insert reverse action
end

function turnLeft()
    turtle.turnLeft()
    table.insert(movementPath, "turnRight") -- Insert reverse action
end

function trackForward()
    if moveForward() then
        table.insert(movementPath, "back")
        return true
    end
    return false
end

function returnHome()
    print("Returning home...")
    -- Execute recorded path in reverse
    for i = #movementPath, 1, -1 do
        local action = movementPath[i]
        if action == "back" then
            if not turtle.back() then
                turtle.turnRight()
                turtle.turnRight()
                turtle.dig()
                turtle.forward()
                turtle.turnRight()
                turtle.turnRight()
            end
        elseif action == "turnRight" then
            turtle.turnRight()
        elseif action == "turnLeft" then
            turtle.turnLeft()
        end
    end
    movementPath = {} -- Clear the path
    print("Returned to starting position")
end

-- Check for ores around current position
function scanForOres()
    local foundOre = false

    -- Check front
    local success, block = turtle.inspect()
    if success and isOre(block.name) then
        foundOre = true
        if moveForward() then
            local x, y, z = gps.locate()
            if x then
                markVisited(x, y, z)
                table.insert(mainPath, {
                    dir = "back"
                })
                mineOreVein()
                -- Return to path
                turtle.back()
            end
        end
    end

    -- Check up
    success, block = turtle.inspectUp()
    if success and isOre(block.name) then
        foundOre = true
        if moveUp() then
            local x, y, z = gps.locate()
            if x then
                markVisited(x, y, z)
                table.insert(mainPath, {
                    dir = "down"
                })
                mineOreVein()
                -- Return to path
                moveDown()
            end
        end
    end

    -- Check down
    success, block = turtle.inspectDown()
    if success and isOre(block.name) then
        foundOre = true
        if moveDown() then
            local x, y, z = gps.locate()
            if x then
                markVisited(x, y, z)
                table.insert(mainPath, {
                    dir = "up"
                })
                mineOreVein()
                -- Return to path
                moveUp()
            end
        end
    end

    -- Check right
    turtle.turnRight()
    success, block = turtle.inspect()
    if success and isOre(block.name) then
        foundOre = true
        if moveForward() then
            local x, y, z = gps.locate()
            if x then
                markVisited(x, y, z)
                table.insert(mainPath, {
                    dir = "left"
                })
                mineOreVein()
                -- Return to path
                turtle.back()
            end
        end
    end
    turtle.turnLeft()

    -- Check left
    turtle.turnLeft()
    success, block = turtle.inspect()
    if success and isOre(block.name) then
        foundOre = true
        if moveForward() then
            local x, y, z = gps.locate()
            if x then
                markVisited(x, y, z)
                table.insert(mainPath, {
                    dir = "right"
                })
                mineOreVein()
                -- Return to path
                turtle.back()
            end
        end
    end
    turtle.turnRight()

    return foundOre
end

-- Recursively mine ore vein
function mineOreVein()
    -- Mine current position (if needed)
    local success, block = turtle.inspectDown()
    if success and isOre(block.name) then
        turtle.digDown()
    end

    -- Scan surrounding blocks for ores
    for dir = 1, 4 do
        local success, block = turtle.inspect()
        if success and isOre(block.name) then
            if moveForward() then
                local x, y, z = gps.locate()
                if x and not isVisited(x, y, z) then
                    markVisited(x, y, z)
                    mineOreVein()
                end
                turtle.back()
            end
        end
        turtle.turnRight()
    end

    -- Check up
    local success, block = turtle.inspectUp()
    if success and isOre(block.name) then
        if moveUp() then
            local x, y, z = gps.locate()
            if x and not isVisited(x, y, z) then
                markVisited(x, y, z)
                mineOreVein()
            end
            moveDown()
        end
    end

    -- Check down
    local success, block = turtle.inspectDown()
    if success and isOre(block.name) then
        if moveDown() then
            local x, y, z = gps.locate()
            if x and not isVisited(x, y, z) then
                markVisited(x, y, z)
                mineOreVein()
            end
            moveUp()
        end
    end
end

-- Main mining function
function stripMine(length, branches, branchLength)
    for i = 1, branches do
        -- Mine forward for branch length
        for j = 1, branchLength do
            if not trackForward() then
                print("Path blocked during branch mining")
                returnHome()
                return false
            end

            local x, y, z = gps.locate()
            if x then
                markVisited(x, y, z)
            end

            -- Check for ores
            scanForOres()
        end

        -- Return to main shaft
        for j = 1, branchLength do
            turtle.back()
        end

        -- Move forward on main shaft
        if i < branches then
            for j = 1, length do
                if not trackForward() then
                    print("Path blocked on main shaft")
                    returnHome()
                    return false
                end
            end
        end
    end
    return true
end

-- Check inventory space
function checkInventory()
    -- Start from slot 2 to keep slot 1 for fuel
    for i = 2, 16 do
        if turtle.getItemCount(i) == 0 then
            return true -- Has empty slot
        end
    end
    return false -- Inventory full
end

-- Main program
function start()
    print("Recursive Ore Miner Starting")
    print("Checking for updates...")

    -- Check for script updates
    local scriptReq, err = http.get("http://127.0.0.1:1337/startup.lua")
    if not scriptReq then
        print("Failed to check for updates: " .. (err or "unknown error"))
    else
        local scriptContent = scriptReq.readAll()
        scriptReq.close()

        local file = fs.open("startup.lua", "r")
        local currentContent = file and file.readAll()
        if file then
            file.close()
        end

        if currentContent and scriptContent == currentContent then
            print("No updates found")
        else
            local file = fs.open("startup.lua", "w")
            if file then
                file.write(scriptContent)
                file.close()
                print("Script updated, restarting...")
                shell.run("startup.lua")
                return
            else
                print("Failed to write update to file")
            end
        end
    end

    -- Ask for mining parameters if not provided
    local length = 3 -- Spacing between branches
    local branches = 10 -- Number of branches
    local branchLength = 10 -- Length of each branch

    print("Starting strip mine with:")
    print("- Branch spacing: " .. length)
    print("- Number of branches: " .. branches)
    print("- Branch length: " .. branchLength)

    -- Initialize GPS coordinates if available
    local x, y, z = gps.locate()
    if x then
        print("Starting position: " .. x .. "," .. y .. "," .. z)
        markVisited(x, y, z)
    else
        print("GPS not available. Position tracking will be limited.")
    end

    -- Check fuel
    local fuelLevel = turtle.getFuelLevel()
    local fuelNeeded = (length * branches) + (branchLength * 2 * branches)
    print("Fuel level: " .. fuelLevel)
    print("Estimated fuel needed: " .. fuelNeeded)

    if fuelLevel < fuelNeeded and fuelLevel ~= "unlimited" then
        print("Warning: Fuel may be insufficient for complete operation")
        print("Attempting to refuel...")
        refuel()
    end

    -- Start mining
    if not stripMine(length, branches, branchLength) then
        print("Mining operation interrupted")
    else
        print("Mining operation complete")
    end

    print("Returning to start...")
    returnHome()
end

-- Run the program
start()
