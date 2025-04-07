"use client";

import { useWebSocket } from "./WebSocketProvider";
import { buttonStyle } from "../utils/helpers";

const ControlPanel = () => {
  const { selectedTurtle, sendCommand } = useWebSocket();

  // Define button styles
  const actionButtonStyle = `${buttonStyle} flex items-center justify-center`;
  const movementButtonStyle = `${buttonStyle} flex items-center justify-center h-14`;
  const infoButtonStyle = `${buttonStyle} flex items-center justify-center`;

  return (
    <div className="bg-card rounded-lg shadow-panel p-6">
      <h2 className="text-lg font-semibold text-primary mb-4">Control Panel</h2>
      <p className="mb-4">
        Selected:{" "}
        <strong>
          {selectedTurtle === "all" ? "All Turtles" : selectedTurtle}
        </strong>
      </p>

      <div className="mb-8">
        <h3 className="text-base mb-3 pb-2 border-b border-border">
          Movement Controls
        </h3>
        <div className="grid grid-cols-3 gap-2 max-w-[320px] mx-auto">
          {/* Top row */}
          <div className="col-start-2">
            <button
              onClick={() => sendCommand("move", { direction: "forward" })}
              className={`${movementButtonStyle} w-full`}
              title="Forward"
            >
              ↑
            </button>
          </div>

          <div></div>

          {/* Middle row */}
          <button
            onClick={() => sendCommand("move", { direction: "turnLeft" })}
            className={movementButtonStyle}
            title="Turn Left"
          >
            ←
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "back" })}
            className={movementButtonStyle}
            title="Back"
          >
            ↓
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "turnRight" })}
            className={movementButtonStyle}
            title="Turn Right"
          >
            →
          </button>

          {/* Vertical movement row */}
          <div className="col-span-3 grid grid-cols-2 gap-2 mt-2">
            <button
              onClick={() => sendCommand("move", { direction: "up" })}
              className={movementButtonStyle}
              title="Up"
            >
              ⤴ Up
            </button>
            <button
              onClick={() => sendCommand("move", { direction: "down" })}
              className={movementButtonStyle}
              title="Down"
            >
              ⤵ Down
            </button>
          </div>
        </div>
      </div>

      <div className="mb-8">
        <h3 className="text-base mb-3 pb-2 border-b border-border">Actions</h3>
        <div className="grid grid-cols-2 gap-3 max-w-[320px] mx-auto">
          <div className="col-span-2 grid grid-cols-3 gap-2">
            <button
              onClick={() => sendCommand("dig", { direction: "up" })}
              className={`${actionButtonStyle} bg-amber-600`}
              title="Dig Up"
            >
              ⛏️ Up
            </button>
            <button
              onClick={() => sendCommand("dig")}
              className={`${actionButtonStyle} bg-amber-600`}
              title="Dig Forward"
            >
              ⛏️ Front
            </button>
            <button
              onClick={() => sendCommand("dig", { direction: "down" })}
              className={`${actionButtonStyle} bg-amber-600`}
              title="Dig Down"
            >
              ⛏️ Down
            </button>
          </div>

          <div className="col-span-2 grid grid-cols-3 gap-2 mt-2">
            <button
              onClick={() => sendCommand("place", { direction: "up" })}
              className={`${actionButtonStyle} bg-emerald-600`}
              title="Place Up"
            >
              📦 Up
            </button>
            <button
              onClick={() => sendCommand("place")}
              className={`${actionButtonStyle} bg-emerald-600`}
              title="Place Forward"
            >
              📦 Front
            </button>
            <button
              onClick={() => sendCommand("place", { direction: "down" })}
              className={`${actionButtonStyle} bg-emerald-600`}
              title="Place Down"
            >
              📦 Down
            </button>
          </div>
        </div>
      </div>

      <div>
        <h3 className="text-base mb-3 pb-2 border-b border-border">
          Information
        </h3>
        <div className="grid grid-cols-2 gap-3 max-w-[320px] mx-auto">
          <button
            onClick={() => sendCommand("getFuelLevel")}
            className={`${infoButtonStyle} bg-blue-600`}
            title="Get Fuel Level"
          >
            ⛽ Fuel
          </button>
          <button
            onClick={() => sendCommand("getInventory")}
            className={`${infoButtonStyle} bg-blue-600`}
            title="Get Inventory"
          >
            🎒 Inventory
          </button>
        </div>
      </div>
    </div>
  );
};

export default ControlPanel;
