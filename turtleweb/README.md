# TurtleWeb Dashboard

A Next.js-based dashboard for monitoring, controlling, and orchestrating ComputerCraft turtles.

## Sitemap Structure

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

## Routes

- **Home**: `/`
- **Turtles**:
  - List: `/turtles`
  - Details: `/turtles/[id]`
- **Projects**:
  - List: `/projects`
  - Details: `/projects/[id]`
  - Create: `/projects/create`
- **Tasks**:
  - Library: `/tasks`
  - Builder: `/tasks/create`
- **Programs**:
  - Library: `/programs`
  - Editor: `/programs/edit/[id]`
- **Settings**:
  - Main: `/settings`
  - System: `/settings/system`
  - Preferences: `/settings/preferences`
  - WebSocket: `/settings/websocket`

## Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.