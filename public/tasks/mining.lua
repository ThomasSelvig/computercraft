-- Mining task module
local Position = require("lib.position")
local Movement = require("lib.movement")
local Inventory = require("lib.inventory")
local Fuel = require("lib.fuel")

local Mining = {}

-- Mine in a rectangular pattern
function Mining.mineRectangle(width, depth, returnHome)
    -- Default to returning home if not specified
    if returnHome == nil then
        returnHome = true
    end
    
    -- Save initial position for return
    local startX = Position.position.x
    local startY = Position.position.y
    local startZ = Position.position.z
    local startFacing = Position.position.facing
    
    -- Calculate fuel requirements
    local requiredFuel = Fuel.calculateRequiredFuel(depth, width)
    local fuelOk, fuelLevel = Fuel.checkFuel(requiredFuel)
    
    if not fuelOk then
        print("Not enough fuel for mining operation!")
        print("Required: " .. requiredFuel .. ", Current: " .. fuelLevel)
        return false, "Insufficient fuel"
    end
    
    -- Statistics
    local stats = {
        blocksDigged = 0,
        movesFailed = 0,
        itemsCollected = 0,
        initialInventorySpace = Inventory.availableSlots()
    }
    
    -- Start mining pattern
    for z = 1, depth do
        for x = 1, width do
            -- Always dig forward
            if turtle.detect() then
                if turtle.dig() then
                    stats.blocksDigged = stats.blocksDigged + 1
                    os.sleep(0.5) -- Wait for falling blocks
                end
            end
            
            -- Try to move forward
            if x < width then
                if not Movement.safeForward() then
                    stats.movesFailed = stats.movesFailed + 1
                end
            end
        end
        
        -- Check if inventory is full
        if Inventory.availableSlots() < 2 then
            print("Inventory almost full, consider returning to base")
        end
        
        -- At the end of the row, turn around for the next row
        if z < depth then
            if z % 2 == 1 then
                -- At end of odd-numbered row, turn right
                Movement.turnRight()
                if not Movement.safeForward() then
                    stats.movesFailed = stats.movesFailed + 1
                end
                Movement.turnRight()
            else
                -- At end of even-numbered row, turn left
                Movement.turnLeft()
                if not Movement.safeForward() then
                    stats.movesFailed = stats.movesFailed + 1
                end
                Movement.turnLeft()
            end
        end
    end
    
    -- Calculate collected items
    stats.itemsCollected = stats.initialInventorySpace - Inventory.availableSlots()
    
    -- Return to starting position if required
    if returnHome then
        print("Mining complete. Returning to starting position...")
        
        -- Calculate the path back - simplified version
        local dx = startX - Position.position.x
        local dy = startY - Position.position.y
        local dz = startZ - Position.position.z
        
        -- Move back to starting coordinates
        -- Handle Y-axis first
        while Position.position.y < startY do
            Movement.safeUp()
        end
        while Position.position.y > startY do
            Movement.safeDown()
        end
        
        -- Turn to face the right direction for X/Z movement
        -- This is a simplified approach - a full pathfinding solution would be more robust
        if dx < 0 then
            -- Need to go west
            while Position.position.facing ~= 3 do
                Movement.turnLeft()
            end
        elseif dx > 0 then
            -- Need to go east
            while Position.position.facing ~= 1 do
                Movement.turnLeft()
            end
        elseif dz < 0 then
            -- Need to go north
            while Position.position.facing ~= 0 do
                Movement.turnLeft()
            end
        elseif dz > 0 then
            -- Need to go south
            while Position.position.facing ~= 2 do
                Movement.turnLeft()
            end
        end
        
        -- Move X and Z to get back to start
        for i = 1, math.abs(dx) do
            Movement.safeForward()
        end
        
        -- Turn to Z direction if needed
        if dz < 0 then
            -- Need to go north
            while Position.position.facing ~= 0 do
                Movement.turnLeft()
            end
        elseif dz > 0 then
            -- Need to go south
            while Position.position.facing ~= 2 do
                Movement.turnLeft()
            end
        end
        
        for i = 1, math.abs(dz) do
            Movement.safeForward()
        end
        
        -- Turn to original facing
        while Position.position.facing ~= startFacing do
            Movement.turnLeft()
        end
    end
    
    print("Mining operation complete!")
    print("Blocks dug: " .. stats.blocksDigged)
    print("Items collected: " .. stats.itemsCollected)
    print("Movement errors: " .. stats.movesFailed)
    
    return true, stats
end

-- Directional mining task
function Mining.mineInDirection(direction, length, returnHome)
    returnHome = returnHome or true
    local steps = 0
    local blocksDigged = 0
    
    -- Save initial position
    local startX = Position.position.x
    local startY = Position.position.y
    local startZ = Position.position.z
    local startFacing = Position.position.facing
    
    -- Turn to face the correct direction
    if direction == "north" and Position.position.facing ~= 0 then
        while Position.position.facing ~= 0 do
            Movement.turnLeft()
        end
    elseif direction == "east" and Position.position.facing ~= 1 then
        while Position.position.facing ~= 1 do
            Movement.turnLeft()
        end
    elseif direction == "south" and Position.position.facing ~= 2 then
        while Position.position.facing ~= 2 do
            Movement.turnLeft()
        end
    elseif direction == "west" and Position.position.facing ~= 3 then
        while Position.position.facing ~= 3 do
            Movement.turnLeft()
        end
    end
    
    -- Mine forward for the specified length
    for i = 1, length do
        if turtle.detect() then
            if turtle.dig() then
                blocksDigged = blocksDigged + 1
                os.sleep(0.5) -- Wait for falling blocks
            end
        end
        
        if Movement.safeForward() then
            steps = steps + 1
        else
            print("Failed to move forward after " .. steps .. " steps")
            break
        end
        
        -- Check if inventory is getting full
        if Inventory.availableSlots() < 2 then
            print("Inventory almost full")
            if returnHome then
                break
            end
        end
    end
    
    if returnHome then
        print("Returning to start position...")
        
        -- Turn around
        Movement.turnLeft()
        Movement.turnLeft()
        
        -- Move back the number of steps we went forward
        for i = 1, steps do
            if not Movement.safeForward() then
                print("Failed while returning home at step " .. i)
                break
            end
        end
        
        -- Turn back to original facing
        while Position.position.facing ~= startFacing do
            Movement.turnLeft()
        end
    end
    
    return {
        success = true,
        blocksDigged = blocksDigged,
        stepsTaken = steps,
        returnedHome = returnHome
    }
