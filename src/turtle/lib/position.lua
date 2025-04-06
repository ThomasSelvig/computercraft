-- Position tracking module
local Position = {}

-- Initialize position tracking
Position.position = { x = 0, y = 0, z = 0, facing = 0 } -- 0=north, 1=east, 2=south, 3=west
Position.initialized = false

-- Load position from file if it exists
function Position.loadPosition()
    if fs.exists("position.json") then
        local file = fs.open("position.json", "r")
        Position.position = textutils.unserialiseJSON(file.readAll())
        file.close()
        Position.initialized = true
        return true
    end
    return false
end

-- Save position to file
function Position.savePosition()
    local file = fs.open("position.json", "w")
    file.write(textutils.serialiseJSON(Position.position))
    file.close()
end

-- Update position based on movement
function Position.updatePosition(action)
    if not Position.initialized then
        Position.initialized = true
    end

    if action == "forward" then
        if Position.position.facing == 0 then Position.position.z = Position.position.z - 1
        elseif Position.position.facing == 1 then Position.position.x = Position.position.x + 1
        elseif Position.position.facing == 2 then Position.position.z = Position.position.z + 1
        elseif Position.position.facing == 3 then Position.position.x = Position.position.x - 1 end
    elseif action == "back" then
        if Position.position.facing == 0 then Position.position.z = Position.position.z + 1
        elseif Position.position.facing == 1 then Position.position.x = Position.position.x - 1
        elseif Position.position.facing == 2 then Position.position.z = Position.position.z - 1
        elseif Position.position.facing == 3 then Position.position.x = Position.position.x + 1 end
    elseif action == "up" then
        Position.position.y = Position.position.y + 1
    elseif action == "down" then
        Position.position.y = Position.position.y - 1
    elseif action == "turnRight" then
        Position.position.facing = (Position.position.facing + 1) % 4
    elseif action == "turnLeft" then
        Position.position.facing = (Position.position.facing - 1) % 4
        if Position.position.facing < 0 then
            Position.position.facing = Position.position.facing + 4
        end
    end

    -- Save position to file for persistence
    Position.savePosition()
end

-- Convert facing number to string
function Position.getFacingString()
    local facings = { "north", "east", "south", "west" }
    return facings[Position.position.facing + 1]
end

-- Get current position as a table
function Position.getCurrentPosition()
    local pos = {
        x = Position.position.x,
        y = Position.position.y,
        z = Position.position.z,
        heading = Position.getFacingString(),
        fuel = turtle.getFuelLevel()
    }
    return pos
end

-- Initialize position tracking
Position.loadPosition()

return Position