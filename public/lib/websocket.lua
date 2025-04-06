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

-- Maximum reconnect attempts before exponential backoff
WebSocketClient.MAX_RECONNECT_ATTEMPTS = 5

-- Connect to the WebSocket server
function WebSocketClient.connect()
    print("Connecting to WebSocket server at " .. env.WEBSOCKET_URL)
    
    local ws, err = http.websocket(env.WEBSOCKET_URL)
    
    if ws then
        print("Connected to WebSocket server")
        WebSocketClient.connected = true
        WebSocketClient.connection = ws
        WebSocketClient.reconnectAttempts = 0
        return true
    else
        print("Connection failed: " .. (err or "unknown error"))
        WebSocketClient.connected = false
        WebSocketClient.connection = nil
        WebSocketClient.reconnectAttempts = WebSocketClient.reconnectAttempts + 1
        return false
    end
end

-- Register the turtle with the server
function WebSocketClient.register()
    if not WebSocketClient.connected or not WebSocketClient.connection then
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
        return true
    else
        print("Failed to send registration: " .. tostring(err))
        WebSocketClient.connected = false
        return false, err
    end
end

-- Send a heartbeat to the server
function WebSocketClient.sendHeartbeat()
    if not WebSocketClient.connected or not WebSocketClient.connection then
        return false, "Not connected"
    end
    
    local success, err = pcall(function()
        WebSocketClient.connection.send(textutils.serialiseJSON({
            type = "heartbeat",
            turtle = env.TURTLE_NAME,
            time = os.clock(),
            position = Position.getCurrentPosition()
        }))
    end)
    
    if success then
        WebSocketClient.lastHeartbeat = os.clock()
        return true
    else
        print("Failed to send heartbeat: " .. tostring(err))
        WebSocketClient.connected = false
        return false, err
    end
end

-- Send a response to the server
function WebSocketClient.sendResponse(response)
    if not WebSocketClient.connected or not WebSocketClient.connection then
        return false, "Not connected"
    end
    
    local success, err = pcall(function()
        WebSocketClient.connection.send(textutils.serialiseJSON(response))
    end)
    
    if success then
        return true
    else
        print("Failed to send response: " .. tostring(err))
        WebSocketClient.connected = false
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
                return data
            else
                print("Failed to parse JSON: " .. tostring(p2))
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