end

-- Ore vein detection and mining
function Mining.mineOreVein(maxBlocks)
    maxBlocks = maxBlocks or 64 -- Default limit to avoid getting lost
    local blocksMinedTotal = 0
    local veinBlocks = {}
    
    -- Function to check if a block is an ore
    local function isOre(inspectFunc)
        local success, data = inspectFunc()
        if success then
            -- Check if the block name contains "ore"
            return string.find(data.name, "ore") ~= nil, data.name
        end
        return false, nil
    end
    
    -- Function to check and mine ores in all directions
    local function checkAndMineOres()
        local mined = 0
        
        -- Check forward
        local isFwOre, oreName = isOre(turtle.inspect)
        if isFwOre then
            print("Mining ore: " .. oreName)
            turtle.dig()
            os.sleep(0.5) -- Wait for falling blocks
            Movement.safeForward()
            mined = mined + 1
            
            -- Add current position to vein blocks
            table.insert(veinBlocks, {
                x = Position.position.x,
                y = Position.position.y,
                z = Position.position.z
            })
            
            -- Recursively check from new position
            if blocksMinedTotal + mined < maxBlocks then
                mined = mined + checkAndMineOres()
            end
            
            -- Move back
            Movement.turnLeft()
            Movement.turnLeft()
            Movement.safeForward()
            Movement.turnLeft()
            Movement.turnLeft()
        end
        
        -- Check up
        local isUpOre, upOreName = isOre(turtle.inspectUp)
        if isUpOre then
            print("Mining ore above: " .. upOreName)
            turtle.digUp()
            os.sleep(0.5)
            Movement.safeUp()
            mined = mined + 1
            
            -- Add current position to vein blocks
            table.insert(veinBlocks, {
                x = Position.position.x,
                y = Position.position.y,
                z = Position.position.z
            })
            
            -- Recursively check from new position
            if blocksMinedTotal + mined < maxBlocks then
                mined = mined + checkAndMineOres()
            end
            
            -- Move back
            Movement.safeDown()
        end
        
        -- Check down
        local isDownOre, downOreName = isOre(turtle.inspectDown)
        if isDownOre then
            print("Mining ore below: " .. downOreName)
            turtle.digDown()
            os.sleep(0.5)
            Movement.safeDown()
            mined = mined + 1
            
            -- Add current position to vein blocks
            table.insert(veinBlocks, {
                x = Position.position.x,
                y = Position.position.y,
                z = Position.position.z
            })
            
            -- Recursively check from new position
            if blocksMinedTotal + mined < maxBlocks then
                mined = mined + checkAndMineOres()
            end
            
            -- Move back
            Movement.safeUp()
        end
        
        -- Check left
        Movement.turnLeft()
        local isLeftOre, leftOreName = isOre(turtle.inspect)
        if isLeftOre then
            print("Mining ore to the left: " .. leftOreName)
            turtle.dig()
            os.sleep(0.5)
            Movement.safeForward()
            mined = mined + 1
            
            -- Add current position to vein blocks
            table.insert(veinBlocks, {
                x = Position.position.x,
                y = Position.position.y,
                z = Position.position.z
            })
            
            -- Recursively check from new position
            if blocksMinedTotal + mined < maxBlocks then
                mined = mined + checkAndMineOres()
            end
            
            -- Move back
            Movement.turnLeft()
            Movement.turnLeft()
            Movement.safeForward()
            Movement.turnRight()
        else
            Movement.turnRight()
        end
        
        -- Check right
        Movement.turnRight()
        local isRightOre, rightOreName = isOre(turtle.inspect)
        if isRightOre then
            print("Mining ore to the right: " .. rightOreName)
            turtle.dig()
            os.sleep(0.5)
            Movement.safeForward()
            mined = mined + 1
            
            -- Add current position to vein blocks
            table.insert(veinBlocks, {
                x = Position.position.x,
                y = Position.position.y,
                z = Position.position.z
            })
            
            -- Recursively check from new position
            if blocksMinedTotal + mined < maxBlocks then
                mined = mined + checkAndMineOres()
            end
            
            -- Move back
            Movement.turnLeft()
            Movement.turnLeft()
            Movement.safeForward()
            Movement.turnLeft()
        else
            Movement.turnLeft()
        end
        
        return mined
    end
    
    -- Start checking and mining from current position
    blocksMinedTotal = checkAndMineOres()
    
    print("Vein mining complete!")
    print("Mined " .. blocksMinedTotal .. " ore blocks")
    
    return {
        success = true,
        blocksMinedTotal = blocksMinedTotal,
        veinBlocks = veinBlocks
    }
end

return Mining