-- ComputerCraft Turtle Startup Script
-- This script runs automatically when the turtle boots and downloads all required files
-- Configuration
local SERVER_URL = "https://sought-composed-alpaca.ngrok-free.app" -- Update this to your server URL
local VERSION_FILE = "version.txt"
local CURRENT_VERSION = "0.1.0" -- This should match the version in package.json

-- Required files to download from server
local REQUIRED_FILES = {"/env.lua", "/main.lua", "/lib/commands.lua", "/lib/fuel.lua", "/lib/inventory.lua",
                        "/lib/movement.lua", "/lib/position.lua", "/lib/websocket.lua", "/tasks/mining.lua"}

-- Ensure directories exist
local function ensureDirectories()
    if not fs.exists("lib") then
        fs.makeDir("lib")
    end
    if not fs.exists("tasks") then
        fs.makeDir("tasks")
    end
end

-- Download a file from the server
local function downloadFile(path, destination)
    print("Downloading " .. path .. " to " .. destination)

    local url = SERVER_URL .. path
    local response, err = http.get(url)

    if not response then
        print("Failed to download " .. path .. ": " .. (err or "unknown error"))
        return false
    else
        local content = response.readAll()
        response.close()

        local file = fs.open(destination, "w")
        if file then
            file.write(content)
            file.close()
            print("Downloaded " .. destination)
            return true
        else
            print("Failed to write to " .. destination)
            return false
        end
    end
end

-- Check if update is needed
local function checkForUpdates()
    local shouldUpdate = true

    -- Check if version file exists and read current version
    if fs.exists(VERSION_FILE) then
        local file = fs.open(VERSION_FILE, "r")
        local storedVersion = file.readAll()
        file.close()

        -- Check version from server
        local versionResponse, err = http.get(SERVER_URL .. "/version.txt")
        if versionResponse then
            local serverVersion = versionResponse.readAll()
            versionResponse.close()

            if storedVersion == serverVersion then
                print("Software is up to date (version " .. storedVersion .. ")")
                shouldUpdate = false
            else
                print("Update available: " .. storedVersion .. " -> " .. serverVersion)
            end
        else
            print("Could not check for updates: " .. (err or "unknown error"))
            -- Proceed with updates if we can't check version
        end
    end

    return shouldUpdate
end

-- Download all required files
local function updateSoftware()
    print("Updating turtle software...")

    -- Ensure necessary directories exist
    ensureDirectories()

    -- Download all required files
    local success = true
    for _, filePath in ipairs(REQUIRED_FILES) do
        local destination = filePath
        local directory = fs.getDir(destination)

        if directory ~= "" and not fs.exists(directory) then
            fs.makeDir(directory)
        end

        if not downloadFile(filePath, destination) then
            success = false
        end
    end

    -- Update version file if all downloads succeeded
    if success then
        -- Get server version
        local versionResponse, err = http.get(SERVER_URL .. "/version.txt")
        if versionResponse then
            local serverVersion = versionResponse.readAll()
            versionResponse.close()

            local versionFile = fs.open(VERSION_FILE, "w")
            versionFile.write(serverVersion)
            versionFile.close()

            print("Software updated to version " .. serverVersion)
        else
            -- Use current version if server version is unavailable
            local versionFile = fs.open(VERSION_FILE, "w")
            versionFile.write(CURRENT_VERSION)
            versionFile.close()

            print("Software updated to version " .. CURRENT_VERSION)
        end
    else
        print("Some files failed to update")
    end

    return success
end

-- Setup error handling
local function setupErrorHandling()
    local logFile = "error.log"

    -- Function to log errors
    local function logError(msg)
        local file = fs.open(logFile, "a")
        if file then
            file.write("[" .. os.date() .. "] " .. tostring(msg) .. "\n")
            file.close()
        end
    end

    -- Redirect errors
    local oldPcall = pcall
    pcall = function(f, ...)
        local result = {oldPcall(f, ...)}
        if not result[1] then
            logError(result[2])
        end
        return table.unpack(result)
    end
end

-- Main startup function
local function startup()
    print("Turtle Orchestration System - Startup")

    -- Ensure package path includes lib directory
    if not string.find(package.path, ";lib/?.lua") then
        package.path = package.path .. ";lib/?.lua"
    end

    -- Set up error handling
    setupErrorHandling()

    -- Check for and apply updates
    local shouldUpdate = checkForUpdates()
    if shouldUpdate then
        updateSoftware()
    end

    -- Always download env.lua as it may contain configuration changes
    downloadFile("/env.lua", "env.lua")

    -- Run the main program
    print("Starting main program...")
    shell.run("main.lua")
end

-- Run the startup process
startup()
