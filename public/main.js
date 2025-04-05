// WebSocket connection
let socket;
let turtles = new Map();

// Connect to WebSocket server
function connectWebSocket() {
  // Determine the WebSocket URL based on the current page location
  const protocol = location.protocol === "https:" ? "wss:" : "ws:";
  const wsUrl = `${protocol}//${location.host}`;

  socket = new WebSocket(wsUrl);

  socket.onopen = () => {
    console.log("Connected to server");
    // Identify as debug client
    socket.send(JSON.stringify({ type: "register", "debug-client": true }));
  };

  socket.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data);
      handleServerMessage(data);
    } catch (error) {
      console.error("Error parsing message:", error);
    }
  };

  socket.onclose = () => {
    console.log("Disconnected from server. Attempting to reconnect...");
    setTimeout(connectWebSocket, 3000);
  };

  socket.onerror = (error) => {
    console.error("WebSocket error:", error);
  };
}

// Handle messages from the server
function handleServerMessage(data) {
  console.log("Received message:", data);
  if (data.type === "turtleUpdate") {
    updateTurtles(data.turtles);
  } else if (data.type === "commandResponse") {
    // Update the turtle's last command with the response
    if (turtles.has(data.turtleId)) {
      const turtle = turtles.get(data.turtleId);
      turtle.lastCommand = {
        ...turtle.lastCommand,
        result: data.response.success ? "success" : "failed",
        message: data.response.message,
        time: Date.now(),
      };
      // Update the turtle's status to idle
      turtle.status = "idle";
      // Render the updated UI
      renderTurtleGrid();
    }
  } else if (data.type === "commandConfirmation") {
    console.log("Command confirmed:", data);
  } else if (data.type === "error") {
    console.error("Server error:", data.message);
    alert("Error: " + data.message);
  }
}

// Update the turtle list and UI
function updateTurtles(turtleList) {
  // Update our local data
  turtleList.forEach((turtle) => {
    const isConnected = turtle.status !== "offline";
    const existingTurtle = turtles.get(turtle.id);

    // Preserve existing command information if available
    const lastCommand =
      turtle.lastCommand ||
      (existingTurtle ? existingTurtle.lastCommand : null);

    turtles.set(turtle.id, {
      name: turtle.id,
      connected: isConnected,
      status: turtle.status,
      lastSeen: turtle.lastHeartbeat,
      position: turtle.position,
      lastCommand: lastCommand,
      currentCommand: turtle.status === "executing" ? lastCommand : null,
    });
  });

  // Update the UI
  renderTurtleGrid();
  updateTargetDropdown();
  updateStats();

  // Update the last update timestamp
  document.getElementById("last-update").textContent =
    new Date().toLocaleTimeString();
}

// Render the turtle grid
function renderTurtleGrid() {
  const grid = document.getElementById("turtle-grid");

  // If there are no turtles, show empty state
  if (turtles.size === 0) {
    grid.innerHTML =
      '<div class="empty-state">No turtles connected yet. Waiting for turtles to join...</div>';
    return;
  }

  // Clear the grid
  grid.innerHTML = "";

  // Add a card for each turtle
  turtles.forEach((turtleData, name) => {
    const card = document.createElement("div");
    card.className = `turtle-card ${
      turtleData.connected ? "connected" : "disconnected"
    }`;

    // Determine the status class
    let statusClass = "status-disconnected";
    if (turtleData.connected) {
      statusClass =
        turtleData.status === "idle" ? "status-idle" : "status-executing";
    }

    // Format the last seen time
    const lastSeen = turtleData.lastSeen
      ? new Date(turtleData.lastSeen).toLocaleTimeString()
      : "Unknown";

    // Create turtle header with status indicator
    let header = `
            <h3>
                <span>
                    <span class="status-indicator ${statusClass}"></span>
                    ${name}
                </span>
                <span style="font-weight: normal; font-size: 12px;">
                    ${turtleData.connected ? "Online" : "Offline"}
                </span>
            </h3>
        `;

    // Create turtle details
    let details = `
            <div class="turtle-details">
                <div><strong>Status:</strong> <span class="${
                  turtleData.status === "idle"
                    ? "success"
                    : turtleData.status === "executing"
                    ? "executing"
                    : "failed"
                }">${turtleData.status}</span></div>
                <div><strong>Last Seen:</strong> ${lastSeen}</div>
                <div><strong>Fuel:</strong> ${
                  turtleData.position?.fuel || "Unknown"
                }</div>
                <div><strong>ID:</strong> ${name}</div>
            </div>
        `;

    // Add current command if the turtle is executing one
    let currentCommand = "";
    if (turtleData.status === "executing" && turtleData.currentCommand) {
      const cmd = turtleData.currentCommand;
      const startTime = cmd.startTime || cmd.time || Date.now();
      const duration = Math.round((Date.now() - startTime) / 1000);
      const action = cmd.action || "Unknown command";

      currentCommand = `
                <div class="turtle-details" style="background-color: #fff3e0; padding: 8px; border-left: 3px solid #ff9800; margin: 10px 0;">
                    <div><strong>Executing:</strong> ${action}</div>
                    <div><strong>Duration:</strong> ${duration}s</div>
                    ${
                      cmd.params
                        ? `<div><strong>Params:</strong> ${JSON.stringify(
                            cmd.params
                          )}</div>`
                        : ""
                    }
                </div>
            `;
    }

    // Add last command result if available
    let lastCommandResult = "";
    if (turtleData.lastCommand) {
      const cmd = turtleData.lastCommand;
      const cmdAction = cmd.action || "Unknown";
      const cmdParams = cmd.params ? JSON.stringify(cmd.params) : "";

      lastCommandResult = `
                <div class="command-result">
                    <div><strong>Last Command:</strong> ${cmdAction} ${cmdParams}</div>
                    <div class="${
                      cmd.result === "success" ? "success" : "failed"
                    }">
                        <strong>Result:</strong> ${cmd.result || "pending"}
                    </div>
                    ${
                      cmd.message
                        ? `<div><strong>Message:</strong> ${cmd.message}</div>`
                        : ""
                    }
                    <div><strong>Time:</strong> ${
                      cmd.time
                        ? new Date(cmd.time).toLocaleTimeString()
                        : "In progress"
                    }</div>
                </div>
            `;
    }

    // Combine all sections
    card.innerHTML = header + details + currentCommand + lastCommandResult;
    grid.appendChild(card);
  });
}

