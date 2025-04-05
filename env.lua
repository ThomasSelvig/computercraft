local env = {}

env.refuelables = {"coal", "lava", "blaze", "charcoal"}
env.chestSide = "below"
env.blacklistOres = {}
env.trashItems = {}

-- Configuration
-- env.WEBSOCKET_URL = "wss://sought-composed-alpaca.ngrok-free.app/turtles"
env.WEBSOCKET_URL = "ws://81.0.169.192:1339"
env.TURTLE_NAME = os.getComputerLabel() or tostring(os.getComputerID())
env.HEARTBEAT_INTERVAL = 1 -- seconds

return env
