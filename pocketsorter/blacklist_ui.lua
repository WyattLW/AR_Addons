-- PocketSorter blacklist management UI
-- Chest selector → category toggles + bag item block/unblock

local chestFilter = _G.PocketSorterChestFilter
local blacklist   = _G.PocketSorterBlacklist

local CATEGORY_NAMES = {
    [6]       = "Buildings",
    [7]       = "Furniture",
    [8]       = "Saplings",
    [12]      = "Potion",
    [13]      = "Food",
    [18]      = "Book",
    [20]      = "Lunastone",
    [21]      = "Livestock",
    [23]      = "Metal",
    [24]      = "Lumber",
    [25]      = "Stone Brick",
    [26]      = "Hide",
    [27]      = "Fabric",
    [28]      = "Machining",
    [31]      = "Rubber",
    [32]      = "Archeum",
    [36]      = "Cooking Oil",
    [38]      = "Ore",
    [39]      = "Hardwood",
    [40]      = "Raw Stone",
    [41]      = "Pelt",
    [42]      = "Textile",
    [45]      = "Meat",
    [46]      = "Seafood",
    [47]      = "Grain",
    [48]      = "Vegetable",
    [49]      = "Fruit",
    [51]      = "Seed",
    [52]      = "Spice",
    [53]      = "Herb",
    [55]      = "Flower",
    [56]      = "Soil",
    [58]      = "Precious Metal",
    [59]      = "Gem",
    [62]      = "Alchemy",
    [69]      = "Dagger",
    [70]      = "Sword",
    [72]      = "Katana",
    [73]      = "Axe",
    [74]      = "Club",
    [75]      = "Scepter",
    [76]      = "Shortspear",
    [77]      = "Bow",
    [79]      = "Shield",
    [80]      = "Lute",
    [81]      = "Flute",
    [83]      = "Cloth Armor",
    [84]      = "Leather Armor",
    [85]      = "Plate Armor",
    [86]      = "Necklace",
    [87]      = "Ring",
    [92]      = "Mount",
    [95]      = "Battle Pet",
    [97]      = "Drink",
    [106]     = "Key",
    [108]     = "Pet Gear",
    [109]     = "Marine Mount",
    [113]     = "Mana Potion",
    [114]     = "Defense Potion",
    [116]     = "Healing Potion",
    [118]     = "Glider",
    [121]     = "Cloak",
    [125]     = "Earring",
    [126]     = "Relic",
    [127]     = "Greatsword",
    [128]     = "Nodachi",
    [129]     = "Greataxe",
    [130]     = "Greatclub",
    [131]     = "Staff",
    [132]     = "Longspear",
    [138]     = "Coin",
    [145]     = "Fishing Rod",
    [146]     = "Taxidermy",
    [148]     = "Sheet Music",
    [150]     = "Crest & Dye",
    [152]     = "Lunagem",
    [157]     = "Armament",
    [158]     = "Steering Gear",
    [159]     = "Mast",
    [160]     = "Sail",
    [161]     = "Lighting",
    [162]     = "Boarding Equip",
    [164]     = "Navigation",
    [165]     = "Misc Apparatus",
    [166]     = "Figurehead",
    [167]     = "Storage",
    [169]     = "Sound Equipment",
    [170]     = "Ship Propellant",
    [173]     = "Synthesis Gear 1",
    [175]     = "Magithopter",
    [176]     = "Giant Pet",
    [191]     = "Pets",
    [197]     = "Powerstone Pet",
    [199]     = "Synthesis Mats",
    [200]     = "Awakening Mats",
    [203]     = "Rifle",
    [204]     = "Farmhand Equip",
    [206]     = "Mech. Components",
    [9000002] = "Boosters",
    [9000003] = "Special Material",
    [9000004] = "Livestock Products",
    [9000005] = "Ship Design",
    [9000006] = "Mach. Comp Scroll",
    [9000007] = "Ship Comp Design",
    [9000008] = "Shard",
    [9000009] = "Music Disc",
    [9000010] = "Enchant Materials",
    [9000011] = "Vehicle Comp Des.",
    [9000013] = "Feed",
    [9000014] = "Unidentified Equip",
    [9000015] = "Alchemy Oil",
    [9000016] = "Mech. Comp. Design",
    [9000017] = "Coinpurse",
    [9000018] = "Valuable Crate",
    [9000019] = "Currency",
    [9000020] = "Synthesis Gear 2",
    [9000021] = "Spec. Consumables",
    [9000022] = "Treasure Map",
    [9000023] = "Treasure Hunt Cons",
    [9000024] = "Underwater Equip",
    [9000025] = "Legendary Trophy",
    [9000026] = "Dream Design",
    [9000027] = "Art Object",
}

local WIN_W        = 480
local PAD          = 14
local MAX_CAT_VIS  = 8
local ITEM_ROW_H   = 28
local MAX_ITEM_VIS = 8
local ITEM_BTN_W   = 68

local win          = nil
local blData       = nil
local chestList    = {}
local selChest     = 1
local catPage      = 1
local itemPage     = 1
local allCats      = {}
local allItems     = {}

local chestLabel, prevChestBtn, nextChestBtn
local catHeader, catPrevBtn, catNextBtn
local catRows  = {}
local itemHeader, itemPrevBtn, itemNextBtn
local itemRows = {}

local function getChest()
    return (#chestList > 0) and chestList[selChest] or nil
end

local function isCatBlocked(chestType, catId)
    local e = blData and blData[chestType]
    return (e and e.categories and e.categories[catId]) and true or false
end

local function isItemBlocked(chestType, itemType)
    local e = blData and blData[chestType]
    return (e and e.items and e.items[itemType]) and true or false
end

local function ensureEntry(chestType)
    if not blData[chestType] then blData[chestType] = {} end
    local e = blData[chestType]
    if not e.items then e.items = {} end
    if not e.categories then e.categories = {} end
end

local function toggleCat(chestType, catId)
    ensureEntry(chestType)
    local cats = blData[chestType].categories
    if cats[catId] then cats[catId] = nil else cats[catId] = true end
    blacklist.save(blData)
end

local function toggleItem(chestType, itemType, name)
    ensureEntry(chestType)
    local items = blData[chestType].items
    if items[itemType] then items[itemType] = nil else items[itemType] = name or true end
    blacklist.save(blData)
end

local function refreshCatGrid()
    local chest  = getChest()
    local total  = #allCats
    local pages  = math.max(1, math.ceil(total / MAX_CAT_VIS))
    if catPage > pages then catPage = pages end
    local start  = (catPage - 1) * MAX_CAT_VIS + 1

    catHeader:SetText(string.format("Categories  %d/%d", catPage, pages))
    catPrevBtn:Enable(catPage > 1)
    catNextBtn:Enable(catPage < pages)

    for i = 1, MAX_CAT_VIS do
        local row = catRows[i]
        local idx = start + i - 1
        if idx <= total and chest then
            local catId  = allCats[idx]
            local name   = CATEGORY_NAMES[catId] or ("cat#"..catId)
            local blocked = isCatBlocked(chest.itemType, catId)
            row.btn:SetText(blocked and "Unblock" or "Block")
            row.btn._catId = catId
            row.label:SetText(name)
            row.btn:Show(true)
            row.label:Show(true)
        else
            row.btn:Show(false)
            row.label:Show(false)
        end
    end
end

local function refreshItemList()
    local chest  = getChest()
    local total  = #allItems
    local pages  = math.max(1, math.ceil(total / MAX_ITEM_VIS))
    if itemPage > pages then itemPage = pages end
    local start  = (itemPage - 1) * MAX_ITEM_VIS + 1

    itemHeader:SetText(string.format("Bag items & blocked (%d)  pg %d/%d", total, itemPage, pages))
    itemPrevBtn:Enable(itemPage > 1)
    itemNextBtn:Enable(itemPage < pages)

    for i = 1, MAX_ITEM_VIS do
        local row = itemRows[i]
        local idx = start + i - 1
        if idx <= total and chest then
            local item    = allItems[idx]
            local blocked = isItemBlocked(chest.itemType, item.itemType)
            row.btn:SetText(blocked and "Unblock" or "Block")
            row.btn._itemType = item.itemType
            row.btn._itemName = item.name
            row.label:SetText(item.name)
            row.btn:Show(true)
            row.label:Show(true)
        else
            row.btn:Show(false)
            row.label:Show(false)
        end
    end
end

local function rebuildLists()
    local chest = getChest()
    allCats  = {}
    allItems = {}
    if not chest then return end

    local filter = chestFilter[chest.itemType]
    if filter then
        for catId in pairs(filter) do table.insert(allCats, catId) end
        table.sort(allCats, function(a, b)
            local ab = isCatBlocked(chest.itemType, a)
            local bb = isCatBlocked(chest.itemType, b)
            if ab ~= bb then return ab end
            return a < b
        end)
    end

    if not filter then return end
    local seen = {}
    for slot = 1, 150 do
        local info = X2Bag:GetBagItemInfo(2, slot)
        if info and info.name and info.category_id and filter[info.category_id] then
            local locked = (info.securityState == 1) or info.pinned or info.locked or false
            if not locked and not seen[info.itemType] then
                seen[info.itemType] = true
                table.insert(allItems, { itemType = info.itemType, name = info.name })
            end
        end
    end

    local e = blData and blData[chest.itemType]
    if e and e.items then
        for itemType, nameOrTrue in pairs(e.items) do
            if not seen[itemType] then
                seen[itemType] = true
                local name = type(nameOrTrue) == "string" and nameOrTrue or ("item#"..itemType)
                table.insert(allItems, { itemType = itemType, name = name })
            end
        end
    end
    table.sort(allItems, function(a, b)
        local ab = isItemBlocked(chest.itemType, a.itemType)
        local bb = isItemBlocked(chest.itemType, b.itemType)
        if ab ~= bb then return ab end
        return a.name < b.name
    end)
end

local function refreshChestRow()
    local chest = getChest()
    if chest then
        chestLabel:SetText(chest.name .. " (" .. selChest .. "/" .. #chestList .. ")")
    else
        chestLabel:SetText("(no pocket chests in bag)")
    end
    local multi = #chestList > 1
    prevChestBtn:Enable(multi)
    nextChestBtn:Enable(multi)
end

local function fullRefresh()
    blData = blacklist.load()

    local prevType = getChest() and getChest().itemType
    chestList = {}
    local seen = {}
    for slot = 1, 150 do
        local info = X2Bag:GetBagItemInfo(2, slot)
        if info and info.category_id == 201 and not seen[info.itemType] then
            seen[info.itemType] = true
            table.insert(chestList, { itemType = info.itemType, name = info.name or ("Chest #"..info.itemType) })
        end
    end

    selChest = 1
    if prevType then
        for i, c in ipairs(chestList) do
            if c.itemType == prevType then selChest = i; break end
        end
    end

    catPage  = 1
    itemPage = 1
    rebuildLists()
    refreshChestRow()
    refreshCatGrid()
    refreshItemList()
end

local function CreateBlacklistWindow()
    local catGridH  = MAX_CAT_VIS * ITEM_ROW_H
    local itemGridH = MAX_ITEM_VIS * ITEM_ROW_H
    -- Sum of: top-pad + title + gap + sep + gap + chest + gap + sep + gap +
    --         cat-hdr + gap + cat-grid + gap + sep + gap + item-hdr + gap + item-grid + bottom-pad
    local WIN_H = 8 + 24 + 8 + 1 + 8 + 24 + 8 + 1 + 4 + 18 + 4
                + catGridH + 8 + 1 + 4 + 18 + 4 + itemGridH + 12

    local wnd = CreateEmptyWindow("psBlacklistWin", "UIParent")
    wnd:SetUILayer("system")
    wnd:SetExtent(WIN_W, WIN_H)
    wnd:AddAnchor("CENTER", "UIParent", 0, 0)
    wnd:EnableDrag(true)
    wnd:Enable(true)
    wnd:SetHandler("OnDragStart", function(self) self:StartMoving(); return true end)
    wnd:SetHandler("OnDragStop",  function(self) self:StopMovingOrSizing() end)
    wnd.ShowProc = function() fullRefresh() end

    local bg = wnd:CreateColorDrawable(0.06, 0.06, 0.10, 0.92, "background")
    bg:AddAnchor("TOPLEFT",     wnd, 0, 0)
    bg:AddAnchor("BOTTOMRIGHT", wnd, 0, 0)

    local y = 8

    -- ── Title row ───────────────────────────────────────────────────────────
    local titleLbl = wnd:CreateChildWidget("label", "psBLTitle", 0, true)
    titleLbl:SetText("PocketSorter — Blacklist")
    titleLbl.style:SetFontSize(13)
    titleLbl.style:SetAlign(ALIGN_LEFT)
    titleLbl:SetExtent(WIN_W - 110, 24)
    titleLbl:AddAnchor("TOPLEFT", wnd, PAD, y)

    local refreshBtn = wnd:CreateChildWidget("button", "psBLRefresh", 0, true)
    refreshBtn:SetStyle("text_default")
    refreshBtn:SetText("Refresh")
    refreshBtn:SetExtent(56, 22)
    refreshBtn:AddAnchor("TOPRIGHT", wnd, -PAD - 34, y + 1)
    refreshBtn:SetHandler("OnClick", fullRefresh)

    local closeBtn = wnd:CreateChildWidget("button", "psBLClose", 0, true)
    closeBtn:SetStyle("text_default")
    closeBtn:SetText("X")
    closeBtn:SetExtent(28, 22)
    closeBtn:AddAnchor("TOPRIGHT", wnd, -PAD, y + 1)
    closeBtn:SetHandler("OnClick", function() wnd:Show(false) end)

    y = y + 24 + 8

    -- ── Separator helper ────────────────────────────────────────────────────
    local function mkSep(yy)
        local s = wnd:CreateColorDrawable(0.35, 0.35, 0.45, 0.7, "background")
        s:SetHeight(1)
        s:AddAnchor("TOPLEFT",  wnd, PAD,  yy)
        s:AddAnchor("TOPRIGHT", wnd, -PAD, yy)
    end

    mkSep(y); y = y + 1 + 8

    -- ── Chest selector ──────────────────────────────────────────────────────
    prevChestBtn = wnd:CreateChildWidget("button", "psBLPrevChest", 0, true)
    prevChestBtn:SetStyle("text_default")
    prevChestBtn:SetText("<")
    prevChestBtn:SetExtent(24, 24)
    prevChestBtn:AddAnchor("TOPLEFT", wnd, PAD, y)
    prevChestBtn:SetHandler("OnClick", function()
        if #chestList < 2 then return end
        selChest = (selChest - 2) % #chestList + 1
        catPage = 1; itemPage = 1
        rebuildLists(); refreshChestRow(); refreshCatGrid(); refreshItemList()
    end)

    nextChestBtn = wnd:CreateChildWidget("button", "psBLNextChest", 0, true)
    nextChestBtn:SetStyle("text_default")
    nextChestBtn:SetText(">")
    nextChestBtn:SetExtent(24, 24)
    nextChestBtn:AddAnchor("TOPRIGHT", wnd, -PAD, y)
    nextChestBtn:SetHandler("OnClick", function()
        if #chestList < 2 then return end
        selChest = selChest % #chestList + 1
        catPage = 1; itemPage = 1
        rebuildLists(); refreshChestRow(); refreshCatGrid(); refreshItemList()
    end)

    chestLabel = wnd:CreateChildWidget("label", "psBLChestName", 0, true)
    chestLabel:SetText("(scanning...)")
    chestLabel.style:SetFontSize(12)
    chestLabel.style:SetAlign(ALIGN_CENTER)
    chestLabel:SetExtent(WIN_W - PAD*2 - 56, 24)
    chestLabel:AddAnchor("TOPLEFT", wnd, PAD + 28, y)

    y = y + 24 + 8
    mkSep(y); y = y + 1 + 4

    -- ── Category section ────────────────────────────────────────────────────
    catHeader = wnd:CreateChildWidget("label", "psBLCatHdr", 0, true)
    catHeader:SetText("Categories")
    catHeader.style:SetFontSize(11)
    catHeader.style:SetAlign(ALIGN_LEFT)
    catHeader:SetExtent(WIN_W - 90, 18)
    catHeader:AddAnchor("TOPLEFT", wnd, PAD, y)

    catPrevBtn = wnd:CreateChildWidget("button", "psBLCatPrev", 0, true)
    catPrevBtn:SetStyle("text_default"); catPrevBtn:SetText("<")
    catPrevBtn:SetExtent(22, 18)
    catPrevBtn:AddAnchor("TOPRIGHT", wnd, -PAD - 24, y)
    catPrevBtn:SetHandler("OnClick", function() catPage = catPage - 1; refreshCatGrid() end)

    catNextBtn = wnd:CreateChildWidget("button", "psBLCatNext", 0, true)
    catNextBtn:SetStyle("text_default"); catNextBtn:SetText(">")
    catNextBtn:SetExtent(22, 18)
    catNextBtn:AddAnchor("TOPRIGHT", wnd, -PAD, y)
    catNextBtn:SetHandler("OnClick", function() catPage = catPage + 1; refreshCatGrid() end)

    y = y + 18 + 4

    local catNameW = WIN_W - PAD*2 - ITEM_BTN_W - 29
    for i = 1, MAX_CAT_VIS do
        local by = y + (i - 1) * ITEM_ROW_H

        local btn = wnd:CreateChildWidget("button", "psBLCatBtn"..i, 0, true)
        btn:SetStyle("text_default"); btn:SetText("Block"); btn:SetExtent(ITEM_BTN_W, ITEM_ROW_H - 2)
        btn:AddAnchor("TOPLEFT", wnd, PAD, by)
        btn:Show(false)
        btn:SetHandler("OnClick", function(self)
            local chest = getChest()
            if chest and self._catId then
                toggleCat(chest.itemType, self._catId)
                refreshCatGrid()
            end
        end)

        local lbl = wnd:CreateChildWidget("label", "psBLCatLbl"..i, 0, true)
        lbl:SetText(""); lbl.style:SetFontSize(11); lbl.style:SetAlign(ALIGN_LEFT)
        lbl:SetExtent(catNameW, ITEM_ROW_H - 2)
        lbl:AddAnchor("TOPLEFT", wnd, PAD + ITEM_BTN_W + 29, by + 3)
        lbl:Show(false)
        catRows[i] = { btn = btn, label = lbl }
    end

    y = y + catGridH + 8
    mkSep(y); y = y + 1 + 4

    -- ── Bag items & blocked section ───────────────────────────────────────────────────
    itemHeader = wnd:CreateChildWidget("label", "psBLItemHdr", 0, true)
    itemHeader:SetText("Bag items & blocked")
    itemHeader.style:SetFontSize(11)
    itemHeader.style:SetAlign(ALIGN_LEFT)
    itemHeader:SetExtent(WIN_W - 90, 18)
    itemHeader:AddAnchor("TOPLEFT", wnd, PAD, y)

    itemPrevBtn = wnd:CreateChildWidget("button", "psBLItemPrev", 0, true)
    itemPrevBtn:SetStyle("text_default"); itemPrevBtn:SetText("<")
    itemPrevBtn:SetExtent(22, 18)
    itemPrevBtn:AddAnchor("TOPRIGHT", wnd, -PAD - 24, y)
    itemPrevBtn:SetHandler("OnClick", function() itemPage = itemPage - 1; refreshItemList() end)

    itemNextBtn = wnd:CreateChildWidget("button", "psBLItemNext", 0, true)
    itemNextBtn:SetStyle("text_default"); itemNextBtn:SetText(">")
    itemNextBtn:SetExtent(22, 18)
    itemNextBtn:AddAnchor("TOPRIGHT", wnd, -PAD, y)
    itemNextBtn:SetHandler("OnClick", function() itemPage = itemPage + 1; refreshItemList() end)

    y = y + 18 + 4

    local itemNameW = WIN_W - PAD*2 - ITEM_BTN_W - 29
    for i = 1, MAX_ITEM_VIS do
        local by = y + (i - 1) * ITEM_ROW_H

        local btn = wnd:CreateChildWidget("button", "psBLItemBtn"..i, 0, true)
        btn:SetStyle("text_default"); btn:SetText("Block"); btn:SetExtent(ITEM_BTN_W, ITEM_ROW_H - 2)
        btn:AddAnchor("TOPLEFT", wnd, PAD, by)
        btn:Show(false)
        btn:SetHandler("OnClick", function(self)
            local chest = getChest()
            if chest and self._itemType then
                toggleItem(chest.itemType, self._itemType, self._itemName)
                refreshItemList()
            end
        end)

        local lbl = wnd:CreateChildWidget("label", "psBLItemLbl"..i, 0, true)
        lbl:SetText(""); lbl.style:SetFontSize(11); lbl.style:SetAlign(ALIGN_LEFT)
        lbl:SetExtent(itemNameW, ITEM_ROW_H - 2)
        lbl:AddAnchor("TOPLEFT", wnd, PAD + ITEM_BTN_W + 29, by + 3)
        lbl:Show(false)
        itemRows[i] = { btn = btn, label = lbl }
    end

    return wnd
end

local function toggle()
    if not win then win = CreateBlacklistWindow() end
    if win:IsVisible() then
        win:Show(false)
    else
        win:Show(true)  -- triggers ShowProc → fullRefresh
    end
end

local function openForChest(itemType)
    if not win then win = CreateBlacklistWindow() end
    fullRefresh()
    for i, c in ipairs(chestList) do
        if c.itemType == itemType then
            selChest = i
            break
        end
    end
    catPage = 1; itemPage = 1
    rebuildLists(); refreshChestRow(); refreshCatGrid(); refreshItemList()
    win:Show(true)
end

_G.PocketSorterBlacklistUI = { toggle = toggle, openForChest = openForChest }
