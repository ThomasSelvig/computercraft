"use client";

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
  
  // Use refs to track connection state and reconnection attempts
  const socketInitialized = useRef(false);
  const reconnectAttempts = useRef(0);
  const maxReconnectAttempts = 10;

  useEffect(() => {
    let reconnectTimeout: NodeJS.Timeout;

    const connectWebSocket = () => {
      // Don't create new connections if we already have one
      if (socket && socket.readyState !== WebSocket.CLOSED && socket.readyState !== WebSocket.CLOSING) {
        console.log("WebSocket connection already exists, skipping initialization");
        return;
      }

      // Reset socket if it's in a closing/closed state
      if (socket && (socket.readyState === WebSocket.CLOSED || socket.readyState === WebSocket.CLOSING)) {
        setSocket(null);
      }

      // Check reconnection attempts
      if (reconnectAttempts.current > maxReconnectAttempts) {
        console.error(`Failed to connect after ${maxReconnectAttempts} attempts`);
        return;
      }

      reconnectAttempts.current += 1;

      // For both local and production, use relative WebSocket URL
      const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      const wsPort = window.location.hostname === 'localhost' ? ':1337' : '';
      const wsUrl = `${wsProtocol}//${window.location.hostname}${wsPort}`;
      console.log("Connecting to WebSocket server at:", wsUrl);

      const ws = new WebSocket(wsUrl);

      ws.onopen = () => {
        console.log("Connected to WebSocket server");
        setConnected(true);
        clearTimeout(reconnectTimeout);
        
        // Reset reconnect attempts on successful connection
        reconnectAttempts.current = 0;

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

        // Implement exponential backoff for reconnection
        const delay = Math.min(5000 * Math.pow(1.5, reconnectAttempts.current), 30000);
        console.log(`Will try to reconnect in ${delay/1000} seconds... (attempt ${reconnectAttempts.current})`);
        
        reconnectTimeout = setTimeout(() => {
          console.log("Attempting to reconnect...");
          connectWebSocket();
        }, delay);
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