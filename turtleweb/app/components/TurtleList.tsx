"use client";

import { useWebSocket } from "./WebSocketProvider";
import { formatTimeDiff, getStatusColor } from "../utils/helpers";

const TurtleList = () => {
  const { turtles, selectedTurtle, setSelectedTurtle } = useWebSocket();

  return (
    <aside className="w-72 bg-card rounded-lg shadow-panel p-4 flex flex-col gap-4 text-black">
      <h2 className="text-lg font-semibold">Turtles</h2>

      <select
        value={selectedTurtle}
        onChange={(e) => setSelectedTurtle(e.target.value)}
        className="w-full p-2 rounded border border-border bg-white mb-4"
      >
        <option value="all">All Turtles</option>
        {turtles.map((turtle) => (
          <option key={turtle.id} value={turtle.id}>
            {turtle.id} - {turtle.status}
          </option>
        ))}
      </select>

      <div className="flex-1 overflow-y-auto flex flex-col gap-3">
        {turtles.length === 0 ? (
          <div className="text-center text-gray-500 py-8">
            No turtles connected
          </div>
        ) : (
          turtles.map((turtle) => (
            <div
              key={turtle.id}
              className={`bg-background rounded-md p-3 cursor-pointer border-2 transition hover:-translate-y-0.5 hover:shadow-sm
                ${
                  selectedTurtle === turtle.id
                    ? "border-primary"
                    : "border-transparent"
                }`}
              onClick={() => setSelectedTurtle(turtle.id)}
            >
              <div className="flex justify-between items-center mb-2">
                <span className="font-semibold">{turtle.id}</span>
                <span
                  className={`text-xs py-1 px-2 rounded-full text-card ${getStatusColor(
                    turtle.status
                  )}`}
                >
                  {turtle.status}
                </span>
              </div>
              <div className="text-sm text-gray-600">
                <div className="flex justify-between">
                  <span>Position:</span>
                  <span>
                    {turtle.position.x !== undefined && turtle.position.y !== undefined && turtle.position.z !== undefined
                      ? `(${turtle.position.x}, ${turtle.position.y}, ${turtle.position.z})`
                      : "Unknown"}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Heading:</span>
                  <span>{turtle.position.heading || "Unknown"}</span>
                </div>
                <div className="flex justify-between">
                  <span>Fuel:</span>
                  <span>{turtle.position.fuel || "Unknown"}</span>
                </div>
                <div>Last seen: {formatTimeDiff(turtle.lastHeartbeat)}</div>
              </div>
            </div>
          ))
        )}
      </div>
    </aside>
  );
};

export default TurtleList;
