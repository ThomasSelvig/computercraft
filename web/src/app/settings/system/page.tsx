export default function SystemSettingsPage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">System Configuration</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Server Settings</h2>
          
          <div className="mb-4">
            <label htmlFor="server-port" className="block text-sm font-medium mb-1">Server Port</label>
            <input 
              type="text" 
              id="server-port" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
              defaultValue="1337"
            />
          </div>
          
          <div className="mb-4">
            <label htmlFor="log-level" className="block text-sm font-medium mb-1">Log Level</label>
            <select 
              id="log-level" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
            >
              <option>Debug</option>
              <option selected>Info</option>
              <option>Warning</option>
              <option>Error</option>
            </select>
          </div>
          
          <div className="mb-4 flex items-center">
            <input 
              type="checkbox" 
              id="enable-logging" 
              className="mr-2"
              defaultChecked
            />
            <label htmlFor="enable-logging" className="text-sm font-medium">Enable File Logging</label>
          </div>
        </div>
        
        <div className="bg-secondary p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-2">Performance Settings</h2>
          
          <div className="mb-4">
            <label htmlFor="max-connections" className="block text-sm font-medium mb-1">Max Connections</label>
            <input 
              type="number" 
              id="max-connections" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
              defaultValue="50"
            />
          </div>
          
          <div className="mb-4">
            <label htmlFor="update-interval" className="block text-sm font-medium mb-1">Status Update Interval (ms)</label>
            <input 
              type="number" 
              id="update-interval" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
              defaultValue="1000"
            />
          </div>
          
          <div className="mb-4">
            <label htmlFor="heartbeat-timeout" className="block text-sm font-medium mb-1">Heartbeat Timeout (ms)</label>
            <input 
              type="number" 
              id="heartbeat-timeout" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
              defaultValue="5000"
            />
          </div>
        </div>
      </div>
      
      <div className="mt-4 flex justify-end">
        <button className="bg-primary hover:bg-primary-dark px-4 py-2 rounded text-white">Save Settings</button>
      </div>
    </div>
  );
}