# ComputerCraft Turtle Dashboard Sitemap

## Overview

This sitemap outlines the structure and navigation flow of the ComputerCraft Turtle Dashboard web application, designed to provide a comprehensive interface for monitoring, controlling, and orchestrating multiple ComputerCraft turtles in real-time.

## Main Sections

```
Dashboard Root
├── Home (Fleet Overview)
├── Turtles
│   ├── Turtle List
│   └── Turtle Details
├── Projects
│   ├── Project List
│   ├── Project Details
│   └── Project Creator
├── Tasks
│   ├── Task Library
│   └── Task Builder
├── Programs
│   ├── Program Library
│   └── Code Editor
└── Settings
    ├── System Configuration
    ├── User Preferences
    └── WebSocket Configuration
```

## Page Descriptions

### Home (Fleet Overview)

**URL:** `/`

The central hub displaying the overall status of the turtle fleet and active operations.

**Components:**
- Real-time turtle status summary
- Active projects and tasks widgets
- System health indicators
- Event stream/activity log
- Quick action panel
- Optional map visualization

**User Actions:**
- Monitor overall system status
- View active operations at a glance
- Access quick commands for fleet-wide operations
- Navigate to specific turtles or projects

### Turtles Section

#### Turtle List

**URL:** `/turtles`

A comprehensive list of all turtles registered in the system.

**Components:**
- Sortable/filterable turtle list with key metrics
- Grouping controls
- Batch selection tools
- Status indicators
- Quick action buttons

**User Actions:**
- View all turtles in the system
- Filter/sort turtles by various properties
- Select multiple turtles for batch operations
- Navigate to individual turtle details
- Perform quick actions on selected turtles

#### Turtle Details

**URL:** `/turtles/:id`

Detailed view for a specific turtle showing comprehensive status and controls.

**Components:**
- Full status display (fuel, inventory, position, etc.)
- Direct command interface
- Status history graphs
- Movement control pad
- Command history
- Task queue

**User Actions:**
- Monitor detailed turtle status
- Send direct commands
- Control movement manually
- View command and event history
- Assign tasks to the turtle
- View/edit turtle properties

### Projects Section

#### Project List

**URL:** `/projects`

Overview of all defined projects, both active and archived.

**Components:**
- Sortable/filterable project list
- Status indicators
- Progress tracking
- Quick actions

**User Actions:**
- Browse all projects
- Filter projects by status, type, etc.
- Create new projects
- Navigate to project details
- Archive/delete projects

#### Project Details

**URL:** `/projects/:id`

Comprehensive view of a specific project with status and control options.

**Components:**
- Project metadata and description
- Task breakdown
- Gantt chart or similar visualization
- Assigned turtles list
- Progress tracking
- Resource consumption metrics

**User Actions:**
- Monitor project progress
- Manage tasks within the project
- Assign/remove turtles
- Pause/resume project
- Edit project parameters
- View logs and events

#### Project Creator

**URL:** `/projects/create`

Interface for defining new multi-turtle projects.

**Components:**
- Project metadata form
- Task sequencing interface
- Blueprint uploader/visualizer
- Resource calculator
- Turtle assignment interface

**User Actions:**
- Define project parameters
- Add and sequence tasks
- Upload building blueprints
- Calculate resource requirements
- Assign turtles to the project
- Save or start the project

### Tasks Section

#### Task Library

**URL:** `/tasks`

Collection of predefined tasks that can be assigned to turtles.

**Components:**
- Task category browser
- Search function
- Task cards with details
- Usage statistics

**User Actions:**
- Browse task categories
- Search for specific tasks
- View task details
- Assign tasks directly to turtles
- Create task templates from existing tasks

#### Task Builder

**URL:** `/tasks/create`

Interface for creating new task definitions.

**Components:**
- Task parameters form
- Command sequence builder
- Testing interface
- Parameter validation
- Template options

**User Actions:**
- Define task parameters
- Build command sequences
- Test tasks on selected turtles
- Save tasks to the library
- Create templates for future use

### Programs Section

#### Program Library

**URL:** `/programs`

Repository of Lua programs that can be deployed to turtles.

**Components:**
- Program category browser
- Search function
- Version history
- Usage statistics
- Deployment tools

**User Actions:**
- Browse program categories
- Search for specific programs
- View program details and code
- Deploy programs to turtles
- Track version history

#### Code Editor

**URL:** `/programs/edit/:id`

Full-featured editor for creating or modifying Lua programs.

**Components:**
- Syntax-highlighted code editor
- Function library sidebar
- API reference
- Validation tools
- Deployment interface

**User Actions:**
- Edit Lua code with syntax highlighting
- Access function libraries
- Validate code before deployment
- Deploy to test or production turtles
- Save versions and track changes

### Settings Section

#### System Configuration

**URL:** `/settings/system`

Global configuration options for the dashboard system.

**Components:**
- WebSocket server settings
- Persistence options
- Performance tuning
- Logging configuration
- System maintenance tools

**User Actions:**
- Configure system-wide settings
- Manage server connections
- Adjust performance parameters
- Configure logging levels
- Perform system maintenance

#### User Preferences

**URL:** `/settings/preferences`

User-specific settings and preferences.

**Components:**
- Theme selection
- Dashboard layout options
- Notification preferences
- Default views configuration
- Keyboard shortcuts

**User Actions:**
- Personalize the dashboard experience
- Configure display preferences
- Set notification options
- Define default views
- Customize keyboard shortcuts

#### WebSocket Configuration

**URL:** `/settings/websocket`

Detailed configuration for the WebSocket connection to turtles.

**Components:**
- Connection parameters
- Protocol settings
- Authentication options
- Heartbeat configuration
- Connection testing tools

**User Actions:**
- Configure WebSocket connection details
- Set protocol parameters
- Manage authentication
- Configure heartbeat behavior
- Test connections to turtles

## Navigation Flows

### Primary User Flows

1. **Turtle Control Flow**
   - Home → Turtle List → Turtle Details → Send Command/Assign Task

2. **Project Management Flow**
   - Home → Project List → Project Details → Monitor Progress/Adjust Parameters

3. **Programming Flow**
   - Programs → Program Library → Code Editor → Deploy Program

4. **Task Creation Flow**
   - Tasks → Task Builder → Create Task → Task Library → Assign to Turtle/Project

5. **Fleet Orchestration Flow**
   - Home → Turtle List (multi-select) → Assign Task/Project → Monitor Execution

### Secondary User Flows

1. **Turtle Registration Flow**
   - Turtles → Add New Turtle → Configure → Deploy Connection Program

2. **System Maintenance Flow**
   - Settings → System Configuration → Adjust Parameters → Apply Changes

3. **Blueprint Execution Flow**
   - Projects → Create Project → Upload Blueprint → Configure Parameters → Assign Turtles → Start Project

4. **Troubleshooting Flow**
   - Home → Event Log → Identify Issue → Turtle Details → Send Recovery Commands

## Mobile Navigation Considerations

For tablet and mobile views, the sitemap adapts with:

1. **Collapsible Navigation**
   - Primary sections collapse to icons
   - Secondary navigation uses dropdown menus

2. **Priority Views**
   - Fleet overview and status indicators remain prominent
   - Control interfaces adapted for touch input
   - Complex visualizations simplified or paginated

3. **Limited Functionality**
   - Advanced editing functions may be view-only
   - Complex orchestration reserved for desktop view
   - Direct controls and monitoring prioritized