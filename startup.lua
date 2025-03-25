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
local inBranch = false -- Flag to track if we're in a branch
local homeX, homeY, homeZ -- Store home coordinates
local inventoryFull = false -- Flag for inventory status
local dropOffChestDir = "down" -- Direction of chest for dropping items

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
    -- Check for unnamed blocks that might be modded ores
    -- Look for common keywords in block names
    if blockName:find("ore") or blockName:find("crystal") or 
       blockName:find("gem") or blockName:find("mineral") then
        return true
    end
    return false
end

-- Function to safely get block information
function safeInspect(direction)
    local success, data
    
    if direction == "forward" then
        success, data = pcall(turtle.inspect)
    elseif direction == "up" then
        success, data = pcall(turtle.inspectUp)
    elseif direction == "down" then
        success, data = pcall(turtle.inspectDown)
    end
    
    if success and type(data) == "table" then
        return true, data
    else
        -- Handle any errors or unexpected results
        return false, nil
    end
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
        -- Try to dig and move forward
        if turtle.detect() then
            turtle.dig()
            sleep(0.5) -- Wait for falling blocks to settle
        end
        
        -- Try multiple times in case of falling gravel or entities
        for attempt = 1, 3 do
            if turtle.forward() then
                return true
            end
            
            -- If still blocked, try digging again (could be gravel that fell)
            if turtle.detect() then
                turtle.dig()
                sleep(0.5)
            else
                -- No block detected but still can't move (likely an entity)
                sleep(1.0) -- Wait for entity to potentially move
            end
        end
        
        return false -- Failed after multiple attempts
    end
    return true
end

function moveUp()
    refuel()
    if not turtle.up() then
        -- Try to dig and move up
        if turtle.detectUp() then
            turtle.digUp()
            sleep(0.5) -- Wait for falling blocks to settle
        end
        
        -- Try multiple times in case of falling gravel or entities
        for attempt = 1, 3 do
            if turtle.up() then
                return true
            end
            
            -- If still blocked, try digging again
            if turtle.detectUp() then
                turtle.digUp()
                sleep(0.5)
            else
                -- No block detected but still can't move (likely an entity)
                sleep(1.0) -- Wait for entity to potentially move
            end
        end
        
        return false -- Failed after multiple attempts
    end
    return true
end

function moveDown()
    refuel()
    if not turtle.down() then
        -- Try to dig and move down
        if turtle.detectDown() then
            turtle.digDown()
            sleep(0.5) -- Wait for blocks to settle
        end
        
        -- Try multiple times in case of entities or other issues
        for attempt = 1, 3 do
            if turtle.down() then
                return true
            end
            
            -- If still blocked, try digging again
            if turtle.detectDown() then
                turtle.digDown()
                sleep(0.5)
            else
                -- No block detected but still can't move (likely an entity)
                sleep(1.0) -- Wait for entity to potentially move
            end
        end
        
        return false -- Failed after multiple attempts
    end
    return true
end

function turnRight()
    turtle.turnRight()
    if movementPath then -- Check if movement path is initialized
        table.insert(movementPath, "turnLeft") -- Insert reverse action
    end
end

function turnLeft()
    turtle.turnLeft()
    if movementPath then -- Check if movement path is initialized
        table.insert(movementPath, "turnRight") -- Insert reverse action
    end
end

function trackForward()
    -- Only add to movement path if we actually move
    if moveForward() then
        if movementPath then -- Check if movement path is initialized
            table.insert(movementPath, "back")
        end
        return true
    end
    return false
end

function trackUp()
    -- Only add to movement path if we actually move
    if moveUp() then
        if movementPath then -- Check if movement path is initialized
            table.insert(movementPath, "down")
        end
        return true
    end
    return false
end

function trackDown()
    -- Only add to movement path if we actually move
    if moveDown() then
        if movementPath then -- Check if movement path is initialized
            table.insert(movementPath, "up")
        end
        return true
    end
    return false
end

