-- Main turtle application with improved WebSocket architecture
local env = require("env")
local WebSocketClient = require("lib.websocket")
local Commands = require("lib.commands")
local Position = require("lib.position")
local Fuel = require("lib.fuel")

-- Turtle Swarm Orchestration System

-- Main program
local function main()
    -- Initialize position tracking
    Position.loadPosition()
    
    -- Connect to WebSocket server
    if not WebSocketClient.initialize() then
        error("Failed to initialize WebSocket connection")
    end
    
    -- Run heartbeat and message handling in parallel
    parallel.waitForAll(
        -- Message handling coroutine
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
                    local pingSuccess = WebSocketClient.sendHeartbeat()
                    
                    if not pingSuccess then
                        print("Ping failed, connection lost. Reconnecting...")
                        while not WebSocketClient.reconnect() do
                            -- Keep trying to reconnect
                        end
                        WebSocketClient.register()
                    else
                        print("Ping successful, connection still active")
                    end
                elseif event == "websocket_message" then
                    -- We received a message
                    local message = param2
                    if message then
                        -- Try to parse as JSON
                        local success, data = pcall(textutils.unserialiseJSON, message)
                        if success and data then
                            print("Received command: " .. textutils.serialize(data))
                            local response = Commands.executeCommand(data)
                            if response then
                                WebSocketClient.sendResponse(response)
                            end
                        else
                            print("Failed to parse JSON: " .. tostring(message))
                            -- Try to extract any valid JSON content
                            local extracted = message:match("{.*}")
                            if extracted then
                                print("Attempting to parse extracted JSON: " .. extracted)
                                local extractSuccess, extractData = pcall(textutils.unserialiseJSON, extracted)
                                if extractSuccess and extractData then
                                    print("Successfully extracted command: " .. textutils.serialize(extractData))
                                    local response = Commands.executeCommand(extractData)
                                    if response then
                                        WebSocketClient.sendResponse(response)
                                    end
                                else
                                    print("Failed to parse extracted content")
                                end
                            end
                        end
                    end
                elseif event == "websocket_closed" then
                    -- Connection closed by server
                    print("Connection closed by server. Reconnecting...")
                    while not WebSocketClient.reconnect() do
                        -- Keep trying to reconnect
                    end
                    WebSocketClient.register()
                end
            end
        end,
        
        -- Heartbeat coroutine
        function()
            print("Starting heartbeat coroutine")
            local heartbeatAttempts = 0
            local lastSuccessfulHeartbeat = os.clock()
            
            while true do
                local currentTime = os.clock()
                if currentTime - WebSocketClient.lastHeartbeat >= env.HEARTBEAT_INTERVAL then
                    print("Sending heartbeat #" .. heartbeatAttempts)
                    local success = WebSocketClient.sendHeartbeat()
                    
                    heartbeatAttempts = heartbeatAttempts + 1
                    
                    if success then
                        lastSuccessfulHeartbeat = currentTime
                    else
                        print("Failed to send heartbeat")
                        
                        -- If we haven't had a successful heartbeat in 10 seconds, reconnect
                        if currentTime - lastSuccessfulHeartbeat > 10 then
                            print("Connection appears to be lost. Forcing reconnect...")
                            if not WebSocketClient.isReconnecting then
                                WebSocketClient.reconnect()
                            end
                        end
                    end
                end
                
                -- Try to process any queued messages that failed to send earlier
                if #WebSocketClient.messageQueue > 0 then
                    print("Processing " .. #WebSocketClient.messageQueue .. " queued messages")
                    WebSocketClient.processQueue()
                end
                
                -- Set a timer and yield to allow other coroutines to run
                local timer = os.startTimer(1)
                os.pullEvent("timer")
            end
        end,
        
        -- Fuel monitoring coroutine
        function()
            print("Starting fuel monitoring coroutine")
            while true do
                -- Check fuel level
                Fuel.checkFuel()
                
                -- Sleep for a while before checking again
                sleep(30)
            end
        end
    )
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