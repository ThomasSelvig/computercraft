-- Utility functions for ComputerCraft turtles
local env = require("env.lua")

function forceWalk(dir)
    -- dirs: up, down, fw, back (in string form)
    if dir == "fw" then
        while not turtle.forward() do
            if turtle.detect() then
                turtle.dig()
            else
                turtle.attack()
            end
        end
    elseif dir == "back" then
        turtle.turnRight()
        turtle.turnRight()
        forceWalk("fw")
        turtle.turnRight()
        turtle.turnRight()
    elseif dir == "up" then
        while not turtle.up() do
            if turtle.detectUp() then
                turtle.digUp()
            else
                turtle.attackUp()
            end
        end
    elseif dir == "down" then
        while not turtle.down() do
            if turtle.detectDown() then
                turtle.digDown()
            else
                turtle.attackDown()
            end
        end
    end
end

function refuel(level)
    -- returns bool: true if refueled, false if not
    local fuelLevel = turtle.getFuelLevel()
    print("Fuel level: " .. fuelLevel .. " / " .. level)
    -- scan the inventory for fuel items
    for slot = 1, 16, 1 do
        if turtle.getItemCount(slot) > 0 then
            local data = turtle.getItemDetail(slot)
            for _, pattern in ipairs(env.refuelables) do
                if string.find(data.name, pattern) then
                    -- fuel item found
                    while turtle.getFuelLevel() < level do
                        turtle.select(slot)
                        turtle.refuel(1)
                        -- run out of fuel in this slot
                        if turtle.getItemCount(slot) == 0 then
                            break
                        end
                    end
                end
            end
        end
    end
    print("[fuel] Refueled from " .. fuelLevel .. " to " .. turtle.getFuelLevel())
    return turtle.getFuelLevel() >= level
end

function findItemSlot(name)
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            local data = turtle.getItemDetail(slot)
            if string.find(data.name, name) then
                return slot
            end
        end
    end
    return false
end

function attemptPlaceChest(location)
    local chestSlot = findItemSlot("chest")
    if chestSlot then
        turtle.select(chestSlot)
        if location == "above" then
            local success = turtle.placeUp()
            print("[chest] Placing chest above: " .. (success and "success" or "failed"))
            return success
        elseif location == "below" then
            local success = turtle.placeDown()
            print("[chest] Placing chest below: " .. (success and "success" or "failed"))
            return success
        elseif location == "left" then
            turtle.turnLeft()
            local success = turtle.place()
            turtle.turnRight()
            print("[chest] Placing chest to the left: " .. (success and "success" or "failed"))
            return success
        elseif location == "right" then
            turtle.turnRight()
            local success = turtle.place()
            turtle.turnLeft()
            print("[chest] Placing chest to the right: " .. (success and "success" or "failed"))
            return success
        end
    else
        print("[chest] No chests found")
    end
    return false
end

function placeChest(location)
    local doOnce = true
    while not attemptPlaceChest(location) do
        if doOnce then
            print("Please supply the turtle with chests")
            doOnce = false
        end
        -- Hibernate if the turtle can't place a chest or whatever
        os.sleep(5)
    end
end

function availableSlots()
    local slots = 0
    for slot = 1, 16 do
        if turtle.getItemCount(slot) == 0 then
            slots = slots + 1
        end
    end
    return slots
end

function cherishItems()
    chest(env.chestSide)
    -- The chest has now been placed
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            local detail = turtle.getItemDetail(slot)
            if not string.find(detail.name, "chest") and
                not (string.find(detail.name, "coal") and not string.find(detail.name, "ore")) then
                turtle.select(slot)
                turtle.dropDown()
            end
        end
    end
    turtle.select(1)
end

function trashTheTrash()
    chest("above")
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            data = turtle.getItemDetail(slot)
            for key in pairs(env.trashItems) do
                if string.find(data.name, env.trashItems[key]) then
                    -- item in "slot" is trash
                    turtle.select(slot)
                    turtle.dropUp()
                end
            end
        end
    end
end

function sortInventory()
    -- stack all the items
    for selSlot = 1, 16 do
        if turtle.getItemCount(selSlot) > 0 then
            local detail = turtle.getItemDetail(selSlot)
            -- item is selected, now the item will scroll the inventory
            for slot = 1, 16 do
                local specDetail = turtle.getItemDetail(slot)
                if turtle.getItemCount(slot) > 0 then
                    if slot < selSlot and detail.name == specDetail.name then
                        turtle.select(selSlot)
                        turtle.transferTo(slot)
                    end
                end
            end
            if turtle.getItemCount(selSlot) > 0 then
                -- not all items were transfered
                -- put the items in selslot in the first blank space
                for blankScroll = 1, 16 do
                    if turtle.getItemCount(blankScroll) <= 0 then
                        turtle.select(selSlot)
                        turtle.transferTo(blankScroll)
                    end
                end
            end
        end
    end
    turtle.select(1)
end

function dumpAllDown()
    chest("below")
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            turtle.dropDown()
        end
    end
end

function dv()
    -- DV: Dig Vertical
    local digUp = true
    local digDown = true

    local upSucc, oreUp = turtle.inspectUp()
    local downSucc, oreDown = turtle.inspectDown()

    for key in pairs(env.blacklistOres) do
        if upSucc then
            if string.find(oreUp.name, env.blacklistOres[key]) then
                digUp = false
            end
        else
            digUp = false
        end

        if downSucc then
            if string.find(oreDown.name, env.blacklistOres[key]) then
                digDown = false
            end
        else
            digDown = false
        end
    end

    if digUp then
        while turtle.detectUp() do
            turtle.digUp()
        end
    end
    if digDown then
        while turtle.detectDown() do
            turtle.digDown()
        end
    end

    -- chest functionality:
    -- if full inv:
    --   if chest in inv:
    --      place chest and drop entire inventory (except for fuel and chests)
    --   else: wait until it has chests

    -- check full inv
    local spareSlots = availableSlots()

    if spareSlots < 1 then
        -- full inv

        -- dumping trash
        trashTheTrash()

        -- dumping useful stuff
        cherishItems()

        -- The items have been dumped, sorting
        sortInventory()
    end
end

function promptForFuel(depth, width)
    local reqFuel
    if width % 2 == 0 then
        reqFuel = depth * width + width + width
    else
        reqFuel = depth * width + width + width + depth
    end

    term.setTextColor(colors.yellow)
    print("\n=== Fuel Check ===")
    print("Required fuel: " .. reqFuel)
    print("Required coal: " .. math.ceil(reqFuel / 80.0))

    while turtle.getFuelLevel() < reqFuel do
        term.setTextColor(colors.red)
        local missing = reqFuel - turtle.getFuelLevel()
        print("\nNot enough fuel!")
        print("Missing: " .. missing .. " fuel units")
        print("Need " .. math.ceil(missing / 80.0) .. " more coal")

        term.setTextColor(colors.white)
        print("\nPlease add fuel and press Enter to continue")
        print("(or press Ctrl+T to terminate)")
        read()
        refuel(reqFuel)
    end

    term.setTextColor(colors.green)
    print("\nFuel level sufficient!")
    print("Extra fuel: " .. (turtle.getFuelLevel() - reqFuel))
    term.setTextColor(colors.white)
end
