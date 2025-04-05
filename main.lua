require("utils")
local env = require("env")

-- Turtle Swarm Websocket Architecture

-- Connect to websocket server
local function connectWebsocket()
    while true do
        local ws, err = http.websocket(env.WEBSOCKET_URL)
        if ws then
            print("Connected to websocket server")
            return ws
        else
            print("Connection failed: " .. (err or "unknown error"))
            print("Retrying in 5 seconds...")
            sleep(5)
        end
    end
end

-- Execute commands received from server
local function executeCommand(command)
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

    -- Command handlers
    local handlers = {
        move = function()
            local direction = params.direction
            local success = false

            if direction == "forward" then
                success = turtle.forward()
            elseif direction == "back" then
                success = turtle.back()
            elseif direction == "up" then
                success = turtle.up()
            elseif direction == "down" then
                success = turtle.down()
            elseif direction == "turnLeft" then
                success = turtle.turnLeft()
            elseif direction == "turnRight" then
                success = turtle.turnRight()
            end

            return {
                success = success
            }
        end,

        dig = function()
            local direction = params.direction
            local success = false

            if direction == "forward" or not direction then
                success = turtle.dig()
            elseif direction == "up" then
                success = turtle.digUp()
            elseif direction == "down" then
                success = turtle.digDown()
            end

            return {
                success = success
            }
        end,

        place = function()
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

        -- Add more command handlers as needed
        getInventory = function()
            local inventory = {}
            for i = 1, 16 do
                local item = turtle.getItemDetail(i)
                inventory[i] = item
            end
            return {
                success = true,
                inventory = inventory
            }
        end,

        getFuelLevel = function()
            local level = turtle.getFuelLevel()
            return {
                success = true,
                fuel = level
            }
        end
    }

    -- Execute the command if handler exists
    if handlers[action] then
        local result = handlers[action]()
        if result then
            result.id = command.id -- Echo back the command ID
            result.turtle = env.TURTLE_NAME
            return result
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

-- Main program
local function main()
    local ws = connectWebsocket()

    -- Send initial registration message
    ws.send(textutils.serialiseJSON({
        type = "register",
        turtle = env.TURTLE_NAME,
        time = os.time()
    }))

    -- Start heartbeat in a separate coroutine
    local lastHeartbeat = os.time()

    parallel.waitForAll( -- Message handling coroutine
    function()
        while true do
            local message = ws.receive()
            if message then
                local success, data = pcall(textutils.unserialiseJSON, message)
                if success and data then
                    local response = executeCommand(data)
                    if response then
                        ws.send(textutils.serialiseJSON(response))
                    end
                else
                    print("Received invalid message: " .. message)
                end
            else
                -- Connection closed
                print("Connection closed. Reconnecting...")
                ws = connectWebsocket()
            end
        end
    end, -- Heartbeat coroutine
    function()
        while true do
            local currentTime = os.time()
            if currentTime - lastHeartbeat >= env.HEARTBEAT_INTERVAL then
                ws.send(textutils.serialiseJSON({
                    type = "heartbeat",
                    turtle = env.TURTLE_NAME,
                    time = currentTime,
                    position = {
                        fuel = turtle.getFuelLevel()
                        -- Could add coordinates if you have a GPS system
                    }
                }))
                lastHeartbeat = currentTime
            end
            sleep(0.1) -- Small sleep to prevent tight loop
        end
    end)
end

-- Handle errors in the main program
while true do
    local success, error = pcall(main)
    if not success then
        print("Error in main program: " .. tostring(error))
        print("Restarting in 5 seconds...")
        sleep(5)
    end
end
