# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Run server: `node server.js` - Starts the WebSocket server on port 1337
- Install dependencies: `pnpm install` - Uses pnpm as package manager
- Start ngrok tunnel: `./start_ngrok.sh` - Exposes local server to the internet

## Code Style
- **Lua**: Use camelCase for functions and variables
- **JavaScript**: Use camelCase for variables/functions, PascalCase for classes
- **Error Handling**: Always wrap turtle API calls in pcall() for error resilience
- **Block Detection**: Use pattern matching with string.find() for item detection
- **Logging**: Use prefixes like "[fuel]", "[chest]" for better debugging
- **Configuration**: Keep all constants and config values in env.lua

## ComputerCraft Best Practices
- Implement path tracking for reliable turtle navigation
- Add multiple retry attempts for movement operations
- Include sleep delays after digging to handle falling blocks
- Use pattern matching for broader block detection
- Save path state before inventory management operations
- Always check inventory status before starting new operations
- Add detailed logging for troubleshooting
- Use recursive algorithms for efficient ore mining
- Reserve slot 1 for fuel items
- Add walk() functions to handle obstacles during movement

## WebSocket Server Architecture
- Use JSON for all communication between turtles and server
- Include proper error handling and reconnection logic
- Implement heartbeat mechanism to track turtle status