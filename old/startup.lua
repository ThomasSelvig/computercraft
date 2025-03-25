-- Recursive Ore Miner
-- Turtle program that strip mines, recursively follows ore veins, and returns to main path
-- Global variables
local mainPath = {} -- Track main path for returning
local visited = {} -- Track visited blocks to avoid loops
-- List of ore types for pattern matching
local orePatterns = {
    "ore", -- Catches all ores with "ore" in the name
    "crystal", -- Various modded crystals
    "gem", -- Gem ores
    "mineral", -- Mineral blocks
    "quartz", -- Nether quartz and variants
    "ruby", -- Common modded gems
    "sapphire", -- Common modded gems
    "uranium", -- Tech mods
    "aluminum", -- Tech mods
    "nickel", -- Tech mods
    "silver", -- Tech mods
    "lead", -- Tech mods
    "platinum", -- Tech mods
    "iridium", -- Tech mods
    "tin", -- Tech mods
    "zinc", -- Tech mods
    "cobalt", -- Tinkers Construct
    "ardite" -- Tinkers Construct
}
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
    
    -- Convert blockName to lowercase for case-insensitive matching
    local lowerName = blockName:lower()
    
    -- Check against all ore patterns
    for _, pattern in ipairs(orePatterns) do
        if lowerName:find(pattern:lower()) then
            return true
        end
    end
    
    -- Additional checks for specific ores or mods that might not follow pattern
    -- For example, some mods use specific naming conventions
    if lowerName:find("shiny") or lowerName:find("ferrous") or 
       lowerName:find("bauxite") or lowerName:find("osmium") or
       lowerName:find("dense") or lowerName:find("rich") or
       lowerName:find("diamond") or lowerName:find("emerald") then
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
    if success and block then
        print("scanForOres inspecting forward: " .. (block.name or "unknown"))
        if isOre(block.name) then
            print("scanForOres found ore forward: " .. block.name)
            foundOre = true
            turtle.dig() -- Mine the ore
            sleep(0.5) -- Wait for blocks to settle
            
            if moveForward() then
                local x, y, z = gps.locate()
                if x then
                    local posKey = getVisitedKey(x, y, z)
                    print("Moved to position: " .. posKey)
                    markVisited(x, y, z)
                    print("Recursively mining ore vein at " .. posKey)
                    mineOreVein()
                else
                    print("GPS not available, mining anyway")
                    mineOreVein()
                end
                -- Return to path
                if not turtle.back() then
                    print("Cannot go back, trying alternative path")
                    turtle.turnRight()
                    turtle.turnRight()
                    if moveForward() then
                        turtle.turnRight()
                        turtle.turnRight()
                    end
                end
            end
        end
    end

    -- Check up
    success, block = safeInspect("up")
    if success and block then
        print("scanForOres inspecting up: " .. (block.name or "unknown"))
        if isOre(block.name) then
            print("scanForOres found ore above: " .. block.name)
            foundOre = true
            turtle.digUp() -- Mine the ore
            sleep(0.5) -- Wait for blocks to settle
            
            if moveUp() then
                local x, y, z = gps.locate()
                if x then
                    local posKey = getVisitedKey(x, y, z)
                    print("Moved up to position: " .. posKey)
                    markVisited(x, y, z)
                    print("Recursively mining ore vein at " .. posKey)
                    mineOreVein()
                else
                    print("GPS not available, mining anyway")
                    mineOreVein()
                end
                -- Return to path
                if not moveDown() then
                    print("Cannot move down, stuck at higher level")
                end
            end
        end
    end

    -- Check down
    success, block = safeInspect("down")
    if success and block then
        print("scanForOres inspecting down: " .. (block.name or "unknown"))
        if isOre(block.name) then
            print("scanForOres found ore below: " .. block.name)
            foundOre = true
            turtle.digDown() -- Mine the ore
            sleep(0.5) -- Wait for blocks to settle
            
            if moveDown() then
                local x, y, z = gps.locate()
                if x then
                    local posKey = getVisitedKey(x, y, z)
                    print("Moved down to position: " .. posKey)
                    markVisited(x, y, z)
                    print("Recursively mining ore vein at " .. posKey)
                    mineOreVein()
                else
                    print("GPS not available, mining anyway")
                    mineOreVein()
                end
                -- Return to path
                if not moveUp() then
                    print("Cannot move up, stuck at lower level")
                end
            end
        end
    end

    -- Check right
    turtle.turnRight()
    success, block = safeInspect("forward")
    if success and block then
        print("scanForOres inspecting right: " .. (block.name or "unknown"))
        if isOre(block.name) then
            print("scanForOres found ore to the right: " .. block.name)
            foundOre = true
            turtle.dig() -- Mine the ore
            sleep(0.5) -- Wait for blocks to settle
            
            if moveForward() then
                local x, y, z = gps.locate()
                if x then
                    local posKey = getVisitedKey(x, y, z)
                    print("Moved right to position: " .. posKey)
                    markVisited(x, y, z)
                    print("Recursively mining ore vein at " .. posKey)
                    mineOreVein()
                else
                    print("GPS not available, mining anyway")
                    mineOreVein()
                end
                -- Return to path
                if not turtle.back() then
                    print("Cannot go back, trying alternative path")
                    turtle.turnRight()
                    turtle.turnRight()
                    if moveForward() then
                        turtle.turnRight()
                        turtle.turnRight()
                    end
                end
            end
        end
    end
    turtle.turnLeft()

    -- Check left
    turtle.turnLeft()
    success, block = safeInspect("forward")
    if success and block then
        print("scanForOres inspecting left: " .. (block.name or "unknown"))
        if isOre(block.name) then
            print("scanForOres found ore to the left: " .. block.name)
            foundOre = true
            turtle.dig() -- Mine the ore
            sleep(0.5) -- Wait for blocks to settle
            
            if moveForward() then
                local x, y, z = gps.locate()
                if x then
                    local posKey = getVisitedKey(x, y, z)
                    print("Moved left to position: " .. posKey)
                    markVisited(x, y, z)
                    print("Recursively mining ore vein at " .. posKey)
                    mineOreVein()
                else
                    print("GPS not available, mining anyway")
                    mineOreVein()
                end
                -- Return to path
                if not turtle.back() then
                    print("Cannot go back, trying alternative path")
                    turtle.turnRight()
                    turtle.turnRight()
                    if moveForward() then
                        turtle.turnRight()
                        turtle.turnRight()
                    end
                end
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
        if success and block then
            print("Inspecting block: " .. (block.name or "unknown"))
            if isOre(block.name) then
                print("Found ore: " .. block.name)
                turtle.dig() -- Mine the ore first
                sleep(0.5) -- Wait for blocks to settle
                
                if moveForward() then
                    local x, y, z = gps.locate()
                    if x then
                        local posKey = getVisitedKey(x, y, z)
                        print("Moved to position: " .. posKey)
                        if not isVisited(x, y, z) then
                            markVisited(x, y, z)
                            print("Recursively mining ore vein at " .. posKey)
                            mineOreVein()
                        else
                            print("Already visited this position")
                        end
                    else
                        print("GPS not available, mining anyway")
                        mineOreVein()
                    end
                    
                    -- Try to go back, and if that fails, try to dig out
                    if not turtle.back() then
                        print("Cannot go back, turning around to try alternate route")
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
        end
        turtle.turnRight()
    end

    -- Check up
    local success, block = safeInspect("up")
    if success and block then
        print("Inspecting block above: " .. (block.name or "unknown"))
        if isOre(block.name) then
            print("Found ore above: " .. block.name)
            turtle.digUp() -- Mine the ore first
            sleep(0.5) -- Wait for blocks to settle
            
            if moveUp() then
                local x, y, z = gps.locate()
                if x then
                    local posKey = getVisitedKey(x, y, z)
                    print("Moved up to position: " .. posKey)
                    if not isVisited(x, y, z) then
                        markVisited(x, y, z)
                        print("Recursively mining ore vein at " .. posKey)
                        mineOreVein()
                    else
                        print("Already visited this position")
                    end
                else
                    print("GPS not available, mining anyway")
                    mineOreVein()
                end
                
                -- Try to go down, if it fails, we'll have to find another way
                if not moveDown() then
                    print("Warning: Could not return down, finding alternative route")
                end
            end
        end
    end

    -- Check down
    local success, block = safeInspect("down")
    if success and block then
        print("Inspecting block below: " .. (block.name or "unknown"))
        if isOre(block.name) then
            print("Found ore below: " .. block.name)
            turtle.digDown() -- Mine the ore first
            sleep(0.5) -- Wait for blocks to settle
            
            if moveDown() then
                local x, y, z = gps.locate()
                if x then
                    local posKey = getVisitedKey(x, y, z)
                    print("Moved down to position: " .. posKey)
                    if not isVisited(x, y, z) then
                        markVisited(x, y, z)
                        print("Recursively mining ore vein at " .. posKey)
                        mineOreVein()
                    else
                        print("Already visited this position")
                    end
                else
                    print("GPS not available, mining anyway")
                    mineOreVein()
                end
                
                -- Try to go up, if it fails, we'll have to find another way
                if not moveUp() then
                    print("Warning: Could not return up, finding alternative route")
                end
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
    
    write("Show current ore patterns? (y/n, default n): ")
    local showPatternsInput = read()
    if showPatternsInput:lower() == "y" then
        print("Current ore detection patterns:")
        for i, pattern in ipairs(orePatterns) do
            print(i .. ": " .. pattern)
        end
    end
    
    write("Add custom ore patterns to mine? (y/n, default n): ")
    local customOresInput = read()
    if customOresInput:lower() == "y" then
        write("Enter custom ore patterns (comma-separated): ")
        local customPatterns = read()
        if customPatterns and customPatterns ~= "" then
            for pattern in customPatterns:gmatch("[^,]+") do
                -- Trim whitespace
                pattern = pattern:match("^%s*(.-)%s*$")
                if pattern ~= "" then
                    table.insert(orePatterns, pattern)
                    print("Added pattern: " .. pattern)
                end
            end
        end
        
        -- Option to exclude specific patterns
        write("Exclude any patterns? (y/n, default n): ")
        local excludeInput = read()
        if excludeInput:lower() == "y" then
            write("Enter pattern numbers to exclude (comma-separated): ")
            local excludeNums = read()
            if excludeNums and excludeNums ~= "" then
                local toRemove = {}
                for numStr in excludeNums:gmatch("[^,]+") do
                    local num = tonumber(numStr:match("^%s*(.-)%s*$"))
                    if num and orePatterns[num] then
                        table.insert(toRemove, num)
                    end
                end
                
                -- Remove from highest index to lowest to avoid shifting problems
                table.sort(toRemove, function(a, b) return a > b end)
                for _, index in ipairs(toRemove) do
                    print("Removed pattern: " .. orePatterns[index])
                    table.remove(orePatterns, index)
                end
            end
        end
    end
    
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
    print("- Using " .. #orePatterns .. " ore detection patterns")

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