-- Environment configuration for ComputerCraft Turtle
local env = {
    -- WebSocket configuration
    -- WEBSOCKET_URL = "ws://localhost:1337",
    WEBSOCKET_URL = "wss://sought-composed-alpaca.ngrok-free.app",
    TURTLE_NAME = os.getComputerLabel() or "Turtle" .. os.getComputerID(),
    HEARTBEAT_INTERVAL = 10, -- seconds
    CONNECTION_TIMEOUT = 30, -- seconds

    -- Fuel management
    LOW_FUEL_THRESHOLD = 100,
    CRITICAL_FUEL_THRESHOLD = 20,
    refuelables = {"coal", "charcoal", "lava_bucket"},

    -- Inventory management
    KEEP_FUEL_IN_SLOT = 1,
    MIN_INVENTORY_SLOTS_FREE = 3,

    -- Block categories
    orePatterns = {"coal_ore", "iron_ore", "gold_ore", "diamond_ore", "emerald_ore", "lapis_ore", "redstone_ore",
                   "quartz_ore", "ancient_debris"},

    trashItems = {"cobblestone", "dirt", "gravel", "sand", "andesite", "diorite", "granite", "tuff", "deepslate"},

    blacklistOres = {"bedrock"},

    -- Chest management
    chestSide = "down", -- Default side for chest operations

    -- Mining configuration
    MINING_DIG_DELAY = 0.5, -- seconds to wait after digging

    -- Movement configuration
    MAX_MOVEMENT_ATTEMPTS = 3
}

return env
