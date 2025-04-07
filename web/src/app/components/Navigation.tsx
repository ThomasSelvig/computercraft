"use client";

import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function Navigation() {
  const pathname = usePathname();
  
  const isActive = (path: string) => {
    if (path === '/' && pathname === '/') return true;
    if (path !== '/' && pathname?.startsWith(path)) return true;
    return false;
  };
  
  return (
    <nav className="bg-secondary p-2 rounded-lg my-4">
      <ul className="flex flex-wrap gap-2">
        <li>
          <Link 
            href="/" 
            className={`px-4 py-2 rounded ${isActive('/') 
              ? 'bg-primary text-white' 
              : 'hover:bg-gray-200 dark:hover:bg-gray-700'}`}
          >
            Home
          </Link>
        </li>
        <li>
          <Link 
            href="/turtles" 
            className={`px-4 py-2 rounded ${isActive('/turtles') 
              ? 'bg-primary text-white' 
              : 'hover:bg-gray-200 dark:hover:bg-gray-700'}`}
          >
            Turtles
          </Link>
        </li>
        <li>
          <Link 
            href="/projects" 
            className={`px-4 py-2 rounded ${isActive('/projects') 
              ? 'bg-primary text-white' 
              : 'hover:bg-gray-200 dark:hover:bg-gray-700'}`}
          >
            Projects
          </Link>
        </li>
        <li>
          <Link 
            href="/tasks" 
            className={`px-4 py-2 rounded ${isActive('/tasks') 
              ? 'bg-primary text-white' 
              : 'hover:bg-gray-200 dark:hover:bg-gray-700'}`}
          >
            Tasks
          </Link>
        </li>
        <li>
          <Link 
            href="/programs" 
            className={`px-4 py-2 rounded ${isActive('/programs') 
              ? 'bg-primary text-white' 
              : 'hover:bg-gray-200 dark:hover:bg-gray-700'}`}
          >
            Programs
          </Link>
        </li>
        <li>
          <Link 
            href="/settings" 
            className={`px-4 py-2 rounded ${isActive('/settings') 
              ? 'bg-primary text-white' 
              : 'hover:bg-gray-200 dark:hover:bg-gray-700'}`}
          >
            Settings
          </Link>
        </li>
      </ul>
    </nav>
  );
}