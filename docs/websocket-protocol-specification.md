# ComputerCraft Dashboard WebSocket Protocol Specification

## Overview

This document defines the WebSocket communication protocol between the ComputerCraft turtle dashboard and the turtles in the game. The protocol is designed to enable real-time control, monitoring, and orchestration of multiple turtles through a central web interface.

## Protocol Design Principles

1. **JSON-based messaging**: All messages are formatted as JSON objects for compatibility and readability.
2. **Type-driven routing**: Messages include a type field that determines how they are processed.
3. **Stateful connections**: The server maintains connection state for each turtle.
4. **Idempotent operations**: Commands can be safely retried without side effects.
5. **Asynchronous communication**: Commands and status updates flow independently.
6. **Heartbeat mechanism**: Regular heartbeats ensure connection health.

## Connection Lifecycle

### Establishing Connection

1. **Turtle Initialization**:
   ```lua
   local ws, err = http.websocket("ws://dashboard-server:1337")
   if not ws then
     print("Connection failed: " .. err)
     return
   end
   ```

2. **Registration**:
   ```lua
   ws.send(textutils.serialiseJSON({
     type = "register",
     id = os.getComputerID(),
     label = os.getComputerLabel() or "Turtle " .. os.getComputerID(),
     capabilities = {
       -- List of special capabilities this turtle has
     }
   }))
   ```

3. **Server Acknowledgment**:
   ```json
   {
     "type": "registerAck",
     "success": true,
     "serverId": "dashboard-server-123",
     "serverTime": 1623456789
   }
   ```

### Connection Maintenance

1. **Heartbeat Mechanism**:
   - Turtles send periodic heartbeats (every 10-30 seconds)
   - Server responds to confirm connection active
   - Missing heartbeats trigger reconnection attempts

2. **Heartbeat Message**:
   ```json
   {
     "type": "heartbeat",
     "timestamp": 1623456789,
     "id": "turtle-123"
   }
   ```

3. **Heartbeat Response**:
   ```json
   {
     "type": "heartbeatAck",
     "timestamp": 1623456790,
     "serverLoad": 0.25
   }
   ```

### Terminating Connection

1. **Graceful Closure**:
   ```json
   {
     "type": "disconnect",
     "reason": "shutdown",
     "id": "turtle-123"
   }
   ```

2. **Unexpected Disconnection Handling**:
   - Server marks turtle as offline after heartbeat timeout
   - Turtle attempts reconnection with exponential backoff
   - Upon reconnection, turtle resumes last known state

## Message Types

### Core Message Structure

All messages follow this basic structure:

```json
{
  "type": "[message-type]",
  "timestamp": 1623456789,
  "id": "[origin-id]",
  ... type-specific fields ...
}
```

### Turtle → Server Messages

#### Status Update

```json
{
  "type": "status",
  "id": "turtle-123",
  "timestamp": 1623456789,
  "position": {
    "x": 100,
    "y": 64,
    "z": -200,
    "heading": "north"
  },
  "fuel": {
    "level": 1500,
    "max": 20000
  },
  "inventory": [
    {
      "slot": 1,
      "name": "minecraft:coal",
      "count": 64
    },
    {
      "slot": 2,
      "name": "minecraft:stone",
      "count": 32
    }
  ],
  "status": "idle",
  "error": null
}
```

#### Command Response

```json
{
  "type": "commandResponse",
  "id": "turtle-123",
  "timestamp": 1623456790,
  "commandId": "cmd-456",
  "success": true,
  "result": {
    "moved": true,
    "newPosition": {
      "x": 101,
      "y": 64,
      "z": -200
    }
  },
  "error": null
}
```

#### Error Report

```json
{
  "type": "error",
  "id": "turtle-123",
  "timestamp": 1623456791,
  "severity": "warning",
  "code": "MOVE_BLOCKED",
  "message": "Movement blocked by unbreakable block",
  "context": {
    "command": "forward",
    "position": {
      "x": 100,
      "y": 64,
      "z": -200
    }
  }
}
```

#### Event Notification

```json
{
  "type": "event",
  "id": "turtle-123",
  "timestamp": 1623456792,
  "eventType": "inventoryChange",
  "data": {
    "slot": 3,
    "previous": {
      "name": "minecraft:dirt",
      "count": 10
    },
    "current": {
      "name": "minecraft:dirt",
      "count": 9
    }
  }
}
```

