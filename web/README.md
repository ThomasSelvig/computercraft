# ComputerCraft Turtle Control Dashboard

This web application provides a monitoring and control interface for ComputerCraft turtles using WebSockets.

## Features

- Real-time turtle status monitoring
- Control interface for sending commands to turtles
- Support for individual turtle or group command execution
- Command history and response tracking
- Inventory and fuel level visualization

## Architecture

The dashboard connects to the WebSocket server running on the same host and provides a user-friendly interface for monitoring and controlling turtles in the ComputerCraft environment.

- **WebSocket Connection**: Automatically connects to the WebSocket server and registers as a debug client
- **Turtle Monitoring**: Displays all connected turtles with their status and last seen time
- **Command Interface**: Provides UI for executing common turtle commands
- **Response Tracking**: Shows command execution results with success/failure status

## Development

This project is built with:

- React
- TypeScript
- Vite

### Getting Started

1. Install dependencies:
   ```
   pnpm install
   ```

2. Start the development server:
   ```
   pnpm dev
   ```

3. Build for production:
   ```
   pnpm build
   ```

### WebSocket Communication

The dashboard communicates with the server using the following message formats:

1. **Registration Message**:
   ```json
   {
     "type": "register",
     "debugClient": true
   }
   ```

2. **Command Message**:
   ```json
   {
     "type": "command",
     "target": "TURTLE_NAME or all",
     "action": "COMMAND_NAME",
     "params": {
       // Command-specific parameters
     }
   }
   ```

3. **Server Messages**:
   - `turtleUpdate`: Updates the list of connected turtles
   - `commandResponse`: Contains the result of a command execution

## Deployment

The dashboard is designed to be served by the Node.js server in the parent directory. After building, the files will be available in the `dist` directory and can be served as static assets.