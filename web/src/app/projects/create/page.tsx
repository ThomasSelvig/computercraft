export default function ProjectCreatePage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Create New Project</h1>
      
      <form className="bg-secondary p-4 rounded-lg shadow">
        <div className="mb-4">
          <label htmlFor="project-name" className="block text-sm font-medium mb-1">Project Name</label>
          <input 
            type="text" 
            id="project-name" 
            className="w-full p-2 border border-gray-300 rounded bg-background"
            placeholder="Enter project name"
          />
        </div>
        
        <div className="mb-4">
          <label htmlFor="project-description" className="block text-sm font-medium mb-1">Description</label>
          <textarea 
            id="project-description" 
            className="w-full p-2 border border-gray-300 rounded bg-background"
            rows={4}
            placeholder="Enter project description"
          ></textarea>
        </div>
        
        <div className="mb-4">
          <label className="block text-sm font-medium mb-1">Project Type</label>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
            <div className="border border-gray-300 rounded p-3 cursor-pointer hover:bg-primary hover:text-white">
              <h3 className="font-medium">Mining</h3>
              <p className="text-xs">Excavate an area for resources</p>
            </div>
            <div className="border border-gray-300 rounded p-3 cursor-pointer hover:bg-primary hover:text-white">
              <h3 className="font-medium">Construction</h3>
              <p className="text-xs">Build structures from blueprints</p>
            </div>
            <div className="border border-gray-300 rounded p-3 cursor-pointer hover:bg-primary hover:text-white">
              <h3 className="font-medium">Farming</h3>
              <p className="text-xs">Manage and harvest crops</p>
            </div>
          </div>
        </div>
        
        <div className="mb-4">
          <label className="block text-sm font-medium mb-1">Assign Turtles</label>
          <div className="border border-gray-300 rounded bg-background p-2">
            <div className="flex flex-wrap gap-2">
              <div className="bg-primary text-white px-2 py-1 rounded text-sm flex items-center">
                Turtle #1
                <button className="ml-2 text-xs">&times;</button>
              </div>
              <div className="bg-primary text-white px-2 py-1 rounded text-sm flex items-center">
                Turtle #2
                <button className="ml-2 text-xs">&times;</button>
              </div>
            </div>
            <input 
              type="text" 
              className="w-full p-2 border-t border-gray-300 mt-2 bg-background"
              placeholder="Search for turtles to add"
            />
          </div>
        </div>
        
        <div className="flex justify-end gap-2">
          <a href="/projects" className="bg-gray-500 hover:bg-gray-600 px-4 py-2 rounded text-white">Cancel</a>
          <button type="submit" className="bg-primary hover:bg-primary-dark px-4 py-2 rounded text-white">Create Project</button>
        </div>
      </form>
    </div>
  );
}