#### Task Progress

```json
{
  "type": "taskProgress",
  "id": "turtle-123",
  "timestamp": 1623456793,
  "taskId": "task-789",
  "progress": 0.45,
  "currentStep": 9,
  "totalSteps": 20,
  "estimatedCompletion": 1623456900
}
```

### Server → Turtle Messages

#### Command

```json
{
  "type": "command",
  "timestamp": 1623456800,
  "commandId": "cmd-457",
  "action": "move",
  "parameters": {
    "direction": "forward",
    "distance": 1,
    "digIfBlocked": true
  },
  "priority": 1,
  "timeout": 5000
}
```

#### Task Assignment

```json
{
  "type": "taskAssign",
  "timestamp": 1623456810,
  "taskId": "task-790",
  "name": "Mine Ore Vein",
  "priority": 2,
  "steps": [
    {
      "action": "scan",
      "parameters": {
        "range": 2,
        "targetBlocks": ["minecraft:iron_ore", "minecraft:gold_ore"]
      }
    },
    {
      "action": "moveToNearest",
      "parameters": {
        "target": "minecraft:iron_ore"
      }
    },
    {
      "action": "mineVein",
      "parameters": {
        "maxBlocks": 32
      }
    }
  ],
  "abortCondition": {
    "fuelBelow": 100,
    "inventoryFull": true
  }
}
```

#### Task Control

```json
{
  "type": "taskControl",
  "timestamp": 1623456820,
  "taskId": "task-790",
  "action": "pause",
  "reason": "user-initiated"
}
```

#### Status Request

```json
{
  "type": "statusRequest",
  "timestamp": 1623456830,
  "requestId": "req-123",
  "fields": ["position", "fuel", "inventory"]
}
```

#### Configuration Update

```json
{
  "type": "configUpdate",
  "timestamp": 1623456840,
  "configs": {
    "reportingInterval": 5000,
    "defaultDigBehavior": "smeltable",
    "lowFuelThreshold": 500
  }
}
```

#### Program Deployment

```json
{
  "type": "programDeploy",
  "timestamp": 1623456850,
  "programId": "prog-123",
  "name": "MiningRoutine",
  "version": "1.2.0",
  "code": "-- Base64 encoded Lua code...",
  "encoding": "base64",
  "autoStart": true,
  "parameters": {
    "miningDepth": 50,
    "pattern": "grid"
  }
}
```

### Orchestration Messages

#### Coordination Assignment

```json
{
  "type": "coordinationAssign",
  "timestamp": 1623456860,
  "coordinationId": "coord-123",
  "role": "miner",
  "groupId": "mining-team-alpha",
  "peers": ["turtle-124", "turtle-125"],
  "leaderTurtle": "turtle-123",
  "communicationChannel": "rednet-55"
}
```

#### Resource Sharing

```json
{
  "type": "resourceShare",
  "timestamp": 1623456870,
  "offeredResources": [
    {
      "name": "minecraft:coal",
      "count": 32,
      "slot": 5
    }
  ],
  "requestingTurtle": "turtle-124",
  "meetLocation": {
    "x": 105,
    "y": 64,
    "z": -200
  }
}
```

#### Path Coordination

```json
{
  "type": "pathCoordination",
  "timestamp": 1623456880,
  "paths": [
    {
      "turtleId": "turtle-123",
      "waypoints": [
        {"x": 100, "y": 64, "z": -200},
        {"x": 105, "y": 64, "z": -200},
        {"x": 105, "y": 64, "z": -205}
      ],
      "priority": 1,
      "timeframe": {
        "start": 1623456900,
        "end": 1623457000
      }
    },
    {
      "turtleId": "turtle-124",
      "waypoints": [
        {"x": 110, "y": 64, "z": -210},
        {"x": 105, "y": 64, "z": -205}
      ],
      "priority": 2,
      "timeframe": {
        "start": 1623456950,
        "end": 1623457050
      }
    }
  ]
}
```

## Error Handling

### Error Categories

1. **Connection Errors**:
   - Connection refused
   - Timeout
   - Protocol violation

2. **Command Errors**:
   - Invalid command
   - Execution failure
   - Timeout

3. **State Errors**:
   - Low fuel
   - Inventory full/empty
   - Position lost

### Error Response Format

