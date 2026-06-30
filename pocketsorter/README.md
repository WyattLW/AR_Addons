# PocketSorter v1.5

**Author:** Wyatt LW (Discord: wyatt_landwalker)

A lightweight ArcheRage addon for automatically sorting and organizing inventory into open storage containers.

## Description

Have you ever finished a farming or a crafting session and find yourself with a messy inventory?
That's a past problem, you open chest, press a button, and that's it! Clean inventory!

Pocketsorter lets you automatically store items in chests / pocket chests / warehouse etc.

## Features

- **Storage type detection** - It automatically understands what type of storage you have open!
- **Smart sort** - matches items by type (ID), not just names (should work for other languages)
- **Store pre-existing** - Automatically checks items in a chest and fills it with same items from your inventory.
- **Store everything** - Store everything that can fit in a pocket chest from your inventory, normal chest is checked for same category items, warehouses is guarded.
- **Blacklist manager** - in-game UI to block specific item types or entire categories from being moved (Each pocket-chest has its own blacklist)
- **Locked item** - Skips pinned and locked items so you can keep your inventory organized how you prefer.
- **Store buttons** - Buttons on pocket chest window for quick sorting
- **ESC menu integration** - access blacklist UI from ESC > System > PS Blacklist

## Usage

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+S` (press) | Sort into open chest, warehouse, or bank |
| `Ctrl+S` (hold ~750ms) | Store all matching items by pre-existing category |

Keybinds can be customized in `pocketsorter.lua`.

### Pocket Chest Buttons

<img width="428" height="329" alt="immagine" src="https://github.com/user-attachments/assets/c7a1dd2a-be80-41e1-91cf-3c532860cb99" />


When a pocket chest is open, three buttons appear:

- **Store Existing** - sort items matching chest contents (same as `Ctrl+S` press)
- **Store Everything** - store all items by pre-existing chest categories (same as `Ctrl+S` hold)
- **Blacklist Settings** - open the blacklist UI for the open chest

### Blacklist Management

<img width="478" height="563" alt="immagine" src="https://github.com/user-attachments/assets/687ccca7-fab6-47ff-845d-33c5a17dc1f8" />

Open **ESC > System > PS Blacklist** to access the blacklist UI:

1. **Chest Selector** - choose which pocket chest to manage (if you have multiple)
2. **Categories Section** - view categories accepted by the chest; click **Block** or **Unblock** to prevent entire categories from being stored
3. **Bag Items Section** - list of items in your bag that match the chest's categories; click **Block** or **Unblock** to control individual items

Blocked items and categories are saved automatically per chest.

## Known Issues

- **Storage closes mid-sort:** If the UI closes after a move, the API may cache stale data; no items are lost, but retry manually
- **Bound/Unbound items:** If the chest has an unbound item and you have a bound version, PocketSorter may attempt to transfer it (lock the item to prevent)
- **Multiple duplicate pocket chest:** Currently differentiates chests by itemType only; if you have identical pocket chests, blacklists apply to all of them

## Changelog

### v1.5 - 2026-06-26 CET

- Blacklist UI: ESC > System > PS Blacklist opens a window
  - Chest selector (< >) scans bag for pocket chests
  - Categories section: shows categories accepted by the chest, click to block/unblock
  - Bag items section: shows bag items matching the chest's categories or previously blacklisted items, click Block/Unblock
  - Paged (< >) for both categories and items
- Simplified blacklist.lua to load/save/isBlacklisted (removed chat commands)

### v1.4 - 2026-06-26 CET

- Reduced hold-to-store duration from 1500ms to 750ms
- Added "Store All" button that appears on the pocket chest window

### v1.3 - 2026-05-26 17:32:42 CET

- Matching items by itemType ID instead of name
- Better lock detection

### v1.2 - 2026-05-25 20:00:39 CET

- Also works with warehouse
- Split commands in two separate hotkeys
- Removed sort button from ui

### v1.1 - 2026-05-25 18:25:46 CET

- Avoids pinned items

### v1.0 - 2026-05-25 17:10:35 CET

- Basic version that compares via name

## Support

For bugs, feature requests, or questions:

- Discord: wyatt_landwalker
- GitHub: [WyattLW/AR_Addons](https://github.com/WyattLW/AR_Addons)