// Update the target dropdown with available turtles
function updateTargetDropdown() {
  const targetSelect = document.getElementById("target");
  const currentSelection = targetSelect.value;

  // Clear options except for "All Turtles"
  while (targetSelect.options.length > 1) {
    targetSelect.remove(1);
  }

  // Add an option for each turtle
  turtles.forEach((_, name) => {
    const option = document.createElement("option");
    option.value = name;
    option.textContent = name;
    targetSelect.appendChild(option);
  });

  // Try to restore the previous selection
  if (currentSelection && [...turtles.keys()].includes(currentSelection)) {
    targetSelect.value = currentSelection;
  }
}

// Update the statistics
function updateStats() {
  const connectedCount = [...turtles.values()].filter(
    (t) => t.connected
  ).length;
  document.getElementById("connected-count").textContent = connectedCount;
}

// Send a command to the server
function sendCommand(target, action, params) {
  if (!socket || socket.readyState !== WebSocket.OPEN) {
    alert("Not connected to server. Please refresh the page.");
    return;
  }

  const command = {
    type: "command",
    target,
    action,
    params,
  };

  // Update the turtle's status in the UI immediately
  if (target !== "all") {
    if (turtles.has(target)) {
      const turtle = turtles.get(target);
      turtle.status = "executing";
      turtle.currentCommand = {
        action,
        params,
        startTime: Date.now(),
      };
      renderTurtleGrid();
    }
  } else {
    // Update all connected turtles
    turtles.forEach((turtle, id) => {
      if (turtle.connected) {
        turtle.status = "executing";
        turtle.currentCommand = {
          action,
          params,
          startTime: Date.now(),
        };
      }
    });
    renderTurtleGrid();
  }

  socket.send(JSON.stringify(command));
}

// Refresh the UI to update durations
function refreshUI() {
  if (turtles.size > 0) {
    renderTurtleGrid();
  }
}

// Initialize the application
document.addEventListener("DOMContentLoaded", () => {
  // Add global styles
  document.head.insertAdjacentHTML(
    "beforeend",
    `
    <style>
      .executing {
        color: #ff9800;
        font-weight: bold;
      }
      .turtle-details {
        line-height: 1.6;
      }
      .command-result {
        margin-top: 15px;
        border-top: 1px solid #eee;
        padding-top: 10px;
      }
    </style>
  `
  );

  // Connect to WebSocket server
  connectWebSocket();

  // Auto-refresh the UI every second to update durations
  setInterval(refreshUI, 1000);

  // Set up command form handler
  document
    .getElementById("command-form")
    .addEventListener("submit", (event) => {
      event.preventDefault();

      const target = document.getElementById("target").value;
      const action = document.getElementById("action").value;

      // Build the parameters based on the action
      const params = {};

      if (["move", "dig", "place"].includes(action)) {
        params.direction = document.getElementById("direction").value;
      }

      if (action === "place") {
        params.slot = parseInt(document.getElementById("slot").value, 10);
      }

      // Send the command
      sendCommand(target, action, params);
    });

  // Show/hide parameter inputs based on the selected action
  document.getElementById("action").addEventListener("change", (event) => {
    const action = event.target.value;
    document.getElementById("direction-group").style.display = [
      "move",
      "dig",
      "place",
    ].includes(action)
      ? "block"
      : "none";
    document.getElementById("slot-group").style.display =
      action === "place" ? "block" : "none";
  });
});
