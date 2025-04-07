/** @type {import('tailwindcss').Config} */
export default {
  content: ['./app/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6', // Blue theme
        secondary: '#10b981', // Green theme
        accent: '#f59e0b', // Orange theme
        danger: '#ef4444', // Red theme
        warning: '#f59e0b', // Yellow theme
        success: '#10b981', // Green theme
        info: '#3b82f6', // Blue theme
      },
      fontFamily: {
        sans: ['var(--font-geist-sans)'],
        mono: ['var(--font-geist-mono)'],
      },
    },
  },
  plugins: [],
}