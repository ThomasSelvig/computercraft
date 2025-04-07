"use client";

import { useWebSocket } from "../../components/WebSocketProvider";
import { useEffect, useState } from "react";
import { getStatusColor, formatTimeDiff } from "../../utils/helpers";
import Link from "next/link";
import ControlPanel from "../../components/ControlPanel";

export default function TurtleDetails({ params }: { params: { id: string } }) {
  const { turtles, setSelectedTurtle, sendCommand } = useWebSocket();
  const [turtle, setTurtle] = useState(null);

  useEffect(() => {
    setSelectedTurtle(params.id);
    const currentTurtle = turtles.find(t => t.id === params.id);
    setTurtle(currentTurtle);
  }, [params.id, turtles, setSelectedTurtle]);

  if (!turtle) {
    return (
      <div className="p-8">
        <Link href="/turtles" className="text-primary hover:underline mb-4 inline-block">
          &larr; Back to Turtles
        </Link>
        <div className="bg-card rounded-lg p-6 shadow-panel">
          <h1 className="text-3xl font-bold mb-6">Turtle Not Found</h1>
          <p>No data available for turtle ID: {params.id}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <Link href="/turtles" className="text-primary hover:underline mb-4 inline-block">
        &larr; Back to Turtles
      </Link>
      
      <div className="bg-card rounded-lg p-6 shadow-panel mb-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">Turtle: {turtle.id}</h1>
          <span className={`py-1 px-3 rounded-full text-white ${getStatusColor(turtle.status)}`}>
            {turtle.status}
          </span>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-background p-4 rounded-lg">
            <h2 className="text-lg font-semibold mb-3">Status Information</h2>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-600">Status:</span>
                <span className="font-medium">{turtle.status}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Last Seen:</span>
                <span className="font-medium">{formatTimeDiff(turtle.lastHeartbeat)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Last Command:</span>
                <span className="font-medium">{turtle.lastCommand?.action || "None"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Command Result:</span>
                <span className="font-medium">{turtle.lastCommand?.result || "N/A"}</span>
              </div>
            </div>
          </div>

          <div className="bg-background p-4 rounded-lg">
            <h2 className="text-lg font-semibold mb-3">Position & Resources</h2>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-600">X Position:</span>
                <span className="font-medium">{turtle.position.x ?? "Unknown"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Y Position:</span>
                <span className="font-medium">{turtle.position.y ?? "Unknown"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Z Position:</span>
                <span className="font-medium">{turtle.position.z ?? "Unknown"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Heading:</span>
                <span className="font-medium">{turtle.position.heading ?? "Unknown"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Fuel Level:</span>
                <span className="font-medium">{turtle.position.fuel ?? "Unknown"}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-card rounded-lg p-6 shadow-panel">
        <h2 className="text-xl font-semibold mb-4">Control Panel</h2>
        <ControlPanel />
      </div>
    </div>
  );
}