"use client";

import { useWebSocket } from "../components/WebSocketProvider";
import Link from "next/link";
import { getStatusColor, formatTimeDiff } from "../utils/helpers";

export default function TurtleListPage() {
  const { turtles } = useWebSocket();

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Turtle Fleet Management</h1>
      
      <div className="bg-card rounded-lg p-6 shadow-panel">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">All Turtles ({turtles.length})</h2>
        </div>
        
        {turtles.length === 0 ? (
          <div className="bg-background p-8 rounded-lg text-center">
            <p className="text-gray-500">No turtles connected to the system.</p>
            <p className="text-sm mt-2">Connect a turtle to get started.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {turtles.map(turtle => (
              <Link 
                href={`/turtles/${turtle.id}`} 
                key={turtle.id} 
                className="bg-background p-4 rounded-lg hover:shadow-md transition-all hover:-translate-y-1 cursor-pointer"
              >
                <div className="flex justify-between items-center mb-3">
                  <h3 className="font-semibold">{turtle.id}</h3>
                  <span className={`py-1 px-2 text-xs rounded-full text-white ${getStatusColor(turtle.status)}`}>
                    {turtle.status}
                  </span>
                </div>
                
                <div className="space-y-1 text-sm text-gray-600">
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
                  <div className="flex justify-between">
                    <span>Last Seen:</span>
                    <span>{formatTimeDiff(turtle.lastHeartbeat)}</span>
                  </div>
                  {turtle.lastCommand && (
                    <div className="flex justify-between">
                      <span>Last Command:</span>
                      <span>{turtle.lastCommand.action}</span>
                    </div>
                  )}
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}