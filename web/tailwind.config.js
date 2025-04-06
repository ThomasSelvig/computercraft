/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#0052cc', // Darker blue for better contrast
        secondary: '#087f5b', // Darker green for better contrast
        background: '#f8f9fa', // Slightly lighter background
        card: '#ffffff',
        text: '#121212', // Darker text for better contrast
        border: '#d1d5db', // Slightly darker border
        danger: '#dc2626', // Darker red for better contrast
        warning: '#d97706', // Darker orange for better contrast
        success: '#047857', // Darker green for better contrast
      },
      boxShadow: {
        panel: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
      }
    },
  },
  plugins: [],
}