-- Utility functions for ComputerCraft turtles
local utils = {}

-- Update mechanism configuration
utils.UPDATE_URL = "http://127.0.0.1:1337/startup.lua"

-- Self-update mechanism
function utils.checkForUpdates(scriptName, currentVersion)
    print("Checking for updates...")

    -- Check if HTTP API is available (needed for updates)
    if not http then
        print("HTTP API not enabled. Cannot check for updates.")
        return false
    end

    local response = http.get(utils.UPDATE_URL)

    if not response then
        print("Could not connect to update server.")
        return false
    end

    local newScript = response.readAll()
    response.close()

    -- Parse version from the downloaded script
    local newVersion = string.match(newScript, 'VERSION%s*=%s*"([%d%.]+)"')

    if not newVersion then
        print("Could not determine version of downloaded script.")
        return false
    end

    -- Compare versions
    local currentMajor, currentMinor, currentPatch = string.match(currentVersion, "(%d+)%.(%d+)%.(%d+)")
    local newMajor, newMinor, newPatch = string.match(newVersion, "(%d+)%.(%d+)%.(%d+)")

    currentMajor, currentMinor, currentPatch = tonumber(currentMajor), tonumber(currentMinor), tonumber(currentPatch)
    newMajor, newMinor, newPatch = tonumber(newMajor), tonumber(newMinor), tonumber(newPatch)

    -- Check if new version is newer
    local isNewer = false
    if newMajor > currentMajor then
        isNewer = true
    elseif newMajor == currentMajor and newMinor > currentMinor then
        isNewer = true
    elseif newMajor == currentMajor and newMinor == currentMinor and newPatch > currentPatch then
        isNewer = true
    end

    if isNewer then
        print("New version available: " .. newVersion)
        print("Current version: " .. currentVersion)

        print("Do you want to update? (y/n)")
        local input = read():lower()

        if input == "y" then
            -- Backup the current script
            local currentScript = fs.open(shell.getRunningProgram(), "r")
            local backup = currentScript.readAll()
            currentScript.close()

            local backupFile = fs.open(shell.getRunningProgram() .. ".backup", "w")
            backupFile.write(backup)
            backupFile.close()

            -- Write the new script
            local scriptFile = fs.open(shell.getRunningProgram(), "w")
            scriptFile.write(newScript)
            scriptFile.close()

            print("Update complete! Restarting...")
            sleep(1)
            os.reboot()
            return true
        else
            print("Update cancelled.")
            return false
        end
    else
        print("No updates available. Running version " .. currentVersion)
        return false
    end
end

-- Movement tracking helper
function utils.withTrackedMovements(fn)
    -- Track position and orientation for return path
    local x, y, z = 0, 0, 0
    local direction = 0  -- 0=north, 1=east, 2=south, 3=west
    local movements = {}

    local function recordMove(moveType)
        table.insert(movements, moveType)
        
        -- Update position based on movement
        if moveType == "forward" then
            if direction == 0 then z = z - 1
            elseif direction == 1 then x = x + 1
            elseif direction == 2 then z = z + 1
            elseif direction == 3 then x = x - 1 end
        elseif moveType == "up" then
            y = y + 1
        elseif moveType == "down" then
            y = y - 1
        elseif moveType == "back" then
            if direction == 0 then z = z + 1
            elseif direction == 1 then x = x - 1
            elseif direction == 2 then z = z - 1
            elseif direction == 3 then x = x + 1 end
        elseif moveType == "turnLeft" then
            direction = (direction - 1) % 4
        elseif moveType == "turnRight" then
            direction = (direction + 1) % 4
        end
    end

    -- Store original functions
    local originalForward = turtle.forward
    local originalUp = turtle.up
    local originalDown = turtle.down
    local originalTurnLeft = turtle.turnLeft
    local originalTurnRight = turtle.turnRight
    local originalBack = turtle.back
    
    -- Wrap original functions with tracking
    local function trackedForward()
        local success = originalForward()
        if success then recordMove("forward") end
        return success
    end
    
    local function trackedUp()
        local success = originalUp()
        if success then recordMove("up") end
        return success
    end
    
    local function trackedDown()
        local success = originalDown()
        if success then recordMove("down") end
        return success
    end
    
    local function trackedTurnLeft()
        local success = originalTurnLeft()
        if success then recordMove("turnLeft") end
        return success
    end
    
    local function trackedTurnRight()
        local success = originalTurnRight()
        if success then recordMove("turnRight") end
        return success
    end
    
    local function trackedBack()
        local success = originalBack()
        if success then recordMove("back") end
        return success
    end
    
    -- Temporarily replace functions with tracked versions
    turtle.forward = trackedForward
    turtle.up = trackedUp
    turtle.down = trackedDown
    turtle.turnLeft = trackedTurnLeft
    turtle.turnRight = trackedTurnRight
    turtle.back = trackedBack
    
    -- Call the original function
    local result = fn()
    
    -- After function completes, return to starting position
    print("Returning to starting position...")
    for i = #movements, 1, -1 do
        local move = movements[i]
        if move == "forward" then
            turtle.back()
        elseif move == "up" then
            turtle.down()
        elseif move == "down" then
            turtle.up()
        elseif move == "back" then
            turtle.forward()
        elseif move == "turnLeft" then
            turtle.turnRight()
        elseif move == "turnRight" then
            turtle.turnLeft()
        end
    end
    
    -- Restore original functions
    turtle.forward = originalForward
    turtle.up = originalUp
    turtle.down = originalDown
    turtle.turnLeft = originalTurnLeft
    turtle.turnRight = originalTurnRight
    turtle.back = originalBack
    
    return result
end

return utils