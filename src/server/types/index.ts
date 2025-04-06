// Types for WebSocket server

export interface TurtleInfo {
  connection: any; // WebSocket connection
  lastHeartbeat: number;
  status: 'idle' | 'executing' | 'offline';
  position: TurtlePosition;
  lastCommand: any;
}

export interface TurtlePosition {
  x?: number;
  y?: number;
  z?: number;
  heading?: 'north' | 'east' | 'south' | 'west';
  fuel?: number;
}

export interface CommandMessage {
  id: string;
  target: string;
  action: string;
  params: Record<string, any>;
}

export interface RegisterMessage {
  type: 'register';
  turtle?: string;
  debugClient?: boolean;
  time?: number;
  capabilities?: string[];
}

export interface HeartbeatMessage {
  type: 'heartbeat';
  turtle: string;
  time?: number;
  position: TurtlePosition;
}

export interface CommandResponse {
  success: boolean;
  message?: string;
  id: string;
  turtle: string;
  [key: string]: any;
}

export interface WebSocketMessage {
  type: string;
  [key: string]: any;
}