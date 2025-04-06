# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This project is a modern dashboard system for monitoring, controlling, and orchestrating multiple ComputerCraft turtles. The system consists of:

1. A Node.js WebSocket server (server.js) for communication
2. Lua scripts for turtles (in the /public directory)
3. A React-based web dashboard (in the /web directory)
4. Comprehensive documentation (in the /docs directory)

The goal is to create a scalable system that enables orchestration of multiple turtles to work on large-scale projects through a real-time dashboard interface.

## Documentation
The `/docs` directory contains critical design and specification documents that should be referenced when developing:

- **dashboard-design-manual.md**: Overall design principles and UI concepts
- **dashboard-spec-sheet.md**: Technical specifications and data models
- **turtle-orchestration.md**: Patterns for coordinating multiple turtles
- **computercraft-turtle-api-reference.md**: Reference for the turtle API
- **dashboard-sitemap.md**: Navigation structure of the web application
- **websocket-protocol-specification.md**: Detailed communication protocol

All development should align with these specifications.

## Commands
- Run server: `node server.js` - Starts the WebSocket server on port 1337
- Install dependencies: `pnpm install` - Uses pnpm as package manager
- Start ngrok tunnel: `./start_ngrok.sh` - Exposes local server to the internet

## Development Priorities
1. Enhance WebSocket protocol for richer data exchange
2. Improve turtle status tracking with detailed position and state
3. Build modular dashboard components following the sitemap
4. Implement task and project orchestration systems
5. Add advanced coordination features for multi-turtle operations

## Code Style
- **Lua**: Use camelCase for functions and variables
- **JavaScript/TypeScript**: Use camelCase for variables/functions, PascalCase for classes
- **React Components**: Follow functional component pattern with hooks
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

## WebSocket Protocol
- Use JSON for all communication between turtles and server
- Follow the message schema defined in websocket-protocol-specification.md
- Include proper error handling and reconnection logic
- Implement heartbeat mechanism to track turtle status
- Use type-based message routing
- Include comprehensive status information in updates

## Web Dashboard Architecture
- Use React with TypeScript and Tailwind CSS
- Implement a clean component hierarchy as defined in dashboard-spec-sheet.md
- Use React Context for WebSocket state management
- Build responsive layouts that work across device sizes
- Implement real-time updates for turtle status
- Follow the sitemap defined in dashboard-sitemap.md