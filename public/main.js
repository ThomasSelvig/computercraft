// WebSocket connection
let socket;
let turtles = new Map();

// Connect to WebSocket server
function connectWebSocket() {
  // Determine the WebSocket URL based on the current page location
  const protocol = location.protocol === "https:" ? "wss:" : "ws:";
  const wsUrl = `${protocol}//${location.host}/turtles`;

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
  }
}

// Update the turtle list and UI
function updateTurtles(turtleList) {
  // Update our local data
  turtles.clear();
  turtleList.forEach((turtle) => {
    const isConnected = turtle.status !== "offline";
    turtles.set(turtle.id, {
      name: turtle.id,
      connected: isConnected,
      status: turtle.status,
      lastSeen: turtle.lastHeartbeat,
      position: turtle.position,
      currentCommand: turtle.lastCommand,
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
                <div><strong>Status:</strong> ${turtleData.status}</div>
                <div><strong>Last Seen:</strong> ${lastSeen}</div>
                <div><strong>Fuel:</strong> ${
                  turtleData.position?.fuel || "Unknown"
                }</div>
            </div>
        `;

    // Add current command if the turtle is executing one
    let currentCommand = "";
    if (turtleData.status === "executing" && turtleData.currentCommand) {
      const cmd = turtleData.currentCommand;
      const duration = Math.round((Date.now() - cmd.startTime) / 1000);

      currentCommand = `
                <div class="turtle-details">
                    <div><strong>Executing:</strong> ${cmd.action}</div>
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
      lastCommandResult = `
                <div class="command-result">
                    <div><strong>Last Command:</strong> ${cmd.id}</div>
                    <div class="${
                      cmd.result === "success" ? "success" : "failed"
                    }">
                        <strong>Result:</strong> ${cmd.result}
                    </div>
                    ${
                      cmd.message
                        ? `<div><strong>Message:</strong> ${cmd.message}</div>`
                        : ""
                    }
                    <div><strong>Time:</strong> ${new Date(
                      cmd.time
                    ).toLocaleTimeString()}</div>
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

  socket.send(JSON.stringify(command));
}

// Initialize the application
document.addEventListener("DOMContentLoaded", () => {
  // Connect to WebSocket server
  connectWebSocket();

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
