# Lofi Discord API System for FiveM

This is a lightweight, optimized Discord API system for FiveM that provides seamless integration between your game server and Discord. It allows server owners to fetch player Discord data, verify roles, and track Discord-connected players with a simple export system. The script is designed with security and performance in mind, featuring built-in caching and server-side only execution.

## Requirements

- Discord Bot Token
- Valid Guild ID
- Players with linked Discord accounts

## Features

- Fetch player Discord avatars and usernames instantly
- Check single or multiple role permissions with flexible verification
- Track Discord server member count and online players
- Built-in caching system to prevent API spam and improve performance
- Automatic version checking with color-coded console output
- Player join notifications with Discord info and role count
- 100% server-sided for maximum security

## Installation

1. Clone or download the repository.
2. Copy the `Lofi_DiscordAPI` folder to your resources directory.
3. Add `ensure Lofi_DiscordAPI` to your server.cfg.

## Usage / Documentation

For detailed usage instructions and documentation, please follow these steps:

1. Create a Discord bot and obtain the bot token
2. Add the bot to your Discord server with appropriate permissions
3. Configure the `config.lua` with your bot token and guild ID
4. Use the simple exports in your scripts:
   - `exports.Lofi_DiscordAPI:getAvatar(source)`
   - `exports.Lofi_DiscordAPI:getUsername(source)`
   - `exports.Lofi_DiscordAPI:hasRole(source, roleId)`
   - And more!

## Contributing

Contributions are welcome! Please submit pull requests or issues if you find bugs or have suggestions for improvement.
