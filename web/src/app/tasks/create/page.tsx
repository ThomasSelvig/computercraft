export default function TaskCreatePage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Create New Task</h1>
      
      <form className="bg-secondary p-4 rounded-lg shadow">
        <div className="mb-4">
          <label htmlFor="task-name" className="block text-sm font-medium mb-1">Task Name</label>
          <input 
            type="text" 
            id="task-name" 
            className="w-full p-2 border border-gray-300 rounded bg-background"
            placeholder="Enter task name"
          />
        </div>
        
        <div className="mb-4">
          <label htmlFor="task-description" className="block text-sm font-medium mb-1">Description</label>
          <textarea 
            id="task-description" 
            className="w-full p-2 border border-gray-300 rounded bg-background"
            rows={2}
            placeholder="Enter task description"
          ></textarea>
        </div>
        
        <div className="mb-4">
          <label className="block text-sm font-medium mb-1">Task Type</label>
          <select className="w-full p-2 border border-gray-300 rounded bg-background">
            <option>Standard Task</option>
            <option>Parameterized Task</option>
            <option>Composite Task</option>
          </select>
        </div>
        
        <div className="mb-4">
          <label htmlFor="task-code" className="block text-sm font-medium mb-1">Task Code</label>
          <div className="border border-gray-300 rounded bg-gray-900 text-gray-100 p-2" style={{ fontFamily: 'monospace' }}>
            <pre>
              {`-- Task code goes here
function execute(turtle)
  -- Your Lua code here
  turtle.forward()
  turtle.dig()
  return true
end`}
            </pre>
          </div>
        </div>
        
        <div className="mb-4">
          <label className="block text-sm font-medium mb-1">Parameters</label>
          <div className="border border-gray-300 rounded p-2 bg-background">
            <div className="grid grid-cols-3 gap-2 mb-2">
              <input 
                type="text" 
                className="p-1 border border-gray-300 rounded"
                placeholder="Parameter Name"
              />
              <select className="p-1 border border-gray-300 rounded">
                <option>String</option>
                <option>Number</option>
                <option>Boolean</option>
              </select>
              <input 
                type="text" 
                className="p-1 border border-gray-300 rounded"
                placeholder="Default Value"
              />
            </div>
            <button className="bg-gray-300 hover:bg-gray-400 px-2 py-1 rounded text-xs w-full">
              + Add Parameter
            </button>
          </div>
        </div>
        
        <div className="flex justify-end gap-2">
          <a href="/tasks" className="bg-gray-500 hover:bg-gray-600 px-4 py-2 rounded text-white">Cancel</a>
          <button type="submit" className="bg-primary hover:bg-primary-dark px-4 py-2 rounded text-white">Create Task</button>
        </div>
      </form>
    </div>
  );
}