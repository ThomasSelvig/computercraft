"use client";

import ControlPanel from '../../../components/ControlPanel';
import CommandHistory from '../../../components/CommandHistory';
import GamepadController from '../../../components/GamepadController';

export default function TurtleDetailsPage({ params }: { params: { id: string } }) {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Turtle #{params.id}</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Status</h2>
          {/* Turtle status details will go here */}
          <div className="p-4 bg-background rounded">
            <p>ID: {params.id}</p>
            <p>Status: Online</p>
            <p>Fuel: 1000/1000</p>
            <p>Position: X: 0, Y: 0, Z: 0</p>
          </div>
        </div>
        
        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Inventory</h2>
          {/* Inventory details will go here */}
          <div className="grid grid-cols-4 gap-2">
            {[...Array(16)].map((_, index) => (
              <div key={index} className="aspect-square bg-background rounded flex items-center justify-center">
                {index + 1}
              </div>
            ))}
          </div>
        </div>
      </div>
      
      <div className="mt-4">
        <ControlPanel />
      </div>
      
      <div className="mt-4">
        <CommandHistory />
      </div>
      
      <GamepadController />
    </div>
  );
}