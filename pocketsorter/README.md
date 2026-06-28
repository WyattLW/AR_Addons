# PocketSorter v1.5

**Author:** Wyatt LW (Discord: wyatt_landwalker)

A lightweight ArcheRage addon for automatically sorting and organizing inventory into open storage containers.

## What It Does

PocketSorter lets you automatically "stack" items from your inventory into open storage, but only items that **already exist** in that storage. No more manual sorting after looting or farming.

**Simple example:**

- Just finished a rift and got coinpurses and gildastars
- Open your pocket chest that already has those items
- Press `Ctrl+S` → they're automatically moved to the chest
- Works with pocket chests, warehouses, and banks

## Features

- **Smart sort** - matches items by type (ID), not just name (should work for other languages)
- **Press or hold** - Press `Ctrl+S` to sort into open chest/warehouse, hold to store all matching items
- **Blacklist manager** - in-game UI to block specific item types or entire categories from being moved
- **Locked item safety** - ignores pinned and locked items (no accidental transfers)
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

When a pocket chest is open, three buttons appear:

- **Store Existing** - sort items matching chest contents (same as `Ctrl+S` press)
- **Store Everything** - store all items by pre-existing chest categories (same as `Ctrl+S` hold)
- **Blacklist Settings** - open the blacklist UI for the open chest

### Blacklist Management

Open **ESC > System > PS Blacklist** to access the blacklist UI:

1. **Chest Selector** - choose which pocket chest to manage (if you have multiple)
2. **Categories Section** - view categories accepted by the chest; click **Block** or **Unblock** to prevent entire categories from being stored
3. **Bag Items Section** - list of items in your bag that match the chest's categories; click **Block** or **Unblock** to control individual items

Blocked items and categories are saved automatically per chest.

## Installation

1. Extract `pocketsorter/` into your ArcheRage Addon folder
2. Restart ArcheRage
3. Check ESC > Addons > PocketSorter enabled

**API Requirement:** The addon requires ArcheRage API Type 8 or compatible. Check your logs if the addon doesn't load.

## Known Issues

- **Warehouse:** Only works after right-clicking the NPC to open it (interacting with F doesn't work due to server limitations)
- **Anywhere warehouse:** Not supported (server limitation)
- **Storage closes mid-sort:** If the UI closes after a move, the API may cache stale data; no items are lost, but retry manually
- **Bound vs. Unbound:** If the chest has an unbound item and you have a bound version, PocketSorter may attempt to transfer it (lock the item to prevent)
- **Multiple duplicate chests:** Currently differentiates chests by itemType only; if you have identical pocket chests, blacklists apply to all of them

## Technical Details

### How It Works

1. Scans the open storage container for item types
2. Searches your inventory for items of the same type
3. Moves matching items one by one (with 225ms delays to respect server cooldowns)
4. Skips locked, pinned, and blacklisted items
5. Reports progress in system chat

### Module Architecture

- **pocketsorter.lua** - main hotkey handler, storage logic, UI buttons
- **scanner.lua** - scans storage containers and inventory, matches items by type
- **blacklist.lua** - manages blacklist data (load/save, query functions)
- **blacklist_ui.lua** - in-game UI for blacklist management with chest/category/item pages
- **chest_filter.lua** - category filters for each pocket chest type

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Addon not loading | Check `ArcheRage.log` for API errors; ensure API Type is available |
| Items not moving | Check if items are locked or pinned; verify blacklist isn't blocking them |
| Buttons don't appear | Close and reopen the pocket chest; buttons only render when the window is active |
| Wrong items moved | Check blacklist settings; individual items may be mistakenly unblocked |

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