```json
{
  "type": "error",
  "timestamp": 1623456890,
  "errorType": "commandFailure",
  "code": "MOVE_FAILED",
  "message": "Cannot move forward: blocked by unbreakable block",
  "commandId": "cmd-458",
  "recoveryOptions": [
    "retry",
    "alternatePath",
    "abort"
  ]
}
```

### Recovery Strategies

1. **Automatic Retry**:
   - Commands with transient failures are automatically retried
   - Exponential backoff with configurable limits

2. **Alternate Path**:
   - Movement failures trigger pathfinding for alternatives
   - Server can suggest alternate paths for turtles

3. **Degraded Operation Mode**:
   - Turtles with low fuel enter energy-saving mode
   - Limited operations prioritized until refueling

4. **Human Intervention Request**:
   - Critical errors generate alerts on dashboard
   - Recovery options presented to users

## Advanced Features

### Batch Commands

```json
{
  "type": "batchCommand",
  "timestamp": 1623456900,
  "batchId": "batch-123",
  "commands": [
    {
      "action": "dig",
      "parameters": {}
    },
    {
      "action": "move",
      "parameters": {
        "direction": "forward"
      }
    },
    {
      "action": "dig",
      "parameters": {}
    }
  ],
  "abortOnFailure": true
}
```

### Turtle Groups

```json
{
  "type": "groupCommand",
  "timestamp": 1623456910,
  "groupId": "mining-team-alpha",
  "command": {
    "action": "returnToBase",
    "parameters": {
      "formationPattern": "line",
      "spacing": 2
    }
  }
}
```

### Event Subscriptions

```json
{
  "type": "eventSubscribe",
  "timestamp": 1623456920,
  "events": [
    "blockBreak",
    "inventoryChange",
    "entityDetected"
  ],
  "filters": {
    "blockTypes": ["minecraft:diamond_ore", "minecraft:emerald_ore"],
    "inventoryThreshold": 0.9
  }
}
```

### Conditional Execution

```json
{
  "type": "conditionalCommand",
  "timestamp": 1623456930,
  "condition": {
    "type": "blockMatch",
    "parameters": {
      "direction": "forward",
      "blockName": "minecraft:diamond_ore"
    }
  },
  "ifTrue": {
    "action": "dig",
    "parameters": {}
  },
  "ifFalse": {
    "action": "move",
    "parameters": {
      "direction": "forward"
    }
  }
}
```

## Implementation Guidelines

### Turtle-Side Implementation

```lua
-- WebSocket connection handler
local function connectToServer()
  local ws, err = http.websocket("ws://dashboard-server:1337")
  if not ws then
    print("Connection failed: " .. (err or "unknown error"))
    return nil
  end
  return ws
end

-- Message handler
local function handleMessages(ws)
  while true do
    local message = ws.receive()
    if not message then
      print("Connection closed")
      break
    end
    
    local success, data = pcall(textutils.unserialiseJSON, message)
    if not success then
      print("Invalid message received")
    else
      processMessage(data)
    end
  end
end

-- Main loop with reconnection logic
local function main()
  while true do
    local ws = connectToServer()
    if ws then
      -- Register with server
      ws.send(textutils.serialiseJSON({
        type = "register",
        id = os.getComputerID(),
        label = os.getComputerLabel() or "Turtle " .. os.getComputerID()
      }))
      
      -- Handle messages until disconnect
      handleMessages(ws)
      
      -- Close connection if still open
      pcall(function() ws.close() end)
    end
    
    -- Wait before reconnection attempt
    print("Reconnecting in 5 seconds...")
    sleep(5)
  end
end
```

### Server-Side Implementation (Node.js)

