local currentVersion = "1.0.0"

CreateThread(function()
    if not Config.VersionCheck then return end
    
    local resourceName = GetCurrentResourceName()
    
    PerformHttpRequest("https://raw.githubusercontent.com/yourusername/Lofi_DiscordAPI/main/version.txt", function(code, data)
        if code == 200 then
            local latestVersion = data:gsub("%s+", "")
            if currentVersion == latestVersion then
                print("^2[" .. resourceName .. "]^0 Version ^2" .. currentVersion .. "^0 - You're running the ^2latest^0 version!")
            else
                print("^1[" .. resourceName .. "]^0 Version ^1" .. currentVersion .. "^0 - ^3Update available!^0 Latest: ^2" .. latestVersion .. "^0")
            end
        else
            print("^3[" .. resourceName .. "]^0 Unable to check version")
        end
    end, "GET")
end)
