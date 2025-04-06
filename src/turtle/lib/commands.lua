-- Command handler module
local env = require("env")
local Movement = require("lib.movement")
local Inventory = require("lib.inventory")
local Fuel = require("lib.fuel")
local Position = require("lib.position")

local Commands = {}

-- Command handler table
Commands.handlers = {
    -- Movement commands
    move = function(params)
        local direction = params.direction
        local success = false
        
        if direction == "forward" then
            success = Movement.safeForward()
        elseif direction == "back" then
            success = Movement.safeBack()
        elseif direction == "up" then
            success = Movement.safeUp()
        elseif direction == "down" then
            success = Movement.safeDown()
        elseif direction == "turnLeft" then
            success = Movement.turnLeft()
        elseif direction == "turnRight" then
            success = Movement.turnRight()
        end
        
        return {
            success = success,
            position = Position.getCurrentPosition()
        }
    end,
    
    -- Digging commands
    dig = function(params)
        local direction = params.direction
        local success = false
        
        if direction == "forward" or not direction then
            success = turtle.dig()
            -- Wait for falling blocks
            if success then os.sleep(0.5) end
        elseif direction == "up" then
            success = turtle.digUp()
            if success then os.sleep(0.5) end
        elseif direction == "down" then
            success = turtle.digDown()
            if success then os.sleep(0.5) end
        end
        
        return {
            success = success
        }
    end,
    
    -- Block placement commands
    place = function(params)
        local direction = params.direction
        local slot = params.slot
        
        if slot then
            turtle.select(slot)
        end
        
        local success = false
        if direction == "forward" or not direction then
            success = turtle.place()
        elseif direction == "up" then
            success = turtle.placeUp()
        elseif direction == "down" then
            success = turtle.placeDown()
        end
        
        return {
            success = success
        }
    end,
    
    -- Inventory commands
    getInventory = function(params)
        local inventory = Inventory.getStatus()
        return {
            success = true,
            inventory = inventory
        }
    end,
    
    -- Fuel commands
    getFuelLevel = function(params)
        local fuelStatus = Fuel.getStatus()
        return {
            success = true,
            fuel = fuelStatus
        }
    end,
    
    -- Refueling commands
    refuel = function(params)
        local targetLevel = params.level or Fuel.LOW_FUEL_THRESHOLD
        local success, newLevel = Fuel.refuelToLevel(targetLevel)
        
        return {
            success = success,
            level = newLevel,
            target = targetLevel
        }
    end,
    
    -- Position commands
    getPosition = function(params)
        local position = Position.getCurrentPosition()
        return {
            success = true,
            position = position
        }
    end,
    
    -- Chest placement
    placeChest = function(params)
        local direction = params.direction or "forward"
        local success = Inventory.placeChest(direction)
        
        return {
            success = success
        }
    end,
    
    -- Complex movement patterns
    walkPath = function(params)
        local path = params.path
        local results = {
            success = true,
            completed = 0,
            total = #path,
            errors = {}
        }
        
        for i, step in ipairs(path) do
            local stepSuccess = false
            
            if step.action == "move" then
                stepSuccess = Movement.walk(step.direction)
            elseif step.action == "turn" then
                if step.direction == "left" then
                    stepSuccess = Movement.turnLeft()
                elseif step.direction == "right" then
                    stepSuccess = Movement.turnRight()
                end
            end
            
            if stepSuccess then
                results.completed = results.completed + 1
            else
                table.insert(results.errors, "Failed at step " .. i .. ": " .. textutils.serialize(step))
                results.success = false
                break
            end
        end
        
        return results
    end,
    
    -- Scan surroundings
    scan = function(params)
        local results = {
            success = true,
            blocks = {}
        }
        
        -- Forward scan
        local fSuccess, fData = turtle.inspect()
        if fSuccess then
            results.blocks.forward = fData
        end
        
        -- Up scan
        local uSuccess, uData = turtle.inspectUp()
        if uSuccess then
            results.blocks.up = uData
        end
        
        -- Down scan
        local dSuccess, dData = turtle.inspectDown()
        if dSuccess then
            results.blocks.down = dData
        end
        
        -- Get position info
        results.position = Position.getCurrentPosition()
        
        return results
    end
}

-- Execute a command
function Commands.executeCommand(command)
    if not command or type(command) ~= "table" then
        return {
            success = false,
            message = "Invalid command format"
        }
    end

    -- Check if command is targeted at all turtles or specifically this turtle
    if command.target ~= "all" and command.target ~= env.TURTLE_NAME then
        return nil -- Not for this turtle
    end

    local action = command.action
    local params = command.params or {}

    -- Execute the command if handler exists
    if Commands.handlers[action] then
        print("Executing action: " .. action)
        print("With params: " .. textutils.serialize(params))
        
        -- Call the handler inside pcall for safety
        local success, result = pcall(function()
            return Commands.handlers[action](params)
        end)
        
        if success and result then
            result.id = command.id -- Echo back the command ID
            result.turtle = env.TURTLE_NAME
            print("Command result: " .. textutils.serialize(result))
            return result
        elseif not success then
            -- Error during command execution
            return {
                success = false,
                message = "Command error: " .. tostring(result),
                id = command.id,
                turtle = env.TURTLE_NAME
            }
        end
    else
        return {
            success = false,
            message = "Unknown command: " .. tostring(action),
            id = command.id,
            turtle = env.TURTLE_NAME
        }
    end
end

return Commands