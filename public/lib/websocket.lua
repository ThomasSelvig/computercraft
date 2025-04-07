-- WebSocket client module for turtle communication
local env = require("env")
local Position = require("lib.position")
local Fuel = require("lib.fuel")

local WebSocketClient = {}

-- Connection state
WebSocketClient.connected = false
WebSocketClient.connection = nil
WebSocketClient.lastHeartbeat = 0
WebSocketClient.reconnectAttempts = 0
WebSocketClient.isReconnecting = false
WebSocketClient.messageQueue = {}
WebSocketClient.maxQueueSize = 10

-- Error counts for rate limiting reconnection attempts
WebSocketClient.errorCount = 0
WebSocketClient.lastErrorTime = 0
WebSocketClient.errorThreshold = 5
WebSocketClient.errorTimeWindow = 30 -- seconds

-- Maximum reconnect attempts before exponential backoff
WebSocketClient.MAX_RECONNECT_ATTEMPTS = 5

-- Reset error counts
function WebSocketClient.resetErrorCount()
    WebSocketClient.errorCount = 0
    WebSocketClient.lastErrorTime = 0
end

-- Check if we should trigger a reconnection based on error frequency
function WebSocketClient.shouldReconnect()
    local currentTime = os.clock()
    
    -- Reset error count if outside time window
    if currentTime - WebSocketClient.lastErrorTime > WebSocketClient.errorTimeWindow then
        WebSocketClient.resetErrorCount()
    end
    
    WebSocketClient.errorCount = WebSocketClient.errorCount + 1
    WebSocketClient.lastErrorTime = currentTime
    
    return WebSocketClient.errorCount >= WebSocketClient.errorThreshold
end

-- Connect to the WebSocket server
function WebSocketClient.connect()
    print("Connecting to WebSocket server at " .. env.WEBSOCKET_URL)
    WebSocketClient.isReconnecting = true
    
    local ws, err = http.websocket(env.WEBSOCKET_URL)
    
    if ws then
        print("Connected to WebSocket server")
        WebSocketClient.connected = true
        WebSocketClient.connection = ws
        WebSocketClient.reconnectAttempts = 0
        WebSocketClient.resetErrorCount()
        WebSocketClient.isReconnecting = false
        
        -- Process any queued messages
        WebSocketClient.processQueue()
        return true
    else
        print("Connection failed: " .. (err or "unknown error"))
        WebSocketClient.connected = false
        WebSocketClient.connection = nil
        WebSocketClient.reconnectAttempts = WebSocketClient.reconnectAttempts + 1
        WebSocketClient.isReconnecting = false
        return false
    end
end

-- Add a message to the queue
function WebSocketClient.queueMessage(msgType, message)
    if #WebSocketClient.messageQueue >= WebSocketClient.maxQueueSize then
        -- Remove oldest message if queue is full
        table.remove(WebSocketClient.messageQueue, 1)
    end
    
    table.insert(WebSocketClient.messageQueue, {
        type = msgType,
        message = message,
        time = os.clock()
    })
end

-- Process the message queue
function WebSocketClient.processQueue()
    if not WebSocketClient.connected or WebSocketClient.isReconnecting then
        return false
    end
    
    local processedCount = 0
    local currentTime = os.clock()
    
    -- Copy queue to avoid modifying while iterating
    local queueCopy = {}
    for i, item in ipairs(WebSocketClient.messageQueue) do
        queueCopy[i] = item
    end
    
    -- Clear the original queue
    WebSocketClient.messageQueue = {}
    
    for _, item in ipairs(queueCopy) do
        -- Only process messages that are less than 60 seconds old
        if currentTime - item.time < 60 then
            local success = false
            
            if item.type == "register" then
                success = WebSocketClient.register()
            elseif item.type == "heartbeat" then
                success = WebSocketClient.sendHeartbeat()
            elseif item.type == "response" then
                success = WebSocketClient.sendResponse(item.message)
            end
            
            if success then
                processedCount = processedCount + 1
            else
                -- If sending failed, re-queue the message
                table.insert(WebSocketClient.messageQueue, item)
            end
        end
    end
    
    return processedCount > 0
end

-- Register the turtle with the server
function WebSocketClient.register()
    if not WebSocketClient.connected or not WebSocketClient.connection then
        WebSocketClient.queueMessage("register", nil)
        return false, "Not connected"
    end
    
    local success, err = pcall(function()
        WebSocketClient.connection.send(textutils.serialiseJSON({
            type = "register",
            turtle = env.TURTLE_NAME,
            time = os.clock(),
            capabilities = WebSocketClient.getCapabilities()
        }))
    end)
    
    if success then
        print("Registration message sent successfully")
        WebSocketClient.resetErrorCount()
        return true
    else
        print("Failed to send registration: " .. tostring(err))
        
        -- Add to error count but don't immediately disconnect
        if WebSocketClient.shouldReconnect() then
            WebSocketClient.connected = false
            WebSocketClient.queueMessage("register", nil)
        end
        
        return false, err
    end
