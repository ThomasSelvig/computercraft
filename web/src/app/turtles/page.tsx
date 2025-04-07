"use client";

import TurtleList from '../../components/TurtleList';

export default function TurtlePage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Turtle Management</h1>
      <TurtleList />
    </div>
  );
}