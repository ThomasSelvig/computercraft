"use client";

import Link from 'next/link';

export default function SettingsPage() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Settings</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Link 
          href="/settings/system" 
          className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow"
        >
          <h2 className="text-xl font-semibold mb-2">System Configuration</h2>
          <p className="text-sm">Configure server settings, logging, and performance options</p>
        </Link>
        
        <Link 
          href="/settings/preferences" 
          className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow"
        >
          <h2 className="text-xl font-semibold mb-2">User Preferences</h2>
          <p className="text-sm">Customize the interface, display options, and user experience</p>
        </Link>
        
        <Link 
          href="/settings/websocket" 
          className="bg-secondary p-4 rounded-lg shadow hover:shadow-md transition-shadow"
        >
          <h2 className="text-xl font-semibold mb-2">WebSocket Configuration</h2>
          <p className="text-sm">Configure connection settings, security, and status monitoring</p>
        </Link>
      </div>
    </div>
  );
}