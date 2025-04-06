-- Enhanced movement module with error handling
local Position = require("lib.position")
local env = require("env")

local Movement = {}

-- Maximum attempts for movement operations
Movement.MAX_ATTEMPTS = 3

-- Safe forward movement with obstacle handling
function Movement.safeForward()
    local attempts = 0
    while attempts < Movement.MAX_ATTEMPTS do
        local success, error = pcall(function()
            if turtle.detect() then
                turtle.dig()
                os.sleep(0.5) -- Wait for falling blocks
                if turtle.detect() then
                    return false -- Still blocked
                end
            end
            return turtle.forward()
        end)

        if success and error then
            Position.updatePosition("forward")
            return true
        end

        attempts = attempts + 1
        if attempts < Movement.MAX_ATTEMPTS then
            os.sleep(0.5)
        end
    end

    return false
end

-- Safe backward movement
function Movement.safeBack()
    local success = turtle.back()
    if success then
        Position.updatePosition("back")
    end
    return success
end

-- Safe upward movement with obstacle handling
function Movement.safeUp()
    local attempts = 0
    while attempts < Movement.MAX_ATTEMPTS do
        local success, error = pcall(function()
            if turtle.detectUp() then
                turtle.digUp()
                os.sleep(0.5) -- Wait for falling blocks
                if turtle.detectUp() then
                    return false -- Still blocked
                end
            end
            return turtle.up()
        end)

        if success and error then
            Position.updatePosition("up")
            return true
        end

        attempts = attempts + 1
        if attempts < Movement.MAX_ATTEMPTS then
            os.sleep(0.5)
        end
    end

    return false
end

-- Safe downward movement with obstacle handling
function Movement.safeDown()
    local attempts = 0
    while attempts < Movement.MAX_ATTEMPTS do
        local success, error = pcall(function()
            if turtle.detectDown() then
                turtle.digDown()
                os.sleep(0.5) -- Wait for falling blocks
                if turtle.detectDown() then
                    return false -- Still blocked
                end
            end
            return turtle.down()
        end)

        -- wtf?
        if success and error then
            Position.updatePosition("down")
            return true
        end

        attempts = attempts + 1
        if attempts < Movement.MAX_ATTEMPTS then
            os.sleep(0.5)
        end
    end

    return false
end

-- Turn left and update position
function Movement.turnLeft()
    local success = turtle.turnLeft()
    if success then
        Position.updatePosition("turnLeft")
    end
    return success
end

-- Turn right and update position
function Movement.turnRight()
    local success = turtle.turnRight()
    if success then
        Position.updatePosition("turnRight")
    end
    return success
end

-- Persistent walk function that handles obstacles
function Movement.walk(dir)
    -- dirs: up, down, forward, back (in string form)
    if dir == "forward" then
        return Movement.safeForward()
    elseif dir == "back" then
        return Movement.safeBack()
    elseif dir == "up" then
        return Movement.safeUp()
    elseif dir == "down" then
        return Movement.safeDown()
    end
    return false
end

-- Move to a specific relative position
function Movement.moveTo(relX, relY, relZ)
    local results = {
        success = true,
        steps = 0,
        errors = {}
    }

    -- Move vertically first
    if relY > 0 then
        for i = 1, relY do
            if not Movement.safeUp() then
                table.insert(results.errors, "Failed to move up at step " .. results.steps)
                results.success = false
                return results
            end
            results.steps = results.steps + 1
        end
    elseif relY < 0 then
        for i = 1, math.abs(relY) do
            if not Movement.safeDown() then
                table.insert(results.errors, "Failed to move down at step " .. results.steps)
                results.success = false
                return results
            end
            results.steps = results.steps + 1
        end
    end

    -- Handle X and Z movements based on current facing
    local pos = Position.getCurrentPosition()

    -- Implement the rest of the moveTo logic
    -- This is a simplified version - a complete implementation would need
    -- to calculate turns and movements based on current facing

    return results
end

return Movement
