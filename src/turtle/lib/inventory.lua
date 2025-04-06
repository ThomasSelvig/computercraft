-- Inventory management module
local env = require("env")

local Inventory = {}

-- Find an item in inventory by name pattern
function Inventory.findItem(pattern)
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and string.find(item.name, pattern) then
            return slot, item
        end
    end
    return nil
end

-- Count available slots
function Inventory.availableSlots()
    local slots = 0
    for slot = 1, 16 do
        if turtle.getItemCount(slot) == 0 then
            slots = slots + 1
        end
    end
    return slots
end

-- Get complete inventory status
function Inventory.getStatus()
    local inventory = {}
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        inventory[i] = item
    end
    return inventory
end

-- Check if inventory is full
function Inventory.isFull()
    return Inventory.availableSlots() == 0
end

-- Check if inventory is empty
function Inventory.isEmpty()
    return Inventory.availableSlots() == 16
end

-- Sort inventory to stack similar items
function Inventory.sortInventory()
    local currentSlot = turtle.getSelectedSlot()
    
    -- Stack all the items
    for selSlot = 1, 16 do
        if turtle.getItemCount(selSlot) > 0 then
            local detail = turtle.getItemDetail(selSlot)
            -- Try to stack with earlier slots
            for slot = 1, selSlot - 1 do
                if turtle.getItemCount(slot) > 0 then
                    local slotDetail = turtle.getItemDetail(slot)
                    if detail.name == slotDetail.name then
                        turtle.select(selSlot)
                        turtle.transferTo(slot)
                        if turtle.getItemCount(selSlot) == 0 then
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- Compact the inventory (move items to earliest slots)
    local nextEmptySlot = 1
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            if slot > nextEmptySlot then
                turtle.select(slot)
                turtle.transferTo(nextEmptySlot)
            end
            nextEmptySlot = nextEmptySlot + 1
        elseif slot < nextEmptySlot then
            nextEmptySlot = slot
        end
    end
    
    -- Restore original slot
    turtle.select(currentSlot)
    
    return true
end

-- Filter out items matching patterns
function Inventory.filterItems(patterns, action)
    local currentSlot = turtle.getSelectedSlot()
    local count = 0
    
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            local item = turtle.getItemDetail(slot)
            for _, pattern in ipairs(patterns) do
                if string.find(item.name, pattern) then
                    turtle.select(slot)
                    local success = false
                    
                    if action == "drop" then
                        success = turtle.drop()
                    elseif action == "dropUp" then
                        success = turtle.dropUp()
                    elseif action == "dropDown" then
                        success = turtle.dropDown()
                    end
                    
                    if success then
                        count = count + 1
                    end
                    
                    break
                end
            end
        end
    end
    
    turtle.select(currentSlot)
    return count
end

-- Dump inventory into a chest
function Inventory.dumpInventory(direction, keepFuelSlot)
    local currentSlot = turtle.getSelectedSlot()
    local count = 0
    
    for slot = 1, 16 do
        if not (keepFuelSlot and slot == 1 and Inventory.isFuelItem(slot)) then
            if turtle.getItemCount(slot) > 0 then
                turtle.select(slot)
                local success = false
                
                if direction == "down" then
                    success = turtle.dropDown()
                elseif direction == "up" then
                    success = turtle.dropUp()
                else  -- forward
                    success = turtle.drop()
                end
                
                if success then
                    count = count + 1
                end
            end
        end
    end
    
    turtle.select(currentSlot)
    return count
end

-- Check if an item is fuel
function Inventory.isFuelItem(slot)
    if turtle.getItemCount(slot) == 0 then
        return false
    end
    
    local item = turtle.getItemDetail(slot)
    if not item then return false end
    
    for _, pattern in ipairs(env.refuelables or {}) do
        if string.find(item.name, pattern) then
            return true
        end
    end
    
    return false
end

-- Attempt to place a chest
function Inventory.placeChest(direction)
    local chestSlot = Inventory.findItem("chest")
    if not chestSlot then
        return false, "No chest found in inventory"
    end
    
    local currentSlot = turtle.getSelectedSlot()
    turtle.select(chestSlot)
    
    local success = false
    if direction == "up" then
        success = turtle.placeUp()
    elseif direction == "down" then
        success = turtle.placeDown()
    elseif direction == "forward" then
        success = turtle.place()
    elseif direction == "left" then
        turtle.turnLeft()
        success = turtle.place()
        turtle.turnRight()
    elseif direction == "right" then
        turtle.turnRight()
        success = turtle.place()
        turtle.turnLeft()
    end
    
    turtle.select(currentSlot)
    return success
end

return Inventory