# ComputerCraft Turtle Dashboard Technical Specification

## System Architecture

### Client-Side Architecture

- **Framework**: React with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **State Management**: React Context API with WebSocket Provider (move to Zustand as fast as possible)
- **Routing**: Next.js App Router

### Server-Side Architecture

- **Server**: Node.js with native WebSocket support
- **Protocol**: Custom JSON-based WebSocket protocol
- **Persistence**: File-based storage (to be implemented)
- **Authentication**: Basic authentication (future enhancement)

### Communication Protocol

- **Connection**: WebSocket with heartbeat mechanism
- **Message Format**: JSON with type-based routing
- **Event System**: Pub/sub pattern for turtle events
- **Command Interface**: Structured command objects with validation

## Core Components

### WebSocket Provider

```typescript
interface WebSocketContextType {
  connected: boolean;
  turtles: Record<string, TurtleData>;
  selectedTurtle: string | null;
  commandHistory: Command[];
  sendCommand: (command: string) => void;
  selectTurtle: (id: string) => void;
  // New methods for orchestration
  selectMultipleTurtles: (ids: string[]) => void;
  broadcastCommand: (command: string, targetIds?: string[]) => void;
  assignTask: (taskId: string, turtleIds: string[]) => void;
}
```

### Turtle Data Model

```typescript
interface TurtleData {
  id: string;
  label: string;
  status: "active" | "idle" | "error" | "offline";
  position: {
    x: number;
    y: number;
    z: number;
    heading: "north" | "east" | "south" | "west";
  };
  fuel: {
    level: number;
    max: number;
  };
  inventory: InventorySlot[];
  currentTask: string | null;
  errorMessage?: string;
  lastUpdated: number;
  groups: string[];
}

interface InventorySlot {
  index: number;
  name: string;
  count: number;
  metadata?: Record<string, any>;
}
```

### Command Interface

```typescript
interface Command {
  id: string;
  timestamp: number;
  turtleId: string;
  type: string;
  payload: any;
  status: "pending" | "success" | "error";
  response?: any;
  error?: string;
}
```

### Task & Project Models

```typescript
interface Task {
  id: string;
  name: string;
  description: string;
  type: "movement" | "building" | "mining" | "inventory" | "custom";
  commands: string[];
  parameters: Record<string, any>;
  dependencies: string[];
  estimatedDuration: number;
  status: "pending" | "in_progress" | "completed" | "failed";
  assignedTurtles: string[];
}

interface Project {
  id: string;
  name: string;
  description: string;
  tasks: Task[];
  status: "planning" | "in_progress" | "completed" | "on_hold";
  progress: number;
  startTime?: number;
  endTime?: number;
}
```

## UI Components Specification

### Header Component

- Project title/logo
- Global connection status indicator
- User settings menu (future)
- Dark/light mode toggle

### TurtleList Component

**Enhanced Features:**

- Sortable by ID, status, fuel level, etc.
- Grouping functionality
- Multi-select capability
- Status indicators with tooltips
- Quick action buttons
- Search/filter by turtle properties

### TurtleDetail Component

- Full turtle status display
- Command history specific to turtle
- Inventory visualization
- 3D model view (future enhancement)
- Task queue visualization
- Real-time status updates

### ControlPanel Component

**Enhanced Features:**

- Tabbed interface for different control categories
  - Movement
  - Interaction (dig, place)
  - Inventory
  - Programs
  - Tasks
- Command builder with parameter validation
- Saved command sequences
- Context-aware controls based on turtle status

### ProjectManager Component

- Project list view
- Project details with task breakdown
- Gantt-style task visualization
- Turtle assignment interface
- Progress tracking with visual indicators
- Critical path highlighting

### TaskBuilder Component

- Drag-and-drop task sequence builder
- Parameter configuration UI
- Task template library
- Validation for turtle capabilities
- Estimated resource calculation

### MapVisualization Component

- 2D/3D toggle
- Zoom and pan controls
- Turtle position markers
- Task visualization overlays
- Region selection for task assignment
- Coordinates display
- Blocks/structures visualization (optional)

### CommandHistory Component

**Enhanced Features:**

- Filterable by command type
- Groupable by turtle
- Expandable command details
- Reusable command patterns
- Export/share functionality

### CodeEditor Component

- Syntax highlighting for Lua
- Auto-completion (future)
- Error checking
- Deploy button with target selection
- Version history
- Template insertion

## WebSocket Protocol Specification

### Connection Establishment

1. Client connects to server WebSocket endpoint
2. Server acknowledges connection
3. Client requests turtle registry
4. Server sends current turtle status for all turtles
5. Heartbeat mechanism initiates

### Message Types

#### Client to Server Messages

```typescript
interface ClientMessage {
  type:
    | "command"
    | "select"
    | "requestRegistry"
    | "heartbeat"
    | "assignTask"
    | "createProject";
  turtleId?: string;
  payload?: any;
}
```

#### Server to Client Messages

```typescript
interface ServerMessage {
  type:
    | "status"
    | "registry"
    | "commandResponse"
    | "error"
    | "heartbeat"
    | "taskUpdate"
    | "projectUpdate";
  turtleId?: string;
  payload?: any;
}
```

### Event System

```typescript
interface TurtleEvent {
  type:
    | "statusChange"
    | "positionUpdate"
    | "inventoryChange"
    | "fuelUpdate"
    | "taskProgress"
    | "error";
  turtleId: string;
  timestamp: number;
  data: any;
}
```

## Orchestration System Specification

### Task Queue Management

- Per-turtle task queues
- Global orchestration queue
- Priority-based execution
- Dependency resolution
- Failure handling and retry policies

### Coordination Patterns

- **Swarm Pattern**: Multiple turtles executing the same task in different areas
- **Assembly Line Pattern**: Turtles performing sequential operations on the same project
- **Leader-Follower Pattern**: One turtle directs movements, others follow
- **Zone Assignment**: Partitioning work areas among multiple turtles
- **Resource Pooling**: Shared inventory management across turtle fleet

### Automatic Optimization

- Path finding and collision avoidance
- Work distribution based on turtle proximity
- Fuel optimization
- Task parallelization where possible
- Deadlock detection and resolution

## Performance Considerations

- WebSocket message batching for high-frequency updates
- Efficient diff-based updates for turtle status
- Pagination for history and logs
- Progressive loading for large projects
- Client-side caching of static data
- Throttling for UI updates to prevent render thrashing

## Security Considerations

- Input validation for all commands
- Rate limiting for command requests
- Authentication for WebSocket connections (future)
- Permissions system for turtle control (future)
- Sanitization of all displayed data

## Deployment and Distribution

- Containerized deployment option (Docker)
- Configuration via environment variables
- Static file hosting for client
- WebSocket server configuration
- Persistent data storage options

## Future Enhancements

- Multi-user support with permissions
- 3D visualization of turtle environments
- Advanced pathfinding algorithms
- Blueprint import/export
- Integration with external mapping tools
- Machine learning for task optimization
- Mobile companion app
