# ComputerCraft Turtle API Reference

This document provides an organized reference of the ComputerCraft Turtle API functions available for programming turtles in Lua.

## Movement Functions

- `turtle.forward()` - Move the turtle forward one block
- `turtle.back()` - Move the turtle backward one block
- `turtle.up()` - Move the turtle up one block
- `turtle.down()` - Move the turtle down one block
- `turtle.turnLeft()` - Rotate the turtle 90 degrees to the left
- `turtle.turnRight()` - Rotate the turtle 90 degrees to the right

## Detection Functions

- `turtle.detect()` - Detect if there is a block in front of the turtle
- `turtle.detectUp()` - Detect if there is a block above the turtle
- `turtle.detectDown()` - Detect if there is a block below the turtle
- `turtle.inspect()` - Get information about the block in front of the turtle
- `turtle.inspectUp()` - Get information about the block above the turtle
- `turtle.inspectDown()` - Get information about the block below the turtle
- `turtle.compare()` - Compare the block in front with the selected inventory slot
- `turtle.compareUp()` - Compare the block above with the selected inventory slot
- `turtle.compareDown()` - Compare the block below with the selected inventory slot

## Interaction Functions

- `turtle.dig()` - Break the block in front of the turtle
- `turtle.digUp()` - Break the block above the turtle
- `turtle.digDown()` - Break the block below the turtle
- `turtle.place()` - Place a block from the selected slot in front of the turtle
- `turtle.placeUp()` - Place a block from the selected slot above the turtle
- `turtle.placeDown()` - Place a block from the selected slot below the turtle
- `turtle.attack()` - Attack an entity in front of the turtle
- `turtle.attackUp()` - Attack an entity above the turtle
- `turtle.attackDown()` - Attack an entity below the turtle
- `turtle.suck()` - Pick up an item in front of the turtle
- `turtle.suckUp()` - Pick up an item above the turtle
- `turtle.suckDown()` - Pick up an item below the turtle
- `turtle.drop()` - Drop an item from the selected slot in front of the turtle
- `turtle.dropUp()` - Drop an item from the selected slot above the turtle
- `turtle.dropDown()` - Drop an item from the selected slot below the turtle

## Inventory Functions

- `turtle.getItemCount([slot])` - Get the number of items in the specified slot
- `turtle.getItemSpace([slot])` - Get the remaining space in the specified slot
- `turtle.getSelectedSlot()` - Get the currently selected slot number
- `turtle.select(slot)` - Select the specified inventory slot
- `turtle.transferTo(slot, [count])` - Move items from selected slot to another slot
- `turtle.compareTo(slot)` - Compare selected slot with another inventory slot
- `turtle.craft([count])` - Craft items using the items in the turtle's inventory
- `turtle.getItemDetail([slot])` - Get detailed information about items in a slot

## Equipment Functions

- `turtle.equipLeft()` - Equip an item from the selected slot to the left side
- `turtle.equipRight()` - Equip an item from the selected slot to the right side
- `turtle.getEquippedLeft()` - Get information about the item equipped on the left side
- `turtle.getEquippedRight()` - Get information about the item equipped on the right side

## Fuel Functions

- `turtle.getFuelLevel()` - Get the current fuel level
- `turtle.getFuelLimit()` - Get the maximum fuel level
- `turtle.refuel([count])` - Refuel the turtle using fuel items in the selected slot

## Related ComputerCraft APIs

### OS Functions

- `os.getComputerID()` - Get the ID of the current computer/turtle
- `os.getComputerLabel()` - Get the label of the current computer/turtle
- `os.setComputerLabel(label)` - Set the label of the current computer/turtle
- `os.time()` - Get the current in-game time. use `os.clock()` for time specific operations instead.
- `os.sleep(seconds)` - Pause execution for the specified number of seconds

### File System Functions

- `fs.open(path, mode)` - Open a file
- `fs.list(path)` - List files in a directory
- `fs.exists(path)` - Check if a file exists
- `fs.isDir(path)` - Check if path is a directory
- `fs.makeDir(path)` - Create a directory

### Redstone Functions

- `redstone.getInput(side)` - Get redstone input level from a specific side
- `redstone.setOutput(side, value)` - Set redstone output level on a specific side

### HTTP Functions (requires HTTP API enabled)

- `http.get(url)` - Perform an HTTP GET request
- `http.post(url, data)` - Perform an HTTP POST request
- `http.websocket(url)` - Open a WebSocket connection

## WebSocket Integration

WebSockets are particularly important for real-time communication between turtles and external systems like dashboards. Key functions:

