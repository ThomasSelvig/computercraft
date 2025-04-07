import Link from "next/link";

export default function Settings() {
  return (
    <div className="dashboard-content">
      <h1 className="text-2xl font-bold mb-6">Settings</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Link href="/settings/system" className="card hover:shadow-md transition-shadow">
          <div className="card-header">System Configuration</div>
          <div className="card-body">
            <p>Configure system-wide settings including server connections and performance parameters</p>
          </div>
        </Link>
        <Link href="/settings/preferences" className="card hover:shadow-md transition-shadow">
          <div className="card-header">User Preferences</div>
          <div className="card-body">
            <p>Personalize the dashboard experience with themes, layouts and notification preferences</p>
          </div>
        </Link>
        <Link href="/settings/websocket" className="card hover:shadow-md transition-shadow">
          <div className="card-header">WebSocket Configuration</div>
          <div className="card-body">
            <p>Configure WebSocket connection details for communicating with turtles</p>
          </div>
        </Link>
      </div>
    </div>
  );
}