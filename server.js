// server.js - Node.js WebSocket Server for Turtle Swarm

const WebSocket = require("ws");
const express = require("express");
const path = require("path");
const http = require("http");
const fs = require("fs");

const app = express();
const port = process.env.PORT || 1339;

// Serve static files
app.use(express.static("public"));

// Serve the debug page
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "debug.html"));
});

// Create HTTP server
const server = http.createServer(app);

// Create WebSocket server
const wss = new WebSocket.Server({ server });

// Store connected turtles
const turtles = new Map();

// Command queue for turtles
const commandQueue = new Map();

// Generate a unique command ID
let commandIdCounter = 0;
function generateCommandId() {
  return `cmd-${Date.now()}-${commandIdCounter++}`;
}

// Broadcast to all connected debug clients
function broadcastToDebugClients(message) {
  wss.clients.forEach((client) => {
    if (client.isDebugClient && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(message));
    }
  });
}

// Update all debug clients with current turtle status
function updateDebugClients() {
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

// Handle new WebSocket connections
wss.on("connection", (ws, req) => {
  console.log("New connection established");

  // For identifying the client type
  ws.isTurtle = false;
  ws.isDebugClient = false;
  ws.turtleId = null;

  // Handle incoming messages
  ws.on("message", (message) => {
    try {
      const data = JSON.parse(message);

      // Handle client type identification
      if (data.type === "register") {
        if (data.turtle) {
          // This is a turtle client
          console.log(`Turtle ${data.turtle} registered`);
          ws.isTurtle = true;
          ws.turtleId = data.turtle;

          turtles.set(data.turtle, {
            connection: ws,
            lastHeartbeat: Date.now(),
            status: "idle",
            position: {},
            lastCommand: null,
          });

          // Check if there are any pending commands for this turtle
          if (commandQueue.has(data.turtle)) {
            const commands = commandQueue.get(data.turtle);
            commands.forEach((cmd) => {
              ws.send(JSON.stringify(cmd));
              turtles.get(data.turtle).lastCommand = cmd;
              turtles.get(data.turtle).status = "executing";
            });
            commandQueue.delete(data.turtle);
          }

          updateDebugClients();
        } else if (data.type === "debug-client") {
          // This is a debug client
          console.log("Debug client connected");
          ws.isDebugClient = true;

          // Send initial turtle status
          updateDebugClients();
        }
      } else if (data.type === "heartbeat" && ws.isTurtle) {
        // Update turtle status with heartbeat
        if (turtles.has(data.turtle)) {
          const turtle = turtles.get(data.turtle);
          turtle.lastHeartbeat = Date.now();
          turtle.position = data.position || turtle.position;
          updateDebugClients();
        }
      } else if (data.type === "command" && ws.isDebugClient) {
        // Process command from debug client
        const { target, action, params } = data;

        const commandId = generateCommandId();
        const command = {
          id: commandId,
          target: target,
          action: action,
          params: params,
        };

        // Send to specific turtle or all turtles
        if (target === "all") {
          let commandSent = false;
          turtles.forEach((turtle, id) => {
            if (turtle.connection.readyState === WebSocket.OPEN) {
              turtle.connection.send(JSON.stringify(command));
              turtle.lastCommand = command;
              turtle.status = "executing";
              commandSent = true;
            } else {
              // Queue command for offline turtle
              if (!commandQueue.has(id)) {
                commandQueue.set(id, []);
              }
              commandQueue.get(id).push(command);
            }
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
          const turtle = turtles.get(target);
          if (turtle.connection.readyState === WebSocket.OPEN) {
            turtle.connection.send(JSON.stringify(command));
            turtle.lastCommand = command;
            turtle.status = "executing";
            updateDebugClients();
          } else {
            // Queue command for offline turtle
            if (!commandQueue.has(target)) {
              commandQueue.set(target, []);
            }
            commandQueue.get(target).push(command);
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
      } else if (ws.isTurtle && data.id) {
        // This is a response from a turtle
        console.log(`Received response from turtle ${ws.turtleId}: `, data);

        if (turtles.has(ws.turtleId)) {
          const turtle = turtles.get(ws.turtleId);
          turtle.status = "idle";

          // Broadcast the response to debug clients
          broadcastToDebugClients({
            type: "commandResponse",
            turtleId: ws.turtleId,
            response: data,
          });

          updateDebugClients();
        }
      }
    } catch (error) {
      console.error("Error processing message:", error);
    }
  });

  // Handle disconnections
  ws.on("close", () => {
    if (ws.isTurtle && ws.turtleId) {
      console.log(`Turtle ${ws.turtleId} disconnected`);

      // Don't remove the turtle from the map, just mark it as offline
      if (turtles.has(ws.turtleId)) {
        const turtle = turtles.get(ws.turtleId);
        turtle.status = "offline";
        turtle.connection = null;
        updateDebugClients();
      }
    } else if (ws.isDebugClient) {
      console.log("Debug client disconnected");
    }
  });
});

// Periodically check for stale turtles
setInterval(() => {
  const now = Date.now();
  turtles.forEach((turtle, id) => {
    // If no heartbeat for 10 seconds and not already marked offline
    if (now - turtle.lastHeartbeat > 10000 && turtle.status !== "offline") {
      console.log(`Turtle ${id} timed out`);
      turtle.status = "offline";
      updateDebugClients();
    }
  });
}, 5000);

// Start the server
server.listen(port, "0.0.0.0", () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});
