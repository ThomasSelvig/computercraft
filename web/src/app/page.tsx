"use client";

import TurtleList from '../components/TurtleList';
import ControlPanel from '../components/ControlPanel';
import CommandHistory from '../components/CommandHistory';
import GamepadController from '../components/GamepadController';

export default function Home() {
  return (
    <div className="flex flex-col p-4">
      <h1 className="text-2xl font-bold mb-4">Fleet Overview</h1>
      
      <div className="flex flex-1 gap-4">
        <TurtleList />
        
        <div className="flex-1 flex flex-col gap-4">
          <ControlPanel />
          <CommandHistory />
        </div>
      </div>
      
      {/* Invisible component that handles gamepad input */}
      <GamepadController />
    </div>
  );
}