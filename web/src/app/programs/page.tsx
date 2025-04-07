"use client";

export default function ProgramsPage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Program Library</h1>
      
      <div className="flex justify-between mb-4">
        <div>
          <input 
            type="text" 
            className="p-2 border border-gray-300 rounded bg-background"
            placeholder="Search programs"
          />
        </div>
        <a href="/programs/edit/new" className="bg-primary hover:bg-primary-dark px-4 py-2 rounded text-white">
          Create New Program
        </a>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">mining.lua</h2>
          <div className="text-xs mt-1 flex items-center gap-1">
            <span className="bg-blue-100 text-blue-800 px-1 rounded">Lua</span>
            <span>3.2 KB</span>
          </div>
          <p className="text-sm mt-2">Advanced mining program with ore detection</p>
          <div className="mt-2 flex justify-end gap-1">
            <button className="bg-gray-300 hover:bg-gray-400 px-2 py-1 rounded text-xs">Deploy</button>
            <a href="/programs/edit/1" className="bg-primary hover:bg-primary-dark px-2 py-1 rounded text-white text-xs">Edit</a>
          </div>
        </div>

        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">bridge.lua</h2>
          <div className="text-xs mt-1 flex items-center gap-1">
            <span className="bg-blue-100 text-blue-800 px-1 rounded">Lua</span>
            <span>1.8 KB</span>
          </div>
          <p className="text-sm mt-2">Builds bridges across gaps and ravines</p>
          <div className="mt-2 flex justify-end gap-1">
            <button className="bg-gray-300 hover:bg-gray-400 px-2 py-1 rounded text-xs">Deploy</button>
            <a href="/programs/edit/2" className="bg-primary hover:bg-primary-dark px-2 py-1 rounded text-white text-xs">Edit</a>
          </div>
        </div>

        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">farm.lua</h2>
          <div className="text-xs mt-1 flex items-center gap-1">
            <span className="bg-blue-100 text-blue-800 px-1 rounded">Lua</span>
            <span>2.5 KB</span>
          </div>
          <p className="text-sm mt-2">Automated crop farming and harvesting</p>
          <div className="mt-2 flex justify-end gap-1">
            <button className="bg-gray-300 hover:bg-gray-400 px-2 py-1 rounded text-xs">Deploy</button>
            <a href="/programs/edit/3" className="bg-primary hover:bg-primary-dark px-2 py-1 rounded text-white text-xs">Edit</a>
          </div>
        </div>
      </div>
    </div>
  );
}