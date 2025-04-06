import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    port: 3000,
    // proxy: {
    //   '/api': {
    //     target: 'http://localhost:1337',
    //     changeOrigin: true,
    //   },
    //   // Direct WebSocket proxy
    //   '/': {
    //     target: 'ws://localhost:1337',
    //     ws: true,
    //     rewrite: (path) => path
    //   }
    // },
    // Allow access through ngrok or other proxies
    hmr: {
      clientPort: 443,
    },
  },
});
