# CLAUDE.md - Token-Efficient Style Guide

## Project Overview
A modern dashboard system for ComputerCraft turtles with:
1. Node.js WebSocket server for communication
2. Lua scripts for turtles
3. Next.js React dashboard
4. Real-time orchestration capabilities

## Core Guidelines

### Code Style
- JS/TS: camelCase for variables/functions, PascalCase for components
- React: functional components with hooks
- Error handling: Always wrap turtle operations in pcall()
- Config: Keep constants in env.lua
- Prefix logs with context: [fuel], [position], etc.

### Dashboard Architecture
- React + TypeScript + Tailwind CSS
- WebSocket Context for state management
- Responsive layouts
- Follow component hierarchy in dashboard-spec-sheet.md
- Implement real-time updates

### WebSocket Protocol
- JSON messages with type-based routing
- Include heartbeat mechanism
- Implement reconnection logic
- Follow message schemas in websocket-protocol-specification.md

### Turtle Best Practices
- Implement path tracking
- Multiple retry attempts for movement
- Add sleep delays after digging (falling blocks)
- Check inventory before operations
- Reserve slot 1 for fuel
- Use pattern matching for block detection

### Components
- Header: Logo, status indicators, navigation
- TurtleList: Sortable/filterable, status indicators
- ControlPanel: Movement, inventory, task controls
- CommandHistory: Record of commands and responses

### Orchestration Patterns
- Centralized: Dashboard controls all turtles directly
- Decentralized: Turtles run autonomous programs
- Hybrid (recommended): Central coordination with local execution
- Support swarm, mining, factory, farming patterns