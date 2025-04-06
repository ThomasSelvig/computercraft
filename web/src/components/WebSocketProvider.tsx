import React, { createContext, useState, useEffect, useContext, useMemo, useRef, useCallback } from 'react';
import { Turtle, CommandResponse, WebSocketContextType } from '../types';

const WebSocketContext = createContext<WebSocketContextType | null>(null);

export const useWebSocket = () => {
  const context = useContext(WebSocketContext);
  if (!context) {
    throw new Error('useWebSocket must be used within a WebSocketProvider');
  }
  return context;
};

export const WebSocketProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [turtles, setTurtles] = useState<Turtle[]>([]);
  const [selectedTurtle, setSelectedTurtle] = useState<string>("all");
  const [socket, setSocket] = useState<WebSocket | null>(null);
  const [connected, setConnected] = useState(false);
  const [commandHistory, setCommandHistory] = useState<CommandResponse[]>([]);
  
  // Use a ref to track if we've already initialized a connection
  // This prevents duplicate connections in React Strict Mode
  const socketInitialized = useRef(false);

  useEffect(() => {
    let reconnectTimeout: NodeJS.Timeout;

    const connectWebSocket = () => {
      // Don't create new connections if we already have one
      if (socket) {
        console.log("WebSocket connection already exists, skipping initialization");
        return;
      }

      // Avoid duplicate initialization in React Strict Mode
      if (socketInitialized.current) {
        console.log("Socket initialization already attempted, skipping");
        return;
      }

      socketInitialized.current = true;

      const wsUrl = "wss://sought-composed-alpaca.ngrok-free.app";
      console.log("Connecting to WebSocket server at:", wsUrl);

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
        socketInitialized.current = false; // Allow reconnection after close

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
        console.log("Cleaning up WebSocket connection");
        socket.close();
      }
      clearTimeout(reconnectTimeout);
    };
  }, []);

  // Send a command to selected turtle
  const sendCommand = useCallback((action: string, params: any = {}) => {
    console.log("Sending command:", action, params);
    if (!socket) {
      console.error("Cannot send command: socket is null");
      // Show error to user so they know something is wrong
      alert(
        "Cannot send command: WebSocket connection not established. Please try refreshing the page."
      );
      return;
    }
    if (!connected) {
      console.error("Cannot send command: not connected");
      alert(
        "Cannot send command: Not connected to server. Please check your connection."
      );
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
  }, [socket, connected, selectedTurtle]);

  const value = useMemo(() => ({
    turtles,
    connected,
    selectedTurtle,
    setSelectedTurtle,
    commandHistory,
    sendCommand,
  }), [turtles, connected, selectedTurtle, commandHistory, sendCommand]);

  return (
    <WebSocketContext.Provider value={value}>
      {children}
    </WebSocketContext.Provider>
  );
};

export default WebSocketProvider;