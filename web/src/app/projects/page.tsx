"use client";

export default function ProjectsPage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Projects</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Project list will be populated dynamically */}
        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">Mining Project</h2>
          <p className="text-sm opacity-75">3 turtles assigned</p>
          <div className="mt-2 flex justify-between">
            <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">Active</span>
            <span className="text-xs">Progress: 45%</span>
          </div>
        </div>

        <div className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer">
          <h2 className="text-xl font-semibold">Construction Project</h2>
          <p className="text-sm opacity-75">2 turtles assigned</p>
          <div className="mt-2 flex justify-between">
            <span className="bg-yellow-100 text-yellow-800 px-2 py-1 rounded text-xs">Paused</span>
            <span className="text-xs">Progress: 23%</span>
          </div>
        </div>

        <a href="/projects/create" className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer border-2 border-dashed border-primary flex items-center justify-center">
          <span className="text-xl">+ Create New Project</span>
        </a>
      </div>
    </div>
  );
}