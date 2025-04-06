# ComputerCraft Turtle Orchestration System

A modern dashboard system for monitoring, controlling, and orchestrating multiple ComputerCraft turtles. This system consists of a TypeScript WebSocket server and Lua scripts for the turtles.

## Project Structure

```
computercraft/
├── dist/              # Compiled TypeScript code
├── docs/              # Project documentation
├── public/            # Compiled Lua scripts (copied from src/turtle)
├── src/
│   ├── server/        # TypeScript WebSocket server
│   │   ├── types/     # TypeScript type definitions
│   │   └── index.ts   # Main server file
│   └── turtle/        # Lua scripts for turtles
│       ├── lib/       # Turtle library modules
│       ├── tasks/     # Task implementations
│       ├── env.lua    # Environment configuration
│       ├── main.lua   # Main turtle program
│       └── startup.lua # Turtle boot script
├── web/               # Web-based dashboard 
├── package.json       # Node.js dependencies
└── tsconfig.json      # TypeScript configuration
```

## Key Features

- **Modular Architecture**: Separates concerns between positioning, movement, inventory management, and communication
- **WebSocket Protocol**: Implements a robust real-time communication protocol between server and turtles
- **Position Tracking**: Provides accurate position data for turtle coordination
- **Task System**: Supports complex coordinated operations across multiple turtles
- **Error Resilience**: Implements retry logic, timeouts, and connection management
- **TypeScript Server**: Strongly-typed WebSocket server with better maintainability

## Getting Started

1. **Install dependencies**:
   ```
   pnpm install
   ```

2. **Build the project**:
   ```
   pnpm build
   ```

3. **Start the WebSocket server**:
   ```
   pnpm start
   ```

4. **Set up turtles in-game**:
   - Copy the contents of `public/` to your ComputerCraft turtle
   - Make sure to set a unique label for each turtle with `os.setComputerLabel("TurtleName")`
   - Update the `env.lua` file with your server's IP address

## Development

1. **Run the server in development mode**:
   ```
   pnpm dev
   ```

2. **Test turtles in-game**:
   - Connect to the WebSocket server
   - Send commands via debug client

## Documentation

For details on the WebSocket protocol, turtle orchestration patterns, and system architecture, see the documentation in the `docs/` directory.

## Original Quarry Program Reference
quarry: https://pastebin.com/wGuCnq6f