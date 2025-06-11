local discordCache = {}
local cacheExpiry = 300 -- 5 minutes cache

local function makeDiscordRequest(endpoint, method)
    local promise = promise.new()
    
    PerformHttpRequest("https://discord.com/api/v10" .. endpoint, function(code, data, headers)
        if code == 200 then
            promise:resolve(json.decode(data))
        else
            promise:resolve(nil)
        end
    end, method or "GET", "", {
        ["Authorization"] = "Bot " .. Config.BotToken,
        ["Content-Type"] = "application/json"
    })
    
    return Citizen.Await(promise)
end

local function getDiscordId(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        if string.match(id, "discord:") then
            return string.gsub(id, "discord:", "")
        end
    end
    return nil
end

local function updateCache(discordId, data)
    discordCache[discordId] = {
        data = data,
        timestamp = os.time()
    }
end

local function getCachedData(discordId)
    if discordCache[discordId] then
        if os.time() - discordCache[discordId].timestamp < cacheExpiry then
            return discordCache[discordId].data
        end
    end
    return nil
end

-- Player join handler
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local source = source
    local discordId = getDiscordId(source)
    local resourceName = GetCurrentResourceName()
    
    if discordId then
        local memberData = makeDiscordRequest("/guilds/" .. Config.GuildId .. "/members/" .. discordId)
        local userData = makeDiscordRequest("/users/" .. discordId)
        
        if memberData and userData then
            local roleCount = #memberData.roles
            print(string.format("^2[%s]^0 %s joined ^7(^5%s^7 | ^3%d roles^7)^0", resourceName, name, userData.username, roleCount))
        else
            print(string.format("^2[%s]^0 %s joined ^7(^1No Discord^7)^0", resourceName, name))
        end
    else
        print(string.format("^2[%s]^0 %s joined ^7(^1Discord not linked^7)^0", resourceName, name))
    end
end)


-- Get Discord avatar
exports("getAvatar", function(serverId)
    local discordId = getDiscordId(serverId)
    if not discordId then return nil end
    
    local cached = getCachedData(discordId)
    if cached and cached.avatar then
        return cached.avatar
    end
    
    local userData = makeDiscordRequest("/users/" .. discordId)
    if userData then
        local avatar = userData.avatar and 
            string.format("https://cdn.discordapp.com/avatars/%s/%s.%s", 
                discordId, userData.avatar, 
                userData.avatar:sub(1, 2) == "a_" and "gif" or "png") 
            or "https://cdn.discordapp.com/embed/avatars/0.png"
        
        updateCache(discordId, {avatar = avatar, username = userData.username})
        return avatar
    end
    return nil
end)

-- Get Discord username
exports("getUsername", function(serverId)
    local discordId = getDiscordId(serverId)
    if not discordId then return nil end
    
    local cached = getCachedData(discordId)
    if cached and cached.username then
        return cached.username
    end
    
    local userData = makeDiscordRequest("/users/" .. discordId)
    if userData then
        updateCache(discordId, {username = userData.username})
        return userData.username
    end
    return nil
end)

-- Check if user has role(s)
exports("hasRole", function(serverId, roles, requireAll)
    local discordId = getDiscordId(serverId)
    if not discordId then return false end
    
    local memberData = makeDiscordRequest("/guilds/" .. Config.GuildId .. "/members/" .. discordId)
    if not memberData then return false end
    
    local userRoles = {}
    for _, roleId in pairs(memberData.roles) do
        userRoles[roleId] = true
    end
    
    if type(roles) == "string" then
        return userRoles[roles] ~= nil
    elseif type(roles) == "table" then
        local count = 0
        for _, roleId in pairs(roles) do
            if userRoles[roleId] then
                count = count + 1
            end
        end
        
        if requireAll then
            return count == #roles
        else
            return count > 0
        end
    end
    
    return false
end)

-- Get guild member count
exports("getGuildMemberCount", function()
    local guildData = makeDiscordRequest("/guilds/" .. Config.GuildId .. "?with_counts=true")
    if guildData then
        return guildData.member_count
    end
    return 0
end)

-- Get online Discord members in-game
exports("getOnlineDiscordMembers", function()
    local count = 0
    local players = GetPlayers()
    
    for _, playerId in pairs(players) do
        local discordId = getDiscordId(playerId)
        if discordId then
            local memberData = makeDiscordRequest("/guilds/" .. Config.GuildId .. "/members/" .. discordId)
            if memberData then
                count = count + 1
            end
        end
    end
    
    return count
end)

-- Get user roles
exports("getUserRoles", function(serverId)
    local discordId = getDiscordId(serverId)
    if not discordId then return {} end
    
    local memberData = makeDiscordRequest("/guilds/" .. Config.GuildId .. "/members/" .. discordId)
    if memberData then
        return memberData.roles
    end
    return {}
end)

-- Get role count
exports("getRoleCount", function(serverId)
    local roles = exports["Lofi_DiscordAPI"]:getUserRoles(serverId)
    return #roles
end)
