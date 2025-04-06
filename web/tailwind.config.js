/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6',
        secondary: '#10b981',
        background: '#f3f4f6',
        card: '#ffffff',
        text: '#1f2937',
        border: '#e5e7eb',
        danger: '#ef4444',
        warning: '#f59e0b',
        success: '#10b981',
      },
      boxShadow: {
        panel: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
      }
    },
  },
  plugins: [],
}