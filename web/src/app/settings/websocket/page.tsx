export default function WebSocketConfigPage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">WebSocket Configuration</h1>
      
      <div className="bg-secondary p-4 rounded-lg shadow mb-4">
        <h2 className="text-xl font-semibold mb-2">Connection Settings</h2>
        
        <div className="mb-4">
          <label htmlFor="websocket-url" className="block text-sm font-medium mb-1">WebSocket URL</label>
          <input 
            type="text" 
            id="websocket-url" 
            className="w-full p-2 border border-gray-300 rounded bg-background"
            defaultValue="ws://localhost:1337"
          />
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label htmlFor="reconnect-attempts" className="block text-sm font-medium mb-1">Reconnect Attempts</label>
            <input 
              type="number" 
              id="reconnect-attempts" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
              defaultValue="5"
            />
          </div>
          
          <div>
            <label htmlFor="reconnect-interval" className="block text-sm font-medium mb-1">Reconnect Interval (ms)</label>
            <input 
              type="number" 
              id="reconnect-interval" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
              defaultValue="2000"
            />
          </div>
        </div>
        
        <div className="mt-4 flex items-center gap-4">
          <div className="flex items-center">
            <input 
              type="checkbox" 
              id="auto-reconnect" 
              className="mr-2"
              defaultChecked
            />
            <label htmlFor="auto-reconnect" className="text-sm font-medium">Auto Reconnect</label>
          </div>
          
          <div className="flex items-center">
            <input 
              type="checkbox" 
              id="use-compression" 
              className="mr-2"
            />
            <label htmlFor="use-compression" className="text-sm font-medium">Use Compression</label>
          </div>
        </div>
      </div>
      
      <div className="bg-secondary p-4 rounded-lg shadow mb-4">
        <h2 className="text-xl font-semibold mb-2">Security</h2>
        
        <div className="mb-4">
          <label htmlFor="auth-token" className="block text-sm font-medium mb-1">Authentication Token</label>
          <input 
            type="password" 
            id="auth-token" 
            className="w-full p-2 border border-gray-300 rounded bg-background"
            placeholder="Enter authentication token"
          />
        </div>
        
        <div className="mb-4 flex items-center">
          <input 
            type="checkbox" 
            id="use-ssl" 
            className="mr-2"
          />
          <label htmlFor="use-ssl" className="text-sm font-medium">Use SSL/TLS (wss://)</label>
        </div>
      </div>
      
      <div className="bg-secondary p-4 rounded-lg shadow mb-4">
        <h2 className="text-xl font-semibold mb-2">Connection Status</h2>
        
        <div className="p-4 bg-background rounded">
          <div className="flex items-center mb-2">
            <div className="w-3 h-3 rounded-full bg-green-500 mr-2"></div>
            <span className="font-medium">Connected</span>
          </div>
          
          <div className="grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
            <div>
              <span className="font-medium">Server:</span> ws://localhost:1337
            </div>
            <div>
              <span className="font-medium">Latency:</span> 12ms
            </div>
            <div>
              <span className="font-medium">Connected Since:</span> 10:23 AM
            </div>
            <div>
              <span className="font-medium">Messages Sent:</span> 132
            </div>
            <div>
              <span className="font-medium">Messages Received:</span> 156
            </div>
            <div>
              <span className="font-medium">Last Heartbeat:</span> 10:45 AM
            </div>
          </div>
        </div>
      </div>
      
      <div className="mt-4 flex justify-end gap-2">
        <button className="bg-blue-500 hover:bg-blue-600 px-4 py-2 rounded text-white">Test Connection</button>
        <button className="bg-red-500 hover:bg-red-600 px-4 py-2 rounded text-white">Disconnect</button>
        <button className="bg-primary hover:bg-primary-dark px-4 py-2 rounded text-white">Save Configuration</button>
      </div>
    </div>
  );
}