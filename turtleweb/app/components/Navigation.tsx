"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

// Icons as SVG components for better token usage
const HomeIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
    <polyline points="9 22 9 12 15 12 15 22"></polyline>
  </svg>
);

const TurtleIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"></path>
    <circle cx="12" cy="10" r="3"></circle>
  </svg>
);

const ProjectIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
    <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
  </svg>
);

const TaskIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"></path>
    <path d="M9 12v.01"></path>
    <path d="M15 12v.01"></path>
    <path d="M12 9v.01"></path>
    <path d="M12 15v.01"></path>
  </svg>
);

const ProgramIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="m18 16 4-4-4-4"></path>
    <path d="m6 8-4 4 4 4"></path>
    <path d="m14.5 4-5 16"></path>
  </svg>
);

const SettingsIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"></path>
    <circle cx="12" cy="12" r="3"></circle>
  </svg>
);

export default function Navigation() {
  const pathname = usePathname();
  
  const isActive = (path: string) => {
    return pathname?.startsWith(path) ? "active" : "";
  };

  return (
    <div className="dashboard-sidebar">
      <div className="p-4 border-b border-gray-200">
        <h2 className="text-lg font-semibold text-gray-800">Turtle Dashboard</h2>
      </div>
      <nav className="p-2">
        <div className="mb-4">
          <p className="px-4 py-1 text-xs font-medium text-gray-500 uppercase">Main</p>
          <ul className="mt-1 space-y-1">
            <li>
              <Link
                href="/"
                className={`nav-item ${pathname === "/" ? "active" : ""}`}
              >
                <span className="nav-item-icon"><HomeIcon /></span>
                <span>Home</span>
              </Link>
            </li>
            <li>
              <Link
                href="/turtles"
                className={`nav-item ${isActive("/turtles")}`}
              >
                <span className="nav-item-icon"><TurtleIcon /></span>
                <span>Turtles</span>
              </Link>
            </li>
            <li>
              <Link
                href="/projects"
                className={`nav-item ${isActive("/projects")}`}
              >
                <span className="nav-item-icon"><ProjectIcon /></span>
                <span>Projects</span>
              </Link>
            </li>
          </ul>
        </div>
        
        <div className="mb-4">
          <p className="px-4 py-1 text-xs font-medium text-gray-500 uppercase">Operations</p>
          <ul className="mt-1 space-y-1">
            <li>
              <Link
                href="/tasks"
                className={`nav-item ${isActive("/tasks")}`}
              >
                <span className="nav-item-icon"><TaskIcon /></span>
                <span>Tasks</span>
              </Link>
            </li>
            <li>
              <Link
                href="/programs"
                className={`nav-item ${isActive("/programs")}`}
              >
                <span className="nav-item-icon"><ProgramIcon /></span>
                <span>Programs</span>
              </Link>
            </li>
          </ul>
        </div>
        
        <div>
          <p className="px-4 py-1 text-xs font-medium text-gray-500 uppercase">System</p>
          <ul className="mt-1 space-y-1">
            <li>
              <Link
                href="/settings"
                className={`nav-item ${isActive("/settings")}`}
              >
                <span className="nav-item-icon"><SettingsIcon /></span>
                <span>Settings</span>
              </Link>
            </li>
          </ul>
        </div>
      </nav>
    </div>
  );
}