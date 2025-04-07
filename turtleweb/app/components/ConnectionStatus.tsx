"use client";

import { useWebSocket } from './WebSocketProvider';

const ConnectionStatus = () => {
  const { connected } = useWebSocket();
  
  return (
    <div className="flex items-center">
      <div className={`status-badge ${connected ? 'status-badge-active' : 'status-badge-error'}`}>
        <div className="flex items-center">
          <div className={`w-2 h-2 rounded-full mr-1.5 ${connected ? 'bg-success animate-pulse' : 'bg-danger'}`}></div>
          <span>{connected ? "Connected" : "Disconnected"}</span>
        </div>
      </div>
    </div>
  );
};

export default ConnectionStatus;