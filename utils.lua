-- Utility functions for ComputerCraft turtles
-- local utils = {}
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
    -- scan the inventory for coal
    while turtle.getFuelLevel() < level do
        for slot = 1, 16, 1 do

            if turtle.getItemCount(slot) > 0 then
                local data = turtle.getItemDetail(slot)

                if string.find(data.name, "coal") or string.find(data.name, "lava") then
                    turtle.select(slot)
                    turtle.refuel(1)
                end
            end
        end
    end
end

function placeChest(location)
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            if string.find(turtle.getItemDetail(slot).name, "chest") then
                -- chest in position "slot"
                turtle.select(slot)
                if location == "above" then
                    repeat
                        local succ, data = turtle.inspectUp()
                        turtle.digUp()
                        turtle.placeUp()
                    until succ and string.find(data.name, "chest")
                    return true

                elseif location == "below" then
                    repeat
                        local succ, data = turtle.inspectDown()
                        turtle.digDown()
                        turtle.placeDown()
                    until succ and string.find(data.name, "chest")
                    return true
                end
                break
            end
        end
    end
    return false
end
function chest(location)
    local doOnce = true
    while not placeChest(location) do
        if doOnce then
            print("Please supply the turtle with chests")
            doOnce = false
        end
        -- Hibernate if the turtle can't place a chest or whatever
        os.sleep(5)
    end
end

function dv()
    -- DV: Dig Vertical
    local digUp = true
    local digDown = true

    local upSucc, oreUp = turtle.inspectUp()
    local downSucc, oreDown = turtle.inspectDown()

    for key in pairs(blacklistOres) do
        if upSucc then
            if string.find(oreUp.name, blacklistOres[key]) then
                digUp = false
            end
        else
            digUp = false
        end

        if downSucc then
            if string.find(oreDown.name, blacklistOres[key]) then
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

    local timesRan = 0
    timesRan = timesRan + 1

    -- check full inv
    local spareSlots = 0
    for slot = 1, 16 do
        if turtle.getItemCount(slot) <= 0 then
            spareSlots = spareSlots + 1
        end
    end

    if spareSlots < 1 then
        -- full inv

        -- dumping trash
        trashItems()

        -- dumping useful stuff
        cherishItems()

        -- The items have been dumped, sorting
        sortInventory()
    end
end
