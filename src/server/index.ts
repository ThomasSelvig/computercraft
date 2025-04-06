// ComputerCraft Turtle Orchestration WebSocket Server

import WebSocket from "ws";
import express from "express";
import path from "path";
import http from "http";
import fs from "fs";
import {
  TurtleInfo,
  CommandMessage,
  RegisterMessage,
  HeartbeatMessage,
  CommandResponse,
  WebSocketMessage,
} from "./types";

// Server Configuration
const PORT = process.env.PORT || 1337;
const HEARTBEAT_TIMEOUT = 10000; // 10 seconds
const OFFLINE_CHECK_INTERVAL = 5000; // 5 seconds

// Initialize Express App and HTTP server
const app = express();

// Serve static files - this will allow turtles to download latest code
app.use(express.static("public"));

// Also serve web dashboard from the web/dist directory if it exists
try {
  if (fs.existsSync(path.join(__dirname, '../../web/dist'))) {
    app.use(express.static(path.join(__dirname, '../../web/dist')));
    
    // Serve the index.html for any routes not explicitly handled
    app.get('*', (req, res) => {
      res.sendFile(path.join(__dirname, '../../web/dist/index.html'));
    });
  }
} catch (error) {
  console.warn('Web dashboard not found, skipping static file setup for web UI');
}

const server = http.createServer(app);

// Create WebSocket server
const wss = new WebSocket.Server({ server });

// Store connected turtles
const turtles = new Map<string, TurtleInfo>();

// Command queue for turtles
const commandQueue = new Map<string, CommandMessage[]>();

// Generate a unique command ID
let commandIdCounter = 0;
function generateCommandId(): string {
  return `cmd-${Date.now()}-${commandIdCounter++}`;
}

// Broadcast to all connected debug clients
function broadcastToDebugClients(message: any): void {
  wss.clients.forEach((client) => {
    if ((client as any).isDebugClient && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(message));
    }
  });
}

// Update all debug clients with current turtle status
function updateDebugClients(): void {
  const turtleStatus = Array.from(turtles.entries()).map(([id, data]) => ({
    id: id,
    lastHeartbeat: data.lastHeartbeat,
    status: data.status,
    position: data.position,
    lastCommand: data.lastCommand,
  }));

  broadcastToDebugClients({
    type: "turtleUpdate",
    turtles: turtleStatus,
  });
}

// Send command to a turtle
function sendCommandToTurtle(
  turtleId: string,
  command: CommandMessage
): boolean {
  if (!turtles.has(turtleId)) return false;

  const turtle = turtles.get(turtleId)!;

  if (turtle.connection && turtle.connection.readyState === WebSocket.OPEN) {
    try {
      console.log(
        `Sending command to turtle ${turtleId}:`,
        JSON.stringify(command)
      );
      turtle.connection.send(JSON.stringify(command));
      console.log(`Command sent successfully to turtle ${turtleId}`);
      turtle.lastCommand = command;
      turtle.status = "executing";
      return true;
    } catch (err) {
      console.error(`Error sending command to turtle ${turtleId}:`, err);
      return false;
    }
  } else {
    // Queue command for offline turtle
    if (!commandQueue.has(turtleId)) {
      commandQueue.set(turtleId, []);
    }
    commandQueue.get(turtleId)!.push(command);
    return false;
  }
}

// Handle new WebSocket connections
wss.on("connection", (ws, req) => {
  console.log("New connection established");

  // Extended WebSocket with extra properties
  const extendedWs = ws as WebSocket & {
    isTurtle: boolean;
    isDebugClient: boolean;
    turtleId: string | null;
  };

  // Initialize connection properties
  extendedWs.isTurtle = false;
  extendedWs.isDebugClient = false;
  extendedWs.turtleId = null;

  // Handle incoming messages
  extendedWs.on("message", (messageData) => {
    try {
      const message = JSON.parse(messageData.toString()) as WebSocketMessage;

      // Handle client type identification
      if (message.type === "register") {
        if (message.debugClient) {
          // Handle debug client registration
          console.log("Debug client connected");
          extendedWs.isDebugClient = true;
          // Send acknowledgment
          extendedWs.send(
            JSON.stringify({
              type: "registerAck",
              success: true,
              serverId: "orchestration-server",
              serverTime: Date.now(),
            })
          );
          // Send initial turtle status
          updateDebugClients();
        } else if (message.turtle) {
          // Handle turtle registration
          handleRegistration(extendedWs, message as RegisterMessage);
        }
      } else if (message.type === "heartbeat" && extendedWs.isTurtle) {
        handleHeartbeat(extendedWs, message as HeartbeatMessage);
      } else if (message.type === "command" && extendedWs.isDebugClient) {
        handleCommand(extendedWs, message);
      } else if (extendedWs.isTurtle && 'id' in message) {
        handleCommandResponse(extendedWs, message as unknown as CommandResponse);
      }
    } catch (error) {
      console.error("Error processing message:", error);
    }
  });

  // Handle disconnections
  extendedWs.on("close", () => {
    if (extendedWs.isTurtle && extendedWs.turtleId) {
      console.log(`Turtle ${extendedWs.turtleId} disconnected`);

      // Don't remove the turtle from the map, just mark it as offline
      if (turtles.has(extendedWs.turtleId)) {
        const turtle = turtles.get(extendedWs.turtleId)!;
        turtle.status = "offline";
        turtle.connection = null;
        updateDebugClients();
      }
    } else if (extendedWs.isDebugClient) {
      console.log("Debug client disconnected");
    }
  });
});

