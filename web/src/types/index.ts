// Types for the turtle monitoring system
export interface Turtle {
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

export interface CommandResponse {
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

export interface WebSocketContextType {
  turtles: Turtle[];
  connected: boolean;
  selectedTurtle: string;
  setSelectedTurtle: (id: string) => void;
  commandHistory: CommandResponse[];
  sendCommand: (action: string, params?: any) => void;
}