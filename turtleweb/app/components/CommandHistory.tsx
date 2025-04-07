"use client";

import { useWebSocket } from './WebSocketProvider';

const CommandHistory = () => {
  const { commandHistory } = useWebSocket();

  return (
    <div className="bg-card rounded-lg shadow-panel p-6">
      <h2 className="text-lg font-semibold text-primary mb-4">Command History</h2>
      <div className="max-h-[400px] overflow-y-auto flex flex-col gap-3">
        {commandHistory.length === 0 ? (
          <div className="text-center text-gray-500 py-8">No commands executed yet</div>
        ) : (
          commandHistory.map((item, index) => (
            <div key={index} className="bg-background rounded-md p-3 border-l-4 border-border animate-[fadeIn_0.3s_ease]">
              <div className="flex justify-between items-center mb-2">
                <span className="font-semibold">{item.turtleId}</span>
                <span className={`text-xs py-1 px-2 rounded-full text-card ${item.response.success ? 'bg-success' : 'bg-danger'}`}>
                  {item.response.success ? "Success" : "Failed"}
                </span>
              </div>
              <div className="text-sm">
                {item.response.message && (
                  <div className="mb-2">{item.response.message}</div>
                )}
                {item.response.fuel !== undefined && (
                  <div className="mb-2">Fuel: {item.response.fuel}</div>
                )}
                {item.response.inventory && (
                  <div>
                    <div>Inventory:</div>
                    <div className="grid grid-cols-4 gap-2 mt-2">
                      {Array.from({ length: 16 }).map((_, i) => (
                        <div key={i} className="bg-white border border-border rounded p-2 text-xs flex flex-col items-center justify-center aspect-square">
                          {item.response.inventory && item.response.inventory[i] ? (
                            <>
                              <div>{item.response.inventory[i]?.name}</div>
                              <div>x{item.response.inventory[i]?.count}</div>
                            </>
                          ) : (
                            i + 1
                          )}
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default CommandHistory;