local currentVersion = "1.0.1"

CreateThread(function()
    if not Config.VersionCheck then return end
    
    Wait(2000) -- Wait for other components to load
    
    print("^5[LOFI DISCORD] ^3[INFO]^0: Checking for updates...")
    
    PerformHttpRequest("https://raw.githubusercontent.com/Lofiith/Lofi_VersionCheck/main/lofi_discord.txt", function(code, data)
        if code == 200 then
            local latestVersion = data:gsub("%s+", "") -- Remove whitespace
            
            if currentVersion == latestVersion then
                print("^5[LOFI DISCORD] ^2[VERSION]^0: Running latest version ^6v" .. currentVersion .. "^0")
            else
                print("^5[LOFI DISCORD] ^3[VERSION]^0: Update available! ^1Current: v" .. currentVersion .. " ^7| ^2Latest: v" .. latestVersion .. "^0")
                print("^5[LOFI DISCORD] ^3[INFO]^0: Download the latest version for bug fixes and new features")
            end
        else
            print("^5[LOFI DISCORD] ^3[VERSION]^0: Unable to check for updates (offline mode)")
        end
    end, "GET")
end)