// Handle turtle registration
function handleRegistration(
  ws: WebSocket & { isTurtle: boolean; turtleId: string | null },
  message: RegisterMessage
): void {
  // Ensure turtle ID exists
  if (!message.turtle) {
    console.error("Attempted to register a turtle without an ID");
    return;
  }
  
  const turtleId = message.turtle;
  console.log(`Turtle ${turtleId} registered`);
  ws.isTurtle = true;
  ws.turtleId = turtleId;

  turtles.set(turtleId, {
    connection: ws,
    lastHeartbeat: Date.now(),
    status: "idle",
    position: {},
    lastCommand: null,
  });

  // Send acknowledgment
  ws.send(
    JSON.stringify({
      type: "registerAck",
      success: true,
      serverId: "orchestration-server",
      serverTime: Date.now(),
    })
  );

  // Check if there are any pending commands for this turtle
  if (commandQueue.has(turtleId)) {
    const commands = commandQueue.get(turtleId)!;
    commands.forEach((cmd) => {
      sendCommandToTurtle(turtleId, cmd);
    });
    commandQueue.delete(turtleId);
  }

  updateDebugClients();
}

// Handle heartbeat messages
function handleHeartbeat(
  ws: WebSocket & { turtleId: string | null },
  message: HeartbeatMessage
): void {
  // Verify the turtle ID is valid
  if (!ws.turtleId || !message.turtle || !turtles.has(message.turtle)) {
    console.warn(`Invalid heartbeat received: ${JSON.stringify(message)}`);
    return;
  }

  const turtle = turtles.get(message.turtle)!;
  turtle.lastHeartbeat = Date.now();

  // If turtle was offline, mark it as active again
  if (turtle.status === "offline") {
    turtle.status = "idle";
  }

  // Update position information
  turtle.position = message.position || turtle.position;

  // Send heartbeat acknowledgment
  ws.send(
    JSON.stringify({
      type: "heartbeatAck",
      timestamp: Date.now(),
      serverLoad: 0.25, // This could be calculated based on server metrics
    })
  );

  updateDebugClients();
}

// Handle command from debug client
function handleCommand(
  ws: WebSocket & { isDebugClient: boolean },
  message: any
): void {
  const { target, action, params } = message;

  const commandId = generateCommandId();
  const command: CommandMessage = {
    id: commandId,
    target: target,
    action: action,
    params: params || {},
  };

  // Send to specific turtle or all turtles
  if (target === "all") {
    let commandSent = false;
    turtles.forEach((turtle, id) => {
      const success = sendCommandToTurtle(id, command);
      commandSent = commandSent || success;
    });

    if (commandSent) {
      updateDebugClients();
    }

    // Confirm to debug client
    ws.send(
      JSON.stringify({
        type: "commandConfirmation",
        id: commandId,
        target: target,
        action: action,
      })
    );
  } else if (turtles.has(target)) {
    const success = sendCommandToTurtle(target, command);

    if (success) {
      updateDebugClients();
    }

    // Confirm to debug client
    ws.send(
      JSON.stringify({
        type: "commandConfirmation",
        id: commandId,
        target: target,
        action: action,
      })
    );
  } else {
    // Turtle not found
    ws.send(
      JSON.stringify({
        type: "error",
        message: `Turtle ${target} not found`,
      })
    );
  }
}

// Handle command response from turtle
function handleCommandResponse(
  ws: WebSocket & { turtleId: string | null },
  response: CommandResponse
): void {
  if (!ws.turtleId || !turtles.has(ws.turtleId)) return;

  console.log(`Received response from turtle ${ws.turtleId}: `, response);

  const turtle = turtles.get(ws.turtleId)!;
  turtle.status = "idle";

  // Update the last command with the result
  if (turtle.lastCommand && turtle.lastCommand.id === response.id) {
    turtle.lastCommand = {
      ...turtle.lastCommand,
      result: response.success ? "success" : "failed",
      message: response.message,
      time: Date.now(),
    };
  }

  // Broadcast the response to debug clients
  broadcastToDebugClients({
    type: "commandResponse",
    turtleId: ws.turtleId,
    response: response,
  });

  updateDebugClients();
}

// Periodically check for stale turtles
setInterval(() => {
  const now = Date.now();
  turtles.forEach((turtle, id) => {
    // If no heartbeat for 10 seconds and not already marked offline
    if (
      now - turtle.lastHeartbeat > HEARTBEAT_TIMEOUT &&
      turtle.status !== "offline"
    ) {
      console.log(`Turtle ${id} timed out`);
      turtle.status = "offline";
      updateDebugClients();
    }
  });
}, OFFLINE_CHECK_INTERVAL);

// Start the server
server.listen(PORT, () => {
  console.log(`Turtle Orchestration Server running on http://0.0.0.0:${PORT}`);
  console.log(`WebSocket server available at ws://0.0.0.0:${PORT}`);
});