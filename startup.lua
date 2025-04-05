-- wget https://sought-composed-alpaca.ngrok-free.app/startup.lua
local URL = "https://sought-composed-alpaca.ngrok-free.app"
-- wget http://127.0.0.1:1337/startup.lua
-- local URL = "http://127.0.0.1:1337"

local function downloadFile(url, ccFilename)

    -- local scriptReq, err = http.get("/main.lua")
    local scriptReq, err = http.get(url)
    if not scriptReq then
        print("Failed to check for updates: " .. (err or "unknown error"))
    else
        local scriptContent = scriptReq.readAll()
        scriptReq.close()

        local file = fs.open(ccFilename, "w")
        if file then
            file.write(scriptContent)
            file.close()
            -- print("Downloaded , running...")
            print("Downloaded " .. ccFilename)
            -- shell.run("main.lua")
            return
        else
            print("Failed to write update to file")
        end
    end

end

downloadFile(URL .. "/env.lua", "env.lua")
downloadFile(URL .. "/main.lua", "main.lua")
downloadFile(URL .. "/utils.lua", "utils.lua")
downloadFile(URL .. "/startup.lua", "startup.lua")
-- term.clear()
shell.run("main.lua")
