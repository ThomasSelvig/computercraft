import { useState, useEffect } from "react";
import "./App.css";

// Types for the turtle monitoring system
interface Turtle {
  id: string;
  lastHeartbeat: number;
  status: "idle" | "offline" | "executing";
  position: {
    fuel?: number;
    [key: string]: any;
  };
  lastCommand?: {
    id: string;
    action: string;
    params?: any;
    result?: string;
    message?: string;
    time?: number;
  };
}

interface CommandResponse {
  turtleId: string;
  response: {
    success: boolean;
    message?: string;
    id: string;
    inventory?: any[];
    fuel?: number;
    [key: string]: any;
  };
}

function App() {
  const [turtles, setTurtles] = useState<Turtle[]>([]);
  const [selectedTurtle, setSelectedTurtle] = useState<string>("all");
  const [socket, setSocket] = useState<WebSocket | null>(null);
  const [connected, setConnected] = useState(false);
  const [commandHistory, setCommandHistory] = useState<CommandResponse[]>([]);

  // Connect to WebSocket server
  useEffect(() => {
    let reconnectTimeout: NodeJS.Timeout;
    const connectWebSocket = () => {
      // Determine the WebSocket URL based on current page location
      // const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
      // const host = window.location.hostname;
      // const port = window.location.port || (protocol === "wss:" ? "443" : "80");
      // const wsUrl = `${protocol}//${host}:${port}`;
      
      const wsUrl = "wss://sought-composed-alpaca.ngrok-free.app";
      console.log("Connecting to WebSocket server at:", wsUrl);
      
      // Clear any existing socket before creating a new one
      if (socket) {
        socket.close();
      }

      const ws = new WebSocket(wsUrl);

      ws.onopen = () => {
        console.log("Connected to WebSocket server");
        setConnected(true);
        clearTimeout(reconnectTimeout);

        // Register as a debug client
        try {
          ws.send(
            JSON.stringify({
              type: "register",
              debugClient: true,
            })
          );
          console.log("Sent registration message");
        } catch (error) {
          console.error("Error sending registration message:", error);
        }
      };

      ws.onclose = () => {
        console.log("Disconnected from WebSocket server");
        setConnected(false);
        setSocket(null);

        // Try to reconnect after a delay
        console.log("Will try to reconnect in 5 seconds...");
        reconnectTimeout = setTimeout(() => {
          console.log("Attempting to reconnect...");
          connectWebSocket();
        }, 5000);
      };

      ws.onerror = (error) => {
        console.error("WebSocket error:", error);
      };

      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          console.log("Received message:", data);

          if (data.type === "turtleUpdate") {
            setTurtles(data.turtles);
          } else if (data.type === "commandResponse") {
            setCommandHistory((prev) => [data, ...prev].slice(0, 100));
          }
        } catch (error) {
          console.error("Error parsing WebSocket message:", error);
        }
      };

      setSocket(ws);
    };

    // Initial connection
    connectWebSocket();

    // Cleanup function
    return () => {
      if (socket) {
        socket.close();
      }
      clearTimeout(reconnectTimeout);
    };
  }, []);

  // Send a command to selected turtle
  const sendCommand = (action: string, params: any = {}) => {
    console.log("Sending command:", action, params);
    if (!socket) {
      console.error("Cannot send command: socket is null");
      // Show error to user so they know something is wrong
      alert("Cannot send command: WebSocket connection not established. Please try refreshing the page.");
      return;
    }
    if (!connected) {
      console.error("Cannot send command: not connected");
      alert("Cannot send command: Not connected to server. Please check your connection.");
      return;
    }

    const commandObj = {
      type: "command",
      target: selectedTurtle,
      action,
      params,
    };
    
    console.log("Sending JSON:", JSON.stringify(commandObj));
    
    try {
      socket.send(JSON.stringify(commandObj));
      console.log("Command sent successfully");
    } catch (error) {
      console.error("Error sending command:", error);
      alert(`Error sending command: ${error}`);
    }
  };

  // Format time difference
  const formatTimeDiff = (timestamp: number) => {
    const now = Date.now();
    const diff = now - timestamp;

    if (diff < 1000) return "just now";
    if (diff < 60000) return `${Math.floor(diff / 1000)}s ago`;
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
    return `${Math.floor(diff / 3600000)}h ago`;
  };

  // Determine status color
  const getStatusColor = (status: string) => {
    switch (status) {
      case "idle":
        return "green";
      case "executing":
        return "blue";
      case "offline":
        return "red";
      default:
        return "gray";
    }
  };

  return (
    <div className="dashboard">
      <header>
        <h1>ComputerCraft Turtle Control Center</h1>
        <div className="connection-status">
          Status:{" "}
          <span className={connected ? "connected" : "disconnected"}>
            <span className="connection-indicator"></span>
            {connected ? "Connected" : "Disconnected"}
          </span>
        </div>
      </header>

      <div className="dashboard-container">
        <div className="sidebar">
          <h2>Turtles</h2>
          <select
            value={selectedTurtle}
            onChange={(e) => setSelectedTurtle(e.target.value)}
            className="turtle-selector"
          >
            <option value="all">All Turtles</option>
            {turtles.map((turtle) => (
              <option key={turtle.id} value={turtle.id}>
                {turtle.id} - {turtle.status}
              </option>
            ))}
          </select>

          <div className="turtle-list">
            {turtles.length === 0 ? (
              <div className="no-turtles">No turtles connected</div>
            ) : (
              turtles.map((turtle) => (
                <div
                  key={turtle.id}
                  className={`turtle-item ${
                    selectedTurtle === turtle.id ? "selected" : ""
                  }`}
                  onClick={() => setSelectedTurtle(turtle.id)}
                >
                  <div className="turtle-header">
                    <span className="turtle-name">{turtle.id}</span>
                    <span
                      className="turtle-status"
                      style={{ backgroundColor: getStatusColor(turtle.status) }}
                    >
                      {turtle.status}
                    </span>
                  </div>
                  <div className="turtle-details">
                    <div>Fuel: {turtle.position.fuel || "Unknown"}</div>
                    <div>Last seen: {formatTimeDiff(turtle.lastHeartbeat)}</div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="main-content">
          <div className="control-panel">
            <h2>Control Panel</h2>
            <p>
              Selected:{" "}
              <strong>
                {selectedTurtle === "all" ? "All Turtles" : selectedTurtle}
              </strong>
            </p>

            <div className="control-group">
              <h3>Movement</h3>
              <div className="button-grid">
                <button
                  onClick={() => sendCommand("move", { direction: "up" })}
                >
                  Up
                </button>
                <button
                  onClick={() => sendCommand("move", { direction: "forward" })}
                >
                  Forward
                </button>
                <button
                  onClick={() => sendCommand("move", { direction: "down" })}
                >
                  Down
                </button>
                <button
                  onClick={() => sendCommand("move", { direction: "turnLeft" })}
                >
                  Turn Left
                </button>
                <button
                  onClick={() => sendCommand("move", { direction: "back" })}
                >
                  Back
                </button>
                <button
                  onClick={() =>
                    sendCommand("move", { direction: "turnRight" })
                  }
                >
                  Turn Right
                </button>
              </div>
            </div>

            <div className="control-group">
              <h3>Actions</h3>
              <div className="button-grid">
                <button onClick={() => sendCommand("dig", { direction: "up" })}>
                  Dig Up
                </button>
                <button onClick={() => sendCommand("dig")}>Dig Forward</button>
                <button
                  onClick={() => sendCommand("dig", { direction: "down" })}
                >
                  Dig Down
                </button>
                <button
                  onClick={() => sendCommand("place", { direction: "up" })}
                >
                  Place Up
                </button>
                <button onClick={() => sendCommand("place")}>
                  Place Forward
                </button>
                <button
                  onClick={() => sendCommand("place", { direction: "down" })}
                >
                  Place Down
                </button>
              </div>
            </div>

            <div className="control-group">
              <h3>Information</h3>
              <div className="button-grid">
                <button onClick={() => sendCommand("getFuelLevel")}>
                  Get Fuel Level
                </button>
                <button onClick={() => sendCommand("getInventory")}>
                  Get Inventory
                </button>
              </div>
            </div>
          </div>

          <div className="response-panel">
            <h2>Command History</h2>
            <div className="command-history">
              {commandHistory.length === 0 ? (
                <div className="no-commands">No commands executed yet</div>
              ) : (
                commandHistory.map((item, index) => (
                  <div key={index} className="command-item">
                    <div className="command-header">
                      <span className="turtle-id">{item.turtleId}</span>
                      <span
                        className={`command-status ${
                          item.response.success ? "success" : "error"
                        }`}
                      >
                        {item.response.success ? "Success" : "Failed"}
                      </span>
                    </div>
                    <div className="command-details">
                      {item.response.message && (
                        <div className="command-message">
                          {item.response.message}
                        </div>
                      )}
                      {item.response.fuel !== undefined && (
                        <div className="command-fuel">
                          Fuel: {item.response.fuel}
                        </div>
                      )}
                      {item.response.inventory && (
                        <div className="command-inventory">
                          <div>Inventory:</div>
                          <div className="inventory-grid">
                            {Array.from({ length: 16 }).map((_, i) => (
                              <div key={i} className="inventory-slot">
                                {item.response.inventory[i] ? (
                                  <>
                                    <div>{item.response.inventory[i].name}</div>
                                    <div>
                                      x{item.response.inventory[i].count}
                                    </div>
                                  </>
                                ) : (
                                  i + 1
                                )}
                              </div>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
