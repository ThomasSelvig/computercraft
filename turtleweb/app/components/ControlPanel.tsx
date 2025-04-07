"use client";

import { useWebSocket } from './WebSocketProvider';
import { buttonStyle } from '../utils/helpers';

const ControlPanel = () => {
  const { selectedTurtle, sendCommand } = useWebSocket();

  return (
    <div className="bg-card rounded-lg shadow-panel p-6">
      <h2 className="text-lg font-semibold text-primary mb-4">Control Panel</h2>
      <p className="mb-4">
        Selected: <strong>{selectedTurtle === "all" ? "All Turtles" : selectedTurtle}</strong>
      </p>

      <div className="mb-8">
        <h3 className="text-base mb-3 pb-2 border-b border-border">Movement</h3>
        <div className="grid grid-cols-3 gap-3">
          <button
            onClick={() => sendCommand("move", { direction: "up" })}
            className={buttonStyle}
          >
            Up
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "forward" })}
            className={buttonStyle}
          >
            Forward
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "down" })}
            className={buttonStyle}
          >
            Down
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "turnLeft" })}
            className={buttonStyle}
          >
            Turn Left
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "back" })}
            className={buttonStyle}
          >
            Back
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "turnRight" })}
            className={buttonStyle}
          >
            Turn Right
          </button>
        </div>
      </div>

      <div className="mb-8">
        <h3 className="text-base mb-3 pb-2 border-b border-border">Actions</h3>
        <div className="grid grid-cols-3 gap-3">
          <button
            onClick={() => sendCommand("dig", { direction: "up" })}
            className={buttonStyle}
          >
            Dig Up
          </button>
          <button
            onClick={() => sendCommand("dig")}
            className={buttonStyle}
          >
            Dig Forward
          </button>
          <button
            onClick={() => sendCommand("dig", { direction: "down" })}
            className={buttonStyle}
          >
            Dig Down
          </button>
          <button
            onClick={() => sendCommand("place", { direction: "up" })}
            className={buttonStyle}
          >
            Place Up
          </button>
          <button
            onClick={() => sendCommand("place")}
            className={buttonStyle}
          >
            Place Forward
          </button>
          <button
            onClick={() => sendCommand("place", { direction: "down" })}
            className={buttonStyle}
          >
            Place Down
          </button>
        </div>
      </div>

      <div>
        <h3 className="text-base mb-3 pb-2 border-b border-border">Information</h3>
        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={() => sendCommand("getFuelLevel")}
            className={buttonStyle}
          >
            Get Fuel Level
          </button>
          <button
            onClick={() => sendCommand("getInventory")}
            className={buttonStyle}
          >
            Get Inventory
          </button>
        </div>
      </div>
    </div>
  );
};

export default ControlPanel;