import { useWebSocket } from './WebSocketProvider';

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
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Up
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "forward" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Forward
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "down" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Down
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "turnLeft" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Turn Left
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "back" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Back
          </button>
          <button
            onClick={() => sendCommand("move", { direction: "turnRight" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
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
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Dig Up
          </button>
          <button
            onClick={() => sendCommand("dig")}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Dig Forward
          </button>
          <button
            onClick={() => sendCommand("dig", { direction: "down" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Dig Down
          </button>
          <button
            onClick={() => sendCommand("place", { direction: "up" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Place Up
          </button>
          <button
            onClick={() => sendCommand("place")}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Place Forward
          </button>
          <button
            onClick={() => sendCommand("place", { direction: "down" })}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
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
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Get Fuel Level
          </button>
          <button
            onClick={() => sendCommand("getInventory")}
            className="bg-primary text-white border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5"
          >
            Get Inventory
          </button>
        </div>
      </div>
    </div>
  );
};

export default ControlPanel;