export default function PreferencesPage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">User Preferences</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Interface Settings</h2>
          
          <div className="mb-4">
            <label htmlFor="theme" className="block text-sm font-medium mb-1">Theme</label>
            <select 
              id="theme" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
            >
              <option>System Default</option>
              <option>Light</option>
              <option>Dark</option>
            </select>
          </div>
          
          <div className="mb-4">
            <label htmlFor="language" className="block text-sm font-medium mb-1">Language</label>
            <select 
              id="language" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
            >
              <option>English</option>
              <option>Spanish</option>
              <option>French</option>
              <option>German</option>
              <option>Japanese</option>
            </select>
          </div>
          
          <div className="mb-4 flex items-center">
            <input 
              type="checkbox" 
              id="enable-animations" 
              className="mr-2"
              defaultChecked
            />
            <label htmlFor="enable-animations" className="text-sm font-medium">Enable Animations</label>
          </div>
        </div>
        
        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Display Settings</h2>
          
          <div className="mb-4">
            <label htmlFor="grid-size" className="block text-sm font-medium mb-1">Grid Size</label>
            <select 
              id="grid-size" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
            >
              <option>Compact</option>
              <option selected>Medium</option>
              <option>Large</option>
            </select>
          </div>
          
          <div className="mb-4">
            <label htmlFor="turtle-icons" className="block text-sm font-medium mb-1">Turtle Icons</label>
            <select 
              id="turtle-icons" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
            >
              <option>Minimal</option>
              <option selected>Standard</option>
              <option>Detailed</option>
            </select>
          </div>
          
          <div className="mb-4 flex items-center">
            <input 
              type="checkbox" 
              id="show-coordinates" 
              className="mr-2"
              defaultChecked
            />
            <label htmlFor="show-coordinates" className="text-sm font-medium">Show Coordinates</label>
          </div>
          
          <div className="mb-4 flex items-center">
            <input 
              type="checkbox" 
              id="show-fuel-level" 
              className="mr-2"
              defaultChecked
            />
            <label htmlFor="show-fuel-level" className="text-sm font-medium">Show Fuel Level</label>
          </div>
        </div>
      </div>
      
      <div className="mt-4 flex justify-end">
        <button className="bg-primary hover:bg-primary-dark px-4 py-2 rounded text-white">Save Preferences</button>
      </div>
    </div>
  );
}