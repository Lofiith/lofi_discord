local cache = {}
local isReady = false

local function validateConfig()
    if not Config.Token or Config.Token == "YOUR_BOT_TOKEN_HERE" then
        print("^5[LOFI DISCORD] ^1[ERROR]^0: Bot token not configured in config.lua")
        return false
    end
    
    if not Config.Guild or Config.Guild == "YOUR_GUILD_ID_HERE" then
        print("^5[LOFI DISCORD] ^1[ERROR]^0: Guild ID not configured in config.lua")
        return false
    end
    
    return true
end

local function removeEmojis(text)
    if not text then return "" end
    
    local emoji = "[%z\1-\127\194-\244][\128-\191]*"
    return text:gsub(emoji, function(char)
        if char:byte() > 127 and char:byte() <= 244 then
            return ''
        else
            return char
        end
    end)
end

local function getDiscordId(source)
    if not source then return nil end
    
    local identifiers = GetPlayerIdentifiers(source)
    if not identifiers then return nil end
    
    for _, identifier in pairs(identifiers) do
        if identifier:match("discord:") then
            return identifier:gsub("discord:", "")
        end
    end
    
    return nil
end

local function makeDiscordRequest(endpoint)
    local promise = promise.new()
    
    PerformHttpRequest("https://discord.com/api/v10" .. endpoint, function(code, data, headers)
        if code == 200 then
            promise:resolve(json.decode(data))
        elseif code == 401 then
            print("^5[LOFI DISCORD] ^1[ERROR]^0: Invalid bot token or insufficient permissions")
            promise:resolve(nil)
        else
            promise:resolve(nil)
        end
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Token,
        ["Content-Type"] = "application/json"
    })
    
    return Citizen.Await(promise)
end

local function updateCache(discordId, data)
    cache[discordId] = {
        data = data,
        timestamp = os.time()
    }
end

local function getCachedData(discordId)
    if cache[discordId] then
        if os.time() - cache[discordId].timestamp < 300 then -- 5 minutes cache
            return cache[discordId].data
        end
    end
    return nil
end

local function getDiscordUserData(discordId, useCache)
    if not discordId then return nil end
    
    if useCache ~= false then
        local cached = getCachedData(discordId)
        if cached then return cached end
    end
    
    local userData = makeDiscordRequest("/users/" .. discordId)
    local memberData = makeDiscordRequest("/guilds/" .. Config.Guild .. "/members/" .. discordId)
    
    if not userData and not memberData then return nil end
    
    local result = {
        user = userData,
        member = memberData,
        inGuild = memberData ~= nil,
        roles = memberData and memberData.roles or {},
        username = userData and userData.username or nil,
        avatar = userData and userData.avatar and 
            string.format("https://cdn.discordapp.com/avatars/%s/%s.%s", 
                discordId, userData.avatar, userData.avatar:sub(1, 2) == "a_" and "gif" or "png") 
            or "https://cdn.discordapp.com/embed/avatars/0.png",
        nickname = memberData and memberData.nick or nil,
        displayName = (memberData and memberData.nick) or (userData and userData.username) or nil
    }
    
    updateCache(discordId, result)
    return result
end

-- Player connected event
RegisterNetEvent('lofi_discord:playerReady', function()
    if not isReady then return end
    
    local source = source
    local playerName = GetPlayerName(source)
    local discordId = getDiscordId(source)
    
    if not discordId then
        if Config.TrackJoinLeave then
            print("^5[LOFI DISCORD] ^3[INFO]^0: " .. playerName .. " ^7joined ^1(Discord not linked)^0")
        end
        
        if Config.RequireDiscord then
            DropPlayer(source, "Discord account required to join this server")
        end
        return
    end
    
    if Config.AutoRefreshCache then
        getDiscordUserData(discordId, false) -- Force refresh
    end
    
    if Config.TrackJoinLeave then
        local userData = getDiscordUserData(discordId)
        if userData and userData.inGuild then
            local roleCount = #userData.roles
            local displayName = userData.displayName or "Unknown"
            print("^5[LOFI DISCORD] ^3[INFO]^0: " .. playerName .. " ^7joined ^2(" .. displayName .. " ^7| ^6" .. roleCount .. " roles^2)^0")
        else
            print("^5[LOFI DISCORD] ^3[INFO]^0: " .. playerName .. " ^7joined ^3(Not in Discord guild)^0")
        end
    end
end)

-- Player dropped event
AddEventHandler('playerDropped', function(reason)
    local source = source
    local discordId = getDiscordId(source)
    
    if discordId then
        cache[discordId] = nil -- Clean up cache
    end
end)

-- Initialize Discord connection
CreateThread(function()
    Wait(1000)
    
    if not validateConfig() then return end
    
    local guildData = makeDiscordRequest("/guilds/" .. Config.Guild)
    if guildData then
        isReady = true
        print("^5[LOFI DISCORD] ^2[SUCCESS]^0: Connected to Discord guild ^6'" .. removeEmojis(guildData.name) .. "'^0")
    else
        print("^5[LOFI DISCORD] ^1[ERROR]^0: Failed to connect to Discord guild")
    end
end)

-- Exports
exports('getAvatar', function(source)
    local discordId = getDiscordId(source)
    local userData = getDiscordUserData(discordId)
    return userData and userData.avatar or nil
end)

exports('getUsername', function(source)
    local discordId = getDiscordId(source)
    local userData = getDiscordUserData(discordId)
    return userData and userData.username or nil
end)

exports('getDisplayName', function(source)
    local discordId = getDiscordId(source)
    local userData = getDiscordUserData(discordId)
    return userData and userData.displayName or nil
end)

exports('hasRole', function(source, roleIds, requireAll)
    local discordId = getDiscordId(source)
    local userData = getDiscordUserData(discordId)
    
    if not userData or not userData.inGuild then return false end
    
    local userRoles = {}
    for _, roleId in pairs(userData.roles) do
        userRoles[roleId] = true
    end
    
    if type(roleIds) == "string" then
        return userRoles[roleIds] ~= nil
    elseif type(roleIds) == "table" then
        local matches = 0
        for _, roleId in pairs(roleIds) do
            if userRoles[roleId] then
                matches = matches + 1
                if not requireAll then return true end
            end
        end
        
        return requireAll and matches == #roleIds or matches > 0
    end
    
    return false
end)

exports('getRoles', function(source)
    local discordId = getDiscordId(source)
    local userData = getDiscordUserData(discordId)
    return userData and userData.roles or {}
end)

exports('isInGuild', function(source)
    local discordId = getDiscordId(source)
    local userData = getDiscordUserData(discordId)
    return userData and userData.inGuild or false
end)

exports('getUser', function(source)
    local discordId = getDiscordId(source)
    return getDiscordUserData(discordId)
end)

exports('refreshCache', function(source)
    local discordId = getDiscordId(source)
    if discordId then
        cache[discordId] = nil
        return getDiscordUserData(discordId, false) ~= nil
    end
    return false
end)