- `http.websocket(url)` - Opens a WebSocket connection to the specified URL
- `websocket.send(message)` - Sends a message through the WebSocket
- `websocket.receive([timeout])` - Receives a message from the WebSocket
- `websocket.close()` - Closes the WebSocket connection

## Event Handling for WebSockets

When working with WebSockets, handling the following events is important:

- `websocket_success` - Triggered when a WebSocket connection is successfully established
- `websocket_message` - Triggered when a message is received through the WebSocket
- `websocket_closed` - Triggered when a WebSocket connection is closed
- `websocket_failure` - Triggered when a WebSocket connection fails to establish

## Useful Patterns and Best Practices

### Error-Resilient Turtle Movement

```lua
function safeForward()
  local success, error = pcall(function()
    if turtle.detect() then
      turtle.dig()
      os.sleep(0.5) -- Wait for falling blocks
      if turtle.detect() then
        return false -- Still blocked (might be an entity)
      end
    end
    return turtle.forward()
  end)

  if not success then
    print("[movement] Error: " .. error)
    return false
  end

  return success
end
```

### Pattern-Based Block Detection

```lua
function isOre(name)
  return string.find(name, "ore") ~= nil
end

function detectAndMineOre()
  local success, data = turtle.inspect()
  if success and isOre(data.name) then
    turtle.dig()
    return true
  end
  return false
end
```

### WebSocket Communication

```lua
local ws

function connectToServer()
  local url = "ws://" .. serverAddress .. ":1337"
  ws = http.websocket(url)

  if ws then
    -- Send registration message
    ws.send(textutils.serialiseJSON({
      type = "register",
      id = os.getComputerID(),
      label = os.getComputerLabel() or "Turtle " .. os.getComputerID()
    }))
    return true
  else
    return false
  end
end

function handleServerCommands()
  while true do
    local message = ws.receive()
    if message then
      local command = textutils.unserialiseJSON(message)
      if command.type == "move" then
        -- Handle movement command
      elseif command.type == "dig" then
        -- Handle digging command
      end

      -- Send status update
      ws.send(textutils.serialiseJSON({
        type = "status",
        fuel = turtle.getFuelLevel(),
        position = getCurrentPosition()
      }))
    else
      -- Connection lost
      break
    end
  end
end
```

### Inventory Management

```lua
function findItem(itemName)
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == itemName then
      return slot
    end
  end
  return nil
end

function depositItems(keepFuelSlot)
  local currentSlot = turtle.getSelectedSlot()

  for slot = 1, 16 do
    if not (keepFuelSlot and slot == 1) then
      turtle.select(slot)
      turtle.dropDown()
    end
  end

  turtle.select(currentSlot)
end
```

### Fuel Management

```lua
function refuelIfNeeded(threshold)
  threshold = threshold or 100

  if turtle.getFuelLevel() < threshold then
    local currentSlot = turtle.getSelectedSlot()
    local fuelSlot = findItem("minecraft:coal") or findItem("minecraft:charcoal")

    if fuelSlot then
      turtle.select(fuelSlot)
      local refueled = turtle.refuel(1)
      turtle.select(currentSlot)
      return refueled
    else
      print("[fuel] No fuel found")
      return false
    end
  end

  return true
end
```

### Path Tracking

```lua
local position = { x = 0, y = 0, z = 0, facing = 0 } -- 0=north, 1=east, 2=south, 3=west

function updatePosition(action)
  if action == "forward" then
    if position.facing == 0 then position.z = position.z - 1
    elseif position.facing == 1 then position.x = position.x + 1
    elseif position.facing == 2 then position.z = position.z + 1
    elseif position.facing == 3 then position.x = position.x - 1 end
  elseif action == "back" then
    if position.facing == 0 then position.z = position.z + 1
    elseif position.facing == 1 then position.x = position.x - 1
    elseif position.facing == 2 then position.z = position.z - 1
    elseif position.facing == 3 then position.x = position.x + 1 end
  elseif action == "up" then
    position.y = position.y + 1
  elseif action == "down" then
    position.y = position.y - 1
  elseif action == "turnRight" then
    position.facing = (position.facing + 1) % 4
  elseif action == "turnLeft" then
    position.facing = (position.facing - 1) % 4
  end

  -- Save position to file for persistence
  savePosition()
end

function savePosition()
  local file = fs.open("position.json", "w")
  file.write(textutils.serialiseJSON(position))
  file.close()
end

function loadPosition()
  if fs.exists("position.json") then
    local file = fs.open("position.json", "r")
    position = textutils.unserialiseJSON(file.readAll())
    file.close()
  end
end
```