```javascript
const WebSocket = require('ws');
const server = new WebSocket.Server({ port: 1337 });

// Store connected turtles
const turtles = new Map();

server.on('connection', (ws) => {
  let turtleId = null;
  
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      
      // Handle registration
      if (data.type === 'register') {
        turtleId = data.id;
        turtles.set(turtleId, {
          ws,
          lastSeen: Date.now(),
          status: 'idle',
          position: null,
          fuel: null,
          inventory: []
        });
        
        // Send acknowledgment
        ws.send(JSON.stringify({
          type: 'registerAck',
          success: true,
          serverId: 'dashboard-server-123',
          serverTime: Date.now()
        }));
        
        // Broadcast updated turtle list to dashboard clients
        broadcastTurtleList();
      }
      // Handle status updates
      else if (data.type === 'status') {
        if (turtles.has(data.id)) {
          const turtle = turtles.get(data.id);
          turtle.lastSeen = Date.now();
          turtle.status = data.status;
          turtle.position = data.position;
          turtle.fuel = data.fuel;
          turtle.inventory = data.inventory;
          
          // Broadcast updated status to dashboard clients
          broadcastTurtleStatus(data.id);
        }
      }
      // Handle heartbeats
      else if (data.type === 'heartbeat') {
        if (turtles.has(data.id)) {
          turtles.get(data.id).lastSeen = Date.now();
          
          // Send heartbeat acknowledgment
          ws.send(JSON.stringify({
            type: 'heartbeatAck',
            timestamp: Date.now(),
            serverLoad: getServerLoad()
          }));
        }
      }
      // Handle other message types...
    } catch (err) {
      console.error('Error processing message:', err);
    }
  });
  
  ws.on('close', () => {
    if (turtleId && turtles.has(turtleId)) {
      const turtle = turtles.get(turtleId);
      turtle.status = 'offline';
      turtle.ws = null;
      
      // Keep turtle in map for reconnection
      setTimeout(() => {
        // Remove turtle if not reconnected after timeout
        if (turtles.has(turtleId) && turtles.get(turtleId).ws === null) {
          turtles.delete(turtleId);
          broadcastTurtleList();
        }
      }, 60000); // 1 minute timeout
      
      broadcastTurtleStatus(turtleId);
    }
  });
});

// Helper functions
function broadcastTurtleList() {
  // Implementation to broadcast updated turtle list to dashboard clients
}

function broadcastTurtleStatus(turtleId) {
  // Implementation to broadcast updated turtle status to dashboard clients
}

function getServerLoad() {
  // Implementation to calculate server load
  return 0.25; // Example value
}

// Start heartbeat checking
setInterval(() => {
  const now = Date.now();
  turtles.forEach((turtle, id) => {
    if (turtle.ws && now - turtle.lastSeen > 45000) { // 45 second timeout
      console.log(`Turtle ${id} timed out`);
      turtle.status = 'offline';
      turtle.ws = null;
      broadcastTurtleStatus(id);
    }
  });
}, 15000); // Check every 15 seconds
```

## Security Considerations

1. **Authentication**:
   - Implement token-based authentication for turtles
   - Validate turtle IDs against known registry
   - Consider server API key for dashboard clients

2. **Input Validation**:
   - Validate all incoming messages against schema
   - Sanitize command parameters
   - Implement rate limiting for commands

3. **Transport Security**:
   - Use WSS (WebSocket Secure) in production
   - Implement TLS for all connections
   - Consider VPN for remote connections

4. **Authorization**:
   - Define permission levels for turtle control
   - Implement role-based access for dashboard users
   - Log all critical commands for audit

## Performance Optimization

1. **Message Batching**:
   - Group status updates from multiple turtles
   - Batch commands when possible
   - Implement priority queue for messages

2. **Throttling**:
   - Adjust status reporting frequency based on activity
   - Implement exponential backoff for reconnections
   - Limit event frequency during high load

3. **Payload Optimization**:
   - Use partial updates for status changes
   - Compress large payloads
   - Implement binary protocol for constrained environments

## Versioning and Compatibility

1. **Protocol Versioning**:
   - Include protocol version in registration
   - Negotiate capabilities during connection
   - Support graceful degradation for older clients

2. **Feature Detection**:
   - Turtles report capabilities during registration
   - Dashboard adapts UI based on available features
   - Provide fallbacks for unsupported operations

3. **Migration Path**:
   - Document breaking changes between versions
   - Provide upgrade scripts for turtle programs
   - Support multiple protocol versions during transition periods

## API Stability and Evolution

As the WebSocket protocol evolves, the following principles should be followed:

1. **Additive Changes**:
   - New message types can be added
   - Existing messages can gain optional fields
   - New capabilities can be added to capability negotiation

2. **Breaking Changes**:
   - Must be clearly documented
   - Should be accompanied by version increment
   - Should provide a migration period where both old and new are supported

3. **Deprecation Process**:
   - Features to be removed should be marked as deprecated
   - Deprecation warnings should be logged
   - Sufficient notice should be given before removal