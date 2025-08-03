# lofi_discord - Simple Discord API for FiveM

A lightweight, optimized Discord API system for FiveM servers. Simple to use with essential features and server-side security.

## Features

- Get Discord avatars, usernames, and display names
- Check player roles (single or multiple)
- Track player join/leave events with Discord info
- Optional Discord requirement for server access
- Built-in caching for performance
- 100% server-side for security

## Installation

1. Download and place in your resources folder
2. Rename folder to `lofi_discord` 
3. Add `ensure lofi_discord` to your server.cfg
4. Configure `config.lua` with your bot token and guild ID

## Configuration

```lua
Config.Token = "YOUR_BOT_TOKEN_HERE"    -- Your Discord bot token
Config.Guild = "YOUR_GUILD_ID_HERE"     -- Your Discord server ID

Config.RequireDiscord = false           -- Kick players without Discord
Config.TrackJoinLeave = true           -- Log player join/leave with Discord info  
Config.AutoRefreshCache = true         -- Refresh cache on player connect
```

## Export Functions

```lua
-- Get Discord avatar URL
local avatar = exports.lofi_discord:getAvatar(source)

-- Get Discord username  
local username = exports.lofi_discord:getUsername(source)

-- Get display name (nickname or username)
local displayName = exports.lofi_discord:getDisplayName(source)

-- Check if player has a role
local hasRole = exports.lofi_discord:hasRole(source, "123456789")

-- Check multiple roles (any match)
local hasAnyRole = exports.lofi_discord:hasRole(source, {"123", "456", "789"})

-- Check multiple roles (require all)
local hasAllRoles = exports.lofi_discord:hasRole(source, {"123", "456"}, true)

-- Get all player roles
local roles = exports.lofi_discord:getRoles(source)

-- Check if player is in Discord guild
local inGuild = exports.lofi_discord:isInGuild(source)

-- Get complete user data
local userData = exports.lofi_discord:getUser(source)

-- Refresh player cache (force update)
exports.lofi_discord:refreshCache(source)
```

## Requirements

- Discord Bot Token
- Discord Guild (Server) ID  
- Bot permissions: Read Messages, View Server Members

## Example Usage

```lua
-- Check if player is admin
RegisterCommand('admin', function(source, args, rawCommand)
    local adminRole = "123456789012345678"
    
    if exports.lofi_discord:hasRole(source, adminRole) then
        -- Give admin access
        print("Admin access granted")
    else
        -- Deny access
        print("Access denied")
    end
end)
```
