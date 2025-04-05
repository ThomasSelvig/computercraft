# ComputerCraft WebSocket Architecture Documentation

## Overview

This project implements a client-server architecture using WebSockets to control multiple ComputerCraft turtles from a central server. The architecture follows a master-slave pattern where the Node.js server acts as the command center (master) and ComputerCraft turtles act as worker nodes (slaves).

## System Components

### 1. Turtle Client (Lua)

The turtle client (`main.lua`) runs on ComputerCraft turtles and:
- Establishes and maintains a WebSocket connection to the central server
- Registers itself with a unique identifier (turtle name or computer ID)
- Processes and executes commands received from the server
- Sends command execution results back to the server
- Maintains a heartbeat to confirm connection status

### 2. WebSocket Server (Node.js)

The server (`server.js`) acts as the command center and:
- Provides a WebSocket endpoint for turtles to connect to
- Tracks all connected turtles and their status
- Routes commands to specific turtles or broadcasts to all turtles
- Queues commands for offline turtles
- Provides connection points for debug clients to monitor and control turtles
- Handles reconnection logic and connection state management

## Communication Protocol

All communication between server and turtles uses JSON-formatted messages:

### Message Types from Turtles to Server:

1. **Registration Message**
   ```json
   {
     "type": "register",
     "turtle": "TURTLE_NAME",
     "time": timestamp
   }
   ```

2. **Heartbeat Message**
   ```json
   {
     "type": "heartbeat",
     "turtle": "TURTLE_NAME",
     "time": timestamp,
     "position": {
       "fuel": fuelLevel
     }
   }
   ```

3. **Command Response**
   ```json
   {
     "success": true/false,
     "message": "Optional status message",
     "id": "COMMAND_ID",
     "turtle": "TURTLE_NAME",
     "additionalData": {}  // Command-specific data
   }
   ```

### Message Types from Server to Turtles:

1. **Command Message**
   ```json
   {
     "id": "COMMAND_ID",
     "target": "TURTLE_NAME or all",
     "action": "COMMAND_NAME",
     "params": {
       // Command-specific parameters
     }
   }
   ```

## Supported Commands

The turtle client supports the following commands:

1. **Move** - Moves the turtle in a specified direction
   - Parameters: `direction` (forward, back, up, down, turnLeft, turnRight)

2. **Dig** - Mines blocks
   - Parameters: `direction` (forward, up, down)

3. **Place** - Places blocks
   - Parameters: `direction` (forward, up, down), `slot` (optional)

4. **getInventory** - Retrieves the turtle's inventory
   - Returns: Array of item details for all slots

5. **getFuelLevel** - Checks the turtle's fuel level
   - Returns: Current fuel level

## Fault Tolerance Features

### Connection Management
- Automatic reconnection with retry logic
- Heartbeat mechanism to detect connection loss
- Connection timeout detection

### Error Handling
- All WebSocket communications wrapped in pcall() to prevent crashes
- Timeout mechanism for message handling
- Server-side command queuing for offline turtles

## Configuration

Configuration values are stored in `env.lua`:
- `WEBSOCKET_URL`: WebSocket server endpoint URL
- `TURTLE_NAME`: Unique identifier for the turtle
- `HEARTBEAT_INTERVAL`: Time between heartbeat messages (seconds)
- `CONNECTION_TIMEOUT`: Time before considering a connection lost (seconds)

## Architecture Diagram

```
┌─────────────────────┐                ┌────────────────────┐
│                     │                │                    │
│  Debug Clients      │                │  ComputerCraft     │
│  (Web Browser)      │<─────────────> │  Turtles           │
│                     │                │  (Lua Clients)     │
└─────────────────────┘                └────────────────────┘
           ▲                                     ▲
           │                                     │
           │                                     │
           │                                     │
           ▼                                     ▼
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    WebSocket Server                     │
│                                                         │
│  ┌─────────────────┐          ┌───────────────────┐    │
│  │                 │          │                   │    │
│  │  Turtle Registry│          │  Command Queue    │    │
│  │                 │          │                   │    │
│  └─────────────────┘          └───────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Extending the System

To add new commands:
1. Add a new handler function in the `handlers` table in `main.lua`
2. Implement the command logic in the handler function
3. Return a result object with at least a `success` field

The WebSocket architecture is designed to be extensible and can be enhanced with:
- Additional turtle capabilities
- More sophisticated command orchestration
- Turtle position tracking and pathfinding
- Task scheduling and prioritization