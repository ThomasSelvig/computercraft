-- Fuel management module
local Inventory = require("lib.inventory")
local env = require("env")

local Fuel = {}

-- Default low fuel threshold
Fuel.LOW_FUEL_THRESHOLD = 100

-- Refuel to a specific level
function Fuel.refuelToLevel(targetLevel)
    local currentLevel = turtle.getFuelLevel()

    if currentLevel >= targetLevel then
        return true, currentLevel
    end

    local startingLevel = currentLevel
    local refueled = false

    -- Try to refuel from each slot
    for slot = 1, 16 do
        if Inventory.isFuelItem(slot) then
            local currentSlot = turtle.getSelectedSlot()
            turtle.select(slot)

            -- Keep refueling until we reach the target or run out of fuel items
            while turtle.getFuelLevel() < targetLevel and turtle.getItemCount() > 0 do
                if turtle.refuel(1) then
                    refueled = true
                else
                    break
                end
            end

            turtle.select(currentSlot)

            -- If we've reached the target level, we're done
            if turtle.getFuelLevel() >= targetLevel then
                break
            end
        end
    end

    local newLevel = turtle.getFuelLevel()
    local added = newLevel - startingLevel

    print(string.format("[fuel] Refueled from %d to %d (+%d)", startingLevel, newLevel, added))

    return newLevel >= targetLevel, newLevel
end

-- Check if fuel is low and refuel if needed
function Fuel.checkFuel(threshold)
    threshold = threshold or Fuel.LOW_FUEL_THRESHOLD

    if turtle.getFuelLevel() < threshold then
        print(string.format("[fuel] Fuel low: %d/%d", turtle.getFuelLevel(), threshold))
        return Fuel.refuelToLevel(threshold)
    end

    return true, turtle.getFuelLevel()
end

-- Calculate required fuel for a operation
function Fuel.calculateRequiredFuel(depth, width, height)
    local moves = 0

    -- Calculate moves for mining a rectangular area
    if width and depth then
        if width % 2 == 0 then
            moves = depth * width + width + width
        else
            moves = depth * width + width + width + depth
        end
    end

    -- Add height movement if specified
    if height then
        moves = moves + height * 2
    end

    -- Add a 20% buffer for safety
    return math.ceil(moves * 1.2)
end

-- Prompt for fuel with calculation
function Fuel.promptForFuel(requiredFuel)
    term.setTextColor(colors.yellow)
    print("\n=== Fuel Check ===")
    print("Required fuel: " .. requiredFuel)
    print("Required coal: " .. math.ceil(requiredFuel / 80.0))

    while turtle.getFuelLevel() < requiredFuel do
        term.setTextColor(colors.red)
        local missing = requiredFuel - turtle.getFuelLevel()
        print("\nNot enough fuel!")
        print("Missing: " .. missing .. " fuel units")
        print("Need " .. math.ceil(missing / 80.0) .. " more coal")

        term.setTextColor(colors.white)
        print("\nPlease add fuel and press Enter to continue")
        print("(or press Ctrl+T to terminate)")
        read()
        Fuel.refuelToLevel(requiredFuel)
    end

    term.setTextColor(colors.green)
    print("\nFuel level sufficient!")
    print("Extra fuel: " .. (turtle.getFuelLevel() - requiredFuel))
    term.setTextColor(colors.white)

    return true
end

-- Get fuel status
function Fuel.getStatus()
    return {
        level = turtle.getFuelLevel(),
        max = turtle.getFuelLimit(),
        isLow = turtle.getFuelLevel() < Fuel.LOW_FUEL_THRESHOLD
    }
end

return Fuel
