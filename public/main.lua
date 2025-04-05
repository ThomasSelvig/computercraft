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
        print("Executing action: " .. action)
        print("With params: " .. textutils.serialize(params))
        local result = handlers[action]()
        if result then
            result.id = command.id -- Echo back the command ID
            result.turtle = env.TURTLE_NAME
            print("Command result: " .. textutils.serialize(result))
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
    print("Sending registration message")
    local success, err = pcall(function()
        ws.send(textutils.serialiseJSON({
            type = "register",
            turtle = env.TURTLE_NAME,
            time = os.clock()
        }))
    end)

    if success then
        print("Registration message sent successfully")
    else
        print("Failed to send registration: " .. tostring(err))
        error("Failed to register with server")
    end

    -- Start heartbeat in a separate coroutine
    local lastHeartbeat = os.clock()

    parallel.waitForAll( -- Message handling coroutine
    function()
        print("Starting message handling coroutine")
        while true do
            local timeout = 5
            local timer = os.startTimer(timeout)

            -- Wait for a message or a timeout
            local event, param1, param2 = os.pullEvent()

            if event == "timer" and param1 == timer then
                -- Timeout occurred (no message received within timeout period)
                print("No messages received for " .. timeout .. " seconds, checking connection...")

                -- Test connection with a ping
                local pingSuccess, pingErr = pcall(function()
                    ws.send(textutils.serialiseJSON({
                        type = "ping",
                        turtle = env.TURTLE_NAME,
                        time = os.clock()
                    }))
                end)

                if not pingSuccess then
                    print("Ping failed, connection lost. Reconnecting...")
                    ws = connectWebsocket()
                else
                    print("Ping successful, connection still active")
                end
            elseif event == "websocket_message" then
                -- We received a message
                local message = param2
                if message then
                    -- print("Debug - Raw message received: " .. tostring(message))
                    -- print("Debug - Message type: " .. type(message))
                    -- print("Debug - Message length: " .. #tostring(message))

                    -- Try to parse as JSON
                    local success, data = pcall(textutils.unserialiseJSON, message)
                    if success and data then
                        print("Received command: " .. textutils.serialize(data))
                        local response = executeCommand(data)
                        if response then
                            ws.send(textutils.serialiseJSON(response))
                        end
                    else
                        print("Failed to parse JSON: " .. tostring(message))
                        -- Try to handle different formats
                        if type(message) == "string" and message:match("^wss?://") then
                            -- This seems to be a URL, not a JSON message
                            print("Received URL instead of JSON command")
                        else
                            -- Try to extract any valid content
                            local extracted = message:match("{.*}")
                            if extracted then
                                print("Attempting to parse extracted JSON: " .. extracted)
                                local extractSuccess, extractData = pcall(textutils.unserialiseJSON, extracted)
                                if extractSuccess and extractData then
                                    print("Successfully extracted command: " .. textutils.serialize(extractData))
                                    local response = executeCommand(extractData)
                                    if response then
                                        ws.send(textutils.serialiseJSON(response))
                                    end
                                else
                                    print("Failed to parse extracted content")
                                end
                            end
                        end
                    end
                end
            elseif event == "websocket_closed" then
                -- Connection closed by server
                print("Connection closed by server. Reconnecting...")
                ws = connectWebsocket()
            end
        end
    end, -- Heartbeat coroutine
    function()
        print("Starting heartbeat coroutine")
        local heartbeatAttempts = 0
        local lastSuccessfulHeartbeat = os.clock()

        while true do
            local currentTime = os.clock()
            if currentTime - lastHeartbeat >= env.HEARTBEAT_INTERVAL then
                print("Sending heartbeat #" .. heartbeatAttempts)
                local success, err = pcall(function()
                    ws.send(textutils.serialiseJSON({
                        type = "heartbeat",
                        turtle = env.TURTLE_NAME,
                        time = currentTime,
                        position = {
                            fuel = turtle.getFuelLevel()
                        }
                    }))
                end)

                heartbeatAttempts = heartbeatAttempts + 1

                if success then
                    -- print("Heartbeat sent successfully")
                    lastHeartbeat = currentTime
                    lastSuccessfulHeartbeat = currentTime
                    -- heartbeatAttempts = 0
                else
                    print("Failed to send heartbeat: " .. tostring(err))

                    -- If we haven't had a successful heartbeat in 5 seconds, reconnect
                    if currentTime - lastSuccessfulHeartbeat > 5 then
                        print("Connection appears to be lost. Forcing reconnect...")
                        error("Heartbeat failed, forcing reconnection")
                    end
                end
            end

            -- Set a timer and yield to allow other coroutines to run
            local timer = os.startTimer(1)
            os.pullEvent("timer")
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
