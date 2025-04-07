"use client";

import Header from "./components/Header";
import WebSocketProvider from "./components/WebSocketProvider";
// import GamepadController from "./components/GamepadController";
import TurtleList from "./components/TurtleList";
import ControlPanel from "./components/ControlPanel";
import CommandHistory from "./components/CommandHistory";

export default function HomePage() {
  return (
    <WebSocketProvider>
      <div className="flex flex-col h-full">
        <Header />
        <main className="dashboard-content">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-1">
              <div className="card h-full">
                <div className="card-header flex items-center justify-between">
                  <h2 className="text-lg font-medium">Turtle Fleet</h2>
                  <span className="status-badge status-badge-active">Online</span>
                </div>
                <div className="card-body p-0">
                  <TurtleList />
                </div>
              </div>
            </div>
            <div className="lg:col-span-2">
              <div className="grid grid-cols-1 gap-6">
                <div className="card">
                  <div className="card-header">
                    <h2 className="text-lg font-medium">Control Panel</h2>
                  </div>
                  <div className="card-body">
                    <ControlPanel />
                  </div>
                </div>
                <div className="card">
                  <div className="card-header">
                    <h2 className="text-lg font-medium">Command History</h2>
                  </div>
                  <div className="card-body">
                    <CommandHistory />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
        {/* <GamepadController /> */}
      </div>
    </WebSocketProvider>
  );
}