function returnHome()
    print("Returning home...")
    
    if not movementPath or #movementPath == 0 then
        print("No movement path recorded, cannot return home")
        return
    end
    
    print("Following return path of " .. #movementPath .. " steps")
    
    -- Execute recorded path in reverse
    local stepsCompleted = 0
    for i = #movementPath, 1, -1 do
        local action = movementPath[i]
        print("Return step " .. stepsCompleted + 1 .. "/" .. #movementPath .. ": " .. action)
        
        if action == "back" then
            -- Try to go back, if blocked, turn around and clear path
            if not turtle.back() then
                print("Path blocked during return, trying alternative route")
                turtle.turnRight()
                turtle.turnRight()
                
                -- Try to clear path and move forward with multiple attempts
                local success = false
                for attempt = 1, 5 do -- Increased attempts
                    print("Clearing return path attempt " .. attempt)
                    
                    if turtle.detect() then
                        turtle.dig()
                        sleep(1.0) -- Longer wait for blocks to settle
                    end
                    
                    if turtle.forward() then
                        success = true
                        break
                    end
                    
                    -- Wait and try again with more aggressive digging
                    if attempt > 2 and turtle.detect() then
                        print("Using more aggressive digging")
                        for dig = 1, 3 do
                            turtle.dig()
                            sleep(0.8)
                        end
                    end
                    
                    sleep(1.0)
                end
                
                if not success then
                    print("Warning: Could not clear obstacle at step " .. i)
                    print("Attempting alternative navigation...")
                    
                    -- Try going up and over
                    if moveUp() then
                        if moveForward() then
                            if moveDown() then
                                success = true
                            else
                                -- We're stuck up, at least continue
                                print("Warning: Stuck at higher level, continuing")
                                success = true
                            end
                        else
                            -- Try to get back down
                            moveDown()
                            -- Skip this step
                            print("Skipping this step due to blockage")
                        end
                    else
                        print("Could not find alternative path, skipping step")
                    end
                else
                    -- Successfully moved forward, now turn back
                    turtle.turnRight()
                    turtle.turnRight()
                end
            end
        elseif action == "turnRight" then
            turtle.turnRight()
        elseif action == "turnLeft" then
            turtle.turnLeft()
        elseif action == "up" then
            moveUp()
        elseif action == "down" then
            moveDown()
        end
        
        stepsCompleted = stepsCompleted + 1
    end
    
    -- Clear the path to start fresh next time
    movementPath = {}
    print("Returned to starting position - completed " .. stepsCompleted .. " steps")
end

-- Inventory management
function checkInventory()
    -- Start from slot 2 to keep slot 1 for fuel
    for i = 2, 16 do
        if turtle.getItemCount(i) == 0 then
            return true -- Has empty slot
        end
    end
    return false -- Inventory full
end

function dropOffItems()
    print("Inventory full, dropping off items...")
    
    -- Save current movement path
    local savedPath = {}
    for i = 1, #movementPath do
        savedPath[i] = movementPath[i]
    end
    
    -- Return to starting position
    returnHome()
    
    -- Attempt to drop items into a chest below (or specified direction)
    print("Dropping items into chest...")
    
    -- Keep slot 1 for fuel, drop everything else
    for slot = 2, 16 do
        turtle.select(slot)
        local success = false
        
        if dropOffChestDir == "down" then
            success = turtle.dropDown()
        elseif dropOffChestDir == "up" then
            success = turtle.dropUp()
        else -- forward
            success = turtle.drop()
        end
        
        if not success then
            print("Warning: Could not drop items in slot " .. slot)
        end
    end
    
    turtle.select(1) -- Reselect slot 1
    
    print("Returning to mining position...")
    
    -- Now retrace the saved path to get back to mining position
    for i = 1, #savedPath do
        local action = savedPath[i]
        
        if action == "back" then
            moveForward()
        elseif action == "turnLeft" then
            turnLeft()
        elseif action == "turnRight" then
            turnRight()
        elseif action == "up" then
            moveUp()
        elseif action == "down" then
            moveDown()
        end
    end
    
    -- Reset the movement path to what it was before
    movementPath = savedPath
    
    print("Resumed mining operation")
    return true
end

-- Check for ores around current position
function scanForOres()
    local foundOre = false

    -- Check front
    local success, block = safeInspect("forward")
    if success and block and isOre(block.name) then
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
    success, block = safeInspect("up")
    if success and block and isOre(block.name) then
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
    success, block = safeInspect("down")
    if success and block and isOre(block.name) then
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
    success, block = safeInspect("forward")
    if success and block and isOre(block.name) then
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
    success, block = safeInspect("forward")
    if success and block and isOre(block.name) then
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
    -- Check if inventory is full
    if not checkInventory() then
        if not dropOffItems() then
            print("Error: Could not drop off items, terminating mining operation")
            return
        end
    end

    -- Mine current position (if needed)
    local success, block = safeInspect("down")
    if success and block and isOre(block.name) then
        turtle.digDown()
        -- Wait for falling blocks
        sleep(0.5)
    end

    -- Scan surrounding blocks for ores
    for dir = 1, 4 do
        local success, block = safeInspect("forward")
        if success and block and isOre(block.name) then
            if moveForward() then
                local x, y, z = gps.locate()
                if x and not isVisited(x, y, z) then
                    markVisited(x, y, z)
                    mineOreVein()
                end
                -- Try to go back, and if that fails, try to dig out
                if not turtle.back() then
                    turtle.turnRight()
                    turtle.turnRight()
                    if moveForward() then
                        turtle.turnRight()
                        turtle.turnRight()
                    else
                        -- We're stuck, try to find another way
                        print("Warning: Path blocked, finding alternative route")
                        turtle.turnRight()
                        turtle.turnRight()
                    end
                end
            end
        end
        turtle.turnRight()
    end

    -- Check up
    local success, block = safeInspect("up")
    if success and block and isOre(block.name) then
        if moveUp() then
            local x, y, z = gps.locate()
            if x and not isVisited(x, y, z) then
                markVisited(x, y, z)
                mineOreVein()
            end
            -- Try to go down, if it fails, we'll have to find another way
            if not moveDown() then
                print("Warning: Could not return down, finding alternative route")
            end
        end
    end

    -- Check down
    local success, block = safeInspect("down")
    if success and block and isOre(block.name) then
        if moveDown() then
            local x, y, z = gps.locate()
            if x and not isVisited(x, y, z) then
                markVisited(x, y, z)
                mineOreVein()
            end
            -- Try to go up, if it fails, we'll have to find another way
            if not moveUp() then
                print("Warning: Could not return up, finding alternative route")
            end
        end
    end
end

-- Main mining function
function stripMine(length, branches, branchLength)
    -- Keep track of current branch
    local currentBranch = 0
    local branchMovementPath = {}
    local mainShaftMovementPath = {}
    
    for i = 1, branches do
        currentBranch = i
        print("Starting branch " .. i .. " of " .. branches)
        
        -- Turn left to start a branch (perpendicular to main shaft)
        print("Turning left to enter branch")
        turnLeft()
        
        -- Save the state of movement path at the start of the branch
        branchMovementPath = {}
        local oldMovementPath = movementPath
        movementPath = branchMovementPath
        
        -- Mine forward for branch length
        for j = 1, branchLength do
            print("Branch step " .. j .. " of " .. branchLength)
            
            -- Check inventory before mining
            if not checkInventory() then
                if not dropOffItems() then
                    print("Error: Could not drop off items, terminating mining operation")
                    -- Restore the main movement path
                    movementPath = oldMovementPath
                    return false
                end
            end
            
            -- Always dig down for human walkway height
            turtle.digDown()
            
            if not trackForward() then
                print("Path blocked during branch mining at step " .. j)
                
                -- Try multiple times with a more aggressive approach
                local success = false
                for attempt = 1, 3 do
                    print("Clearing path attempt " .. attempt)
                    
                    -- Dig more aggressively
                    if turtle.detect() then
                        turtle.dig()
                        sleep(1.0) -- Longer wait for blocks to settle
                    end
                    
                    if moveForward() then
                        table.insert(movementPath, "back")
                        success = true
                        break
                    end
                    sleep(1.0)
                end
                
                if not success then
                    print("Failed to clear path, returning to main shaft")
                    -- Restore the main movement path
                    movementPath = oldMovementPath
                    
                    -- Return to start of this branch
                    for k = #branchMovementPath, 1, -1 do
                        local action = branchMovementPath[k]
                        if action == "back" then
                            turtle.back()
                        elseif action == "turnRight" then
                            turtle.turnRight()
                        elseif action == "turnLeft" then
                            turtle.turnLeft()
                        elseif action == "up" then
                            moveUp()
                        elseif action == "down" then
                            moveDown()
                        end
                    end
                    
                    -- Skip to next branch
                    break
                end
            end

            local x, y, z = gps.locate()
            if x then
                markVisited(x, y, z)
            end

            -- Check for ores
            scanForOres()
        end
        
        -- Save branch path for potential reuse
        local branchPath = {}
        for k = 1, #branchMovementPath do
            branchPath[k] = branchMovementPath[k]
        end
        
        -- Return to main shaft - traverse the branch path backwards
        print("Returning to main shaft from branch " .. i)
        for k = #branchMovementPath, 1, -1 do
            local action = branchMovementPath[k]
            if action == "back" then
                if not turtle.back() then
                    -- If blocked, turn around and try to move forward
                    turtle.turnRight()
                    turtle.turnRight()
                    if moveForward() then
                        -- Then turn around to maintain original orientation
                        turtle.turnRight()
                        turtle.turnRight()
                    end
                end
            elseif action == "turnRight" then
                turtle.turnRight()
            elseif action == "turnLeft" then
                turtle.turnLeft()
            elseif action == "up" then
                moveUp()
            elseif action == "down" then
                moveDown()
            end
        end
        
        -- Turn right to face along the main shaft again
        print("Turning right to face along main shaft")
        turnRight()
        
        -- Restore the main movement path
        movementPath = oldMovementPath
        
        -- Move forward on main shaft to position for next branch
        if i < branches then
            print("Moving to position for branch " .. (i+1))
            -- Save the state of movement path for the main shaft segment
            mainShaftMovementPath = {}
            local oldMovementPath = movementPath
            movementPath = mainShaftMovementPath
            
            for j = 1, length do
                -- Check inventory before mining
                if not checkInventory() then
                    if not dropOffItems() then
                        print("Error: Could not drop off items, terminating mining operation")
                        -- Restore the original movement path
                        movementPath = oldMovementPath
                        return false
                    end
                end
                
                -- Always dig down for human walkway height
                turtle.digDown()
                
                print("Main shaft step " .. j .. " of " .. length)
                if not trackForward() then
                    print("Path blocked on main shaft at step " .. j)
                    
                    -- Try multiple times with a more aggressive approach
                    local success = false
                    for attempt = 1, 3 do
                        print("Clearing main shaft path attempt " .. attempt)
                        
                        -- Dig more aggressively
                        if turtle.detect() then
                            turtle.dig()
                            sleep(1.0) -- Longer wait for blocks to settle
                        end
                        
                        if moveForward() then
                            table.insert(movementPath, "back")
                            success = true
                            break
                        end
                        sleep(1.0)
                    end
                    
                    if not success then
                        print("Failed to progress on main shaft, ending mining operation")
                        -- Restore the original movement path
                        movementPath = oldMovementPath
                        
                        -- Return to start (home)
                        returnHome()
                        return false
                    end
                end
            end
            
            -- Restore the original movement path but include this segment
            for j = 1, #mainShaftMovementPath do
                table.insert(oldMovementPath, mainShaftMovementPath[j])
            end
            movementPath = oldMovementPath
        end
    end
    return true
end

-- Main program
function start()
    print("Recursive Ore Miner Starting")
    print("Checking for updates...")

    -- Reset global tracking variables
    movementPath = {}
    visited = {}
    mainPath = {}
    
    -- Get user input for mining parameters
    write("Enter branch spacing (default 3): ")
    local lengthInput = read()
    local length = tonumber(lengthInput) or 3 -- Spacing between branches
    
    write("Enter number of branches (default 10): ")
    local branchesInput = read()
    local branches = tonumber(branchesInput) or 10 -- Number of branches
    
    write("Enter branch length (default 10): ")
    local branchLengthInput = read()
    local branchLength = tonumber(branchLengthInput) or 10 -- Length of each branch
    
    write("Enter chest direction for item drop-off (down/up/forward, default down): ")
    local dropDirInput = read()
    dropOffChestDir = dropDirInput ~= "" and dropDirInput or "down"
    
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

    print("Starting strip mine with:")
    print("- Branch spacing: " .. length)
    print("- Number of branches: " .. branches)
    print("- Branch length: " .. branchLength)
    print("- Item drop-off direction: " .. dropOffChestDir)

    -- Initialize GPS coordinates if available
    local x, y, z = gps.locate()
    if x then
        print("Starting position: " .. x .. "," .. y .. "," .. z)
        homeX, homeY, homeZ = x, y, z
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
    local miningSuccess = stripMine(length, branches, branchLength)
    
    if not miningSuccess then
        print("Mining operation interrupted")
    else
        print("Mining operation complete")
    end

    -- Always try to return home, even if mining was interrupted
    print("Returning to start...")
    
    -- Check if we have any path to follow
    if #movementPath > 0 then
        print("Return path has " .. #movementPath .. " steps")
        returnHome()
    else
        print("No return path recorded - already at home position")
    end
    
    print("Mining operation finished")
end

-- Run the program
start()