"use client";

import ConnectionStatus from './ConnectionStatus';

const Header = () => {
  return (
    <header className="bg-white border-b border-gray-200 px-6 py-3 flex justify-between items-center">
      <div className="flex items-center">
        <h1 className="text-xl font-semibold text-gray-900">Dashboard</h1>
      </div>
      <div className="flex items-center space-x-4">
        <div className="text-sm text-gray-500">
          {new Date().toLocaleDateString()}
        </div>
        <ConnectionStatus />
      </div>
    </header>
  );
};

export default Header;