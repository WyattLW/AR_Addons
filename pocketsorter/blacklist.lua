local blacklist = {}
local SAVE_KEY  = "ps_blacklist"
local _cache    = nil

function blacklist.load()
    _cache = ADDON:LoadData(SAVE_KEY) or {}
    return _cache
end

function blacklist.save(data)
    _cache = data
    ADDON:SaveData(SAVE_KEY, data)
end

function blacklist.isCategoryBlocked(chestType, categoryId)
    if not _cache then _cache = ADDON:LoadData(SAVE_KEY) or {} end
    local e = _cache[chestType]
    return (e and categoryId and e.categories and e.categories[categoryId]) and true or false
end

function blacklist.isItemBlocked(chestType, itemType)
    if not _cache then _cache = ADDON:LoadData(SAVE_KEY) or {} end
    local e = _cache[chestType]
    return (e and e.items and e.items[itemType]) and true or false
end

_G.PocketSorterBlacklist = blacklist
return blacklist