end

-- Send a heartbeat to the server
function WebSocketClient.sendHeartbeat()
    if not WebSocketClient.connected or not WebSocketClient.connection then
        return false, "Not connected"
    end
    
    local heartbeatData = {
        type = "heartbeat",
        turtle = env.TURTLE_NAME,
        time = os.clock(),
        position = Position.getCurrentPosition()
    }
    
    local success, err = pcall(function()
        WebSocketClient.connection.send(textutils.serialiseJSON(heartbeatData))
    end)
    
    if success then
        WebSocketClient.lastHeartbeat = os.clock()
        WebSocketClient.resetErrorCount()
        return true
    else
        print("Failed to send heartbeat: " .. tostring(err))
        
        -- Queue the heartbeat for retry
        WebSocketClient.queueMessage("heartbeat", nil)
        
        -- Check if we should trigger a reconnect based on error frequency
        if WebSocketClient.shouldReconnect() then
            WebSocketClient.connected = false
        end
        
        return false, err
    end
end

-- Send a response to the server
function WebSocketClient.sendResponse(response)
    if not WebSocketClient.connected or not WebSocketClient.connection then
        WebSocketClient.queueMessage("response", response)
        return false, "Not connected"
    end
    
    local success, err = pcall(function()
        WebSocketClient.connection.send(textutils.serialiseJSON(response))
    end)
    
    if success then
        WebSocketClient.resetErrorCount()
        return true
    else
        print("Failed to send response: " .. tostring(err))
        
        -- Queue the response for retry
        WebSocketClient.queueMessage("response", response)
        
        -- Check if we should trigger a reconnect based on error frequency
        if WebSocketClient.shouldReconnect() then
            WebSocketClient.connected = false
        end
        
        return false, err
    end
end

-- Receive a message with timeout
function WebSocketClient.receiveMessage(timeout)
    if not WebSocketClient.connected or not WebSocketClient.connection then
        return nil, "Not connected"
    end
    
    -- Set up a timer
    local timer = nil
    if timeout then
        timer = os.startTimer(timeout)
    end
    
    while true do
        local event, p1, p2 = os.pullEvent()
        
        if event == "websocket_message" then
            -- Parse the message
            local success, data = pcall(textutils.unserialiseJSON, p2)
            if success and data then
                WebSocketClient.resetErrorCount()
                return data
            else
                print("Failed to parse JSON: " .. tostring(p2))
                
                -- Try to extract valid JSON from possibly corrupted message
                local extractedJson = p2:match("{.-}")
                if extractedJson then
                    local extractSuccess, extractData = pcall(textutils.unserialiseJSON, extractedJson)
                    if extractSuccess and extractData then
                        print("Successfully extracted JSON from message")
                        WebSocketClient.resetErrorCount()
                        return extractData
                    end
                end
            end
        elseif event == "websocket_closed" then
            WebSocketClient.connected = false
            return nil, "Connection closed"
        elseif event == "timer" and p1 == timer then
            return nil, "Timeout"
        end
    end
end

-- Reconnect to the server with exponential backoff
function WebSocketClient.reconnect()
    if WebSocketClient.isReconnecting then
        print("Already attempting to reconnect...")
        return false
    end
    
    if WebSocketClient.reconnectAttempts > WebSocketClient.MAX_RECONNECT_ATTEMPTS then
        local delay = math.min(2 ^ (WebSocketClient.reconnectAttempts - WebSocketClient.MAX_RECONNECT_ATTEMPTS), 60)
        print("Reconnecting in " .. delay .. " seconds...")
        sleep(delay)
    else
        print("Reconnecting in 5 seconds...")
        sleep(5)
    end
    
    -- Close existing connection if it exists
    if WebSocketClient.connection then
        pcall(function() WebSocketClient.connection.close() end)
        WebSocketClient.connection = nil
    end
    
    WebSocketClient.connected = false
    
    return WebSocketClient.connect()
end

-- Get the turtle's capabilities
function WebSocketClient.getCapabilities()
    -- This can be expanded as needed
    return {
        "move",
        "dig",
        "place",
        "getInventory",
        "getFuelLevel"
    }
end

-- Initialize the connection
function WebSocketClient.initialize()
    while not WebSocketClient.connect() do
        WebSocketClient.reconnect()
    end
    
    return WebSocketClient.register()
end

return WebSocketClient