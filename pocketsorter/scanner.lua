-- Scanner — reads open storage and finds matching inventory items.
-- Pocket chests use X2Coffer; warehouse uses X2Bank.
-- scan(target) takes an explicit "coffer" or "bank" target — no auto-detection.

local scanner = {}

function scanner.scanCoffer()
    local capacity = X2Coffer:Capacity()
    if not capacity then return {} end
    local idSet = {}
    for slot = 1, capacity do
        local info = X2Coffer:GetBagItemInfo(slot)
        if info and info.itemType then
            idSet[info.itemType] = true
        end
    end
    return idSet
end

function scanner.scanBank()
    local capacity = X2Bank:Capacity()
    if not capacity then return {} end
    local idSet = {}
    for slot = 1, capacity do
        local info = X2Bank:GetBagItemInfo(slot)
        if info and info.itemType then
            idSet[info.itemType] = true
        end
    end
    return idSet
end

-- securityState==1 means locked in-game (2 = unlocked). info.locked is always false
-- but kept as a safety net in case of unknown edge cases.
function scanner.scanInventory()
    local items = {}
    for slot = 1, 150 do
        local info = X2Bag:GetBagItemInfo(2, slot)
        if info and info.name then
            table.insert(items, {
                slot       = slot,
                name       = info.name,
                itemType   = info.itemType,
                category_id = info.category_id,
                count      = X2Bag:ItemStack(slot) or 1,
                maxStack   = info.maxStack or 1,
                locked     = (info.securityState == 1) or info.pinned or info.locked or false,
            })
        end
    end
    return items
end

-- Returns:
--   target   string|nil  — echoes the requested target, or nil if container has no data
--   toSort   list        — inventory items whose itemType exists in the target storage
function scanner.scan(target)
    local targetItems = target == "bank" and scanner.scanBank() or scanner.scanCoffer()
    local blacklist = _G.PocketSorterBlacklist

    local toSort = {}
    if next(targetItems) ~= nil then
        local chestType = scanner.detectChestType(target)
        for _, item in ipairs(scanner.scanInventory()) do
            if targetItems[item.itemType] then
                if blacklist and chestType and blacklist.isCategoryBlocked(chestType, item.category_id) then
                    X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Skipping blacklisted category item: %s x%d (slot %d)", item.name, item.count, item.slot))
                elseif blacklist and chestType and blacklist.isItemBlocked(chestType, item.itemType) then
                    X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Skipping blacklisted item: %s x%d (slot %d)", item.name, item.count, item.slot))
                elseif item.locked then
                    X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Skipping locked: %s x%d (slot %d)", item.name, item.count, item.slot))
                else
                    table.insert(toSort, item)
                end
            end
        end
    end

    return { target = next(targetItems) ~= nil and target or nil, toSort = toSort }
end

function scanner.detectChestType(target)
    if target == "bank" then return nil end
    for slot = 1, 150 do
        local info = X2Bag:GetBagItemInfo(2, slot)
        if info and info.category_id == 201 and info.locked then
            return info.itemType
        end
    end
    return nil
end

_G.PocketSorterScanner = scanner
return scanner
