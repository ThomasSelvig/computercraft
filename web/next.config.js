/** @type {import('next').NextConfig} */
const nextConfig = {
  // Turn off React strict mode for now as we migrate to Next.js
  reactStrictMode: false,

  // Configure trailing slash to match our routing
  trailingSlash: false,

  // For production builds, optimize images
  images: {
    domains: ["localhost"],
    unoptimized: process.env.NODE_ENV !== "production",
  },

  // For development, allow WebSocket connections
  // async rewrites() {
  //   return [
  //     {
  //       source: '/api/ws',
  //       destination: 'ws://localhost:1337',
  //     },
  //   ];
  // },

  // Add environment variables
  env: {
    WEBSOCKET_URL: process.env.WEBSOCKET_URL || "ws://localhost:1337",
  },
};

module.exports = nextConfig;
