export default function ProjectDetailsPage({ params }: { params: { id: string } }) {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Project Details</h1>
      
      <div className="bg-secondary p-4 rounded-lg shadow mb-4">
        <h2 className="text-xl font-semibold mb-2">Project #{params.id}</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <h3 className="font-medium">Status</h3>
            <p>Active</p>
            <h3 className="font-medium mt-2">Progress</h3>
            <div className="w-full bg-background rounded-full h-2.5 my-2">
              <div className="bg-primary h-2.5 rounded-full" style={{ width: '45%' }}></div>
            </div>
            <p>45% Complete</p>
          </div>
          <div>
            <h3 className="font-medium">Assigned Turtles</h3>
            <ul className="list-disc list-inside">
              <li>Turtle #1</li>
              <li>Turtle #2</li>
              <li>Turtle #3</li>
            </ul>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Tasks</h2>
          <ul className="divide-y">
            <li className="py-2 flex justify-between">
              <span>Mining Task #1</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">Complete</span>
            </li>
            <li className="py-2 flex justify-between">
              <span>Mining Task #2</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs">In Progress</span>
            </li>
            <li className="py-2 flex justify-between">
              <span>Mining Task #3</span>
              <span className="bg-gray-100 text-gray-800 px-2 py-1 rounded text-xs">Queued</span>
            </li>
          </ul>
        </div>

        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Activity Log</h2>
          <ul className="divide-y">
            <li className="py-2">
              <div className="text-sm">Turtle #1 completed Mining Task #1</div>
              <div className="text-xs opacity-75">10 minutes ago</div>
            </li>
            <li className="py-2">
              <div className="text-sm">Turtle #2 started Mining Task #2</div>
              <div className="text-xs opacity-75">15 minutes ago</div>
            </li>
            <li className="py-2">
              <div className="text-sm">Project started</div>
              <div className="text-xs opacity-75">30 minutes ago</div>
            </li>
          </ul>
        </div>
      </div>

      <div className="mt-4 flex justify-end gap-2">
        <button className="bg-yellow-500 hover:bg-yellow-600 px-4 py-2 rounded text-white">Pause Project</button>
        <button className="bg-red-500 hover:bg-red-600 px-4 py-2 rounded text-white">Cancel Project</button>
      </div>
    </div>
  );
}