"use client";

export default function TasksPage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Task Library</h1>
      
      <div className="flex justify-between mb-4">
        <div>
          <input 
            type="text" 
            className="p-2 border border-gray-300 rounded bg-background"
            placeholder="Search tasks"
          />
        </div>
        <a href="/tasks/create" className="bg-primary hover:bg-primary-dark px-4 py-2 rounded text-white">
          Create New Task
        </a>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">Mining Task</h2>
          <p className="text-sm mt-1">Excavates a specified area layer by layer</p>
          <div className="mt-2 flex justify-between items-center">
            <span className="text-xs opacity-75">Used 24 times</span>
            <button className="bg-primary hover:bg-primary-dark px-2 py-1 rounded text-white text-xs">Run</button>
          </div>
        </div>

        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">Tunnel Task</h2>
          <p className="text-sm mt-1">Creates a straight tunnel with optional branching</p>
          <div className="mt-2 flex justify-between items-center">
            <span className="text-xs opacity-75">Used 18 times</span>
            <button className="bg-primary hover:bg-primary-dark px-2 py-1 rounded text-white text-xs">Run</button>
          </div>
        </div>

        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">Tree Farm Task</h2>
          <p className="text-sm mt-1">Plants and harvests trees in a designated area</p>
          <div className="mt-2 flex justify-between items-center">
            <span className="text-xs opacity-75">Used 12 times</span>
            <button className="bg-primary hover:bg-primary-dark px-2 py-1 rounded text-white text-xs">Run</button>
          </div>
        </div>
      </div>
    </div>
  );
}