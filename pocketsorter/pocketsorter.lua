-- PocketSorter
-- Entrypoint

if API_TYPE == nil then
    ADDON:ImportAPI(8)
    X2Chat:DispatchChatMessage(CMF_SYSTEM, "Globals folder not found")
    return
end

ADDON:ImportAPI(API_TYPE.CHAT.id)
ADDON:ImportAPI(API_TYPE.BAG.id)
ADDON:ImportAPI(API_TYPE.COFFER.id)
ADDON:ImportAPI(API_TYPE.BANK.id)
ADDON:ImportAPI(API_TYPE.HOTKEY.id)
ADDON:ImportAPI(API_TYPE.UNIT.id)
-- OBJECT_TYPE.WINDOW must be imported before calling CreateEmptyWindow.
-- The remaining imports are required by globals/window.lua at initialization.
ADDON:ImportObject(OBJECT_TYPE.WINDOW)
ADDON:ImportObject(OBJECT_TYPE.TEXT_STYLE)
ADDON:ImportObject(OBJECT_TYPE.BUTTON)
ADDON:ImportObject(OBJECT_TYPE.LABEL)
ADDON:ImportObject(OBJECT_TYPE.DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.NINE_PART_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.COLOR_DRAWABLE)

local scanner = _G.PocketSorterScanner
local blacklist = _G.PocketSorterBlacklist

local MOVE_DELAY    = 225  -- ms initial delay before first move in a batch
local MAX_VERIFY_MS = 350  -- ms before retrying a move
local MAX_RETRIES   = 3

local sortQueue     = {}
local sortTimer     = 0
local sortTarget    = nil
local pendingVerify = nil
local verifyTimer   = 0

local holdTimer  = 0
local HOLD_MS    = 750
local holdFired  = false

local function doStoreAll()
    local chestSlot     = nil
    local chestItemType = nil
    for slot = 1, 150 do
        local info = X2Bag:GetBagItemInfo(2, slot)
        if info and info.category_id == 201 and info.locked then
            chestSlot     = slot
            chestItemType = info.itemType
            break
        end
    end

    local filter = nil
    local label  = nil

    if chestItemType then
        local chestFilter = _G.PocketSorterChestFilter
        filter = chestFilter and chestFilter[chestItemType]
        label  = filter and "filtered" or "pocket chest"
    else
        local capacity = X2Coffer:Capacity()
        if capacity then
            local categorySet = {}
            for slot = 1, capacity do
                local info = X2Coffer:GetBagItemInfo(slot)
                if info and info.category_id then
                    categorySet[info.category_id] = true
                end
            end
            if next(categorySet) then
                filter = categorySet
                label  = "chest categories"
            end
        end
        if not label then
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Can't determine chest categories — open a chest with items first.")
            return
        end
    end

    sortQueue  = {}
    sortTarget = "coffer"
    for slot = 1, 150 do
        if slot ~= chestSlot then
            local info = X2Bag:GetBagItemInfo(2, slot)
            if info and info.name then
                if not filter or filter[info.category_id] then
                    local count = X2Bag:ItemStack(slot) or 1
                    local locked = (info.securityState == 1) or info.pinned or info.locked or false
                    if blacklist and chestItemType and blacklist.isCategoryBlocked(chestItemType, info.category_id) then
                        X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Skipping blacklisted category item: %s x%d (slot %d)", info.name, count, slot))
                    elseif blacklist and chestItemType and blacklist.isItemBlocked(chestItemType, info.itemType) then
                        X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Skipping blacklisted item: %s x%d (slot %d)", info.name, count, slot))
                    elseif locked then
                        X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Skipping locked: %s x%d (slot %d)", info.name, count, slot))
                    else
                        table.insert(sortQueue, { slot = slot, name = info.name, itemType = info.itemType, count = count })
                    end
                end
            end
        end
    end

    if #sortQueue == 0 then
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Nothing to store.")
        return
    end
    sortTimer = MOVE_DELAY
    X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Storing %s — %d item(s)...", label, #sortQueue))
end

local function doSort(target)
    local result = scanner.scan(target)
    if not result.target then
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Open a " .. target .. " first.")
        return
    end
    if #result.toSort == 0 then
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Nothing to sort into this " .. target .. ".")
        return
    end
    sortQueue  = {}
    sortTarget = result.target
    for _, item in ipairs(result.toSort) do
        table.insert(sortQueue, item)
    end
    sortTimer = MOVE_DELAY
    X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Sorting %d item(s) into %s...", #sortQueue, sortTarget))
end

-- Change keybinds here if you want to use your own:

X2Hotkey:SetBindingUiEvent("POCKETSORTER_SORT", "CTRL-S")

-- Zero-size invisible window — only exists to receive HOTKEY_ACTION and run OnUpdate.
-- Show(true) is required; a hidden window doesn't process events or ticks.
local w = CreateEmptyWindow("PocketSorter", "UIParent")
w:SetExtent(0, 0)
w:Show(true)

w:SetHandler("OnEvent", function(self, event, ...)
    if event == "HOTKEY_ACTION" then
        local actionName, keyUp = ...
        if actionName == "POCKETSORTER_SORT" then
            if not keyUp then
                if holdTimer == 0 then
                    holdTimer = HOLD_MS
                    holdFired = false
                end
            else
                if not holdFired then
                    holdTimer = 0
                    local _, _, _, _, cofferOpen = ADDON:GetContentMainScriptPosVis(UIC_COFFER)
                    local _, _, _, _, bankOpen   = ADDON:GetContentMainScriptPosVis(UIC_BANK)
                    if bankOpen then
                        doSort("bank")
                    elseif cofferOpen then
                        doSort("coffer")
                    else
                        X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Open a chest or bank first.")
                    end
                end
            end
        end
    elseif event == "CHAT_MESSAGE" then
        local channel, relation, name, message = ...
        if type(name) ~= "string" or type(message) ~= "string" then return end
        if string.sub(message, 1, 3) ~= "/ps" then return end
        if name ~= X2Unit:UnitName("player") then return end

        local tokens = {}
        for token in string.gmatch(message, "%S+") do
            table.insert(tokens, token)
        end

        if tokens[1] ~= "/ps" then return end

        local cmd = tokens[2]
        if cmd == "info" then
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Ctrl+S (press) = sort into open chest or bank")
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Ctrl+S (hold) = store all matching items into open chest")
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] ESC > System > PS Blacklist = open blacklist UI")
        end
    end
end)
w:RegisterEvent("HOTKEY_ACTION")
w:RegisterEvent("CHAT_MESSAGE")

-- OnUpdate fires every frame; dt is elapsed ms since the last frame.
-- 200ms delay between moves matches the API cooldown for both MoveToEmptyCofferSlot
-- and MoveToEmptyBankSlot.
function w:OnUpdate(dt)
    if holdTimer > 0 then
        holdTimer = holdTimer - dt
        if holdTimer <= 0 then
            holdTimer = 0
            holdFired = true
            local _, _, _, _, bankOpen = ADDON:GetContentMainScriptPosVis(UIC_BANK)
            if bankOpen then
                X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Store by pre-existing category not supported for bank.")
            else
                doStoreAll()
            end
        end
    end

    if pendingVerify then
        verifyTimer = verifyTimer + dt
        local info  = X2Bag:GetBagItemInfo(2, pendingVerify.slot)
        local moved = not info or info.itemType ~= pendingVerify.itemType

        if not moved and verifyTimer < MAX_VERIFY_MS then return end

        if not moved then
            if pendingVerify.tries < MAX_RETRIES then
                pendingVerify.tries = pendingVerify.tries + 1
                if sortTarget == "bank" then
                    X2Bag:MoveToEmptyBankSlot(pendingVerify.slot)
                else
                    X2Bag:MoveToEmptyCofferSlot(pendingVerify.slot)
                end
                verifyTimer = 0
                return
            end
            X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Failed: %s (slot %d)", pendingVerify.name, pendingVerify.slot))
        else
            X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("[PocketSorter] Moved: %s x%d (slot %d)", pendingVerify.name, pendingVerify.count, pendingVerify.slot))
        end
        pendingVerify = nil

        if #sortQueue == 0 then
            sortTarget = nil
            sortTimer  = 0
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "[PocketSorter] Done.")
            return
        end
        sortTimer = 0
    end

    if #sortQueue == 0 then return end
    sortTimer = sortTimer - dt
    if sortTimer > 0 then return end

    local item = table.remove(sortQueue, 1)
    if sortTarget == "bank" then
        X2Bag:MoveToEmptyBankSlot(item.slot)
    else
        X2Bag:MoveToEmptyCofferSlot(item.slot)
    end
    pendingVerify = { slot = item.slot, name = item.name, itemType = item.itemType, count = item.count, tries = 0 }
    verifyTimer   = 0
end
w:SetHandler("OnUpdate", w.OnUpdate)

-- Two floating buttons on the coffer window, stacked above the refresh button.
-- Tweak BTN_BOTTOM/GAP if the position is off.
local BTN_W      = 120
local BTN_H      = 26
local BTN_LEFT   = 20   -- px from left edge of coffer window
local BTN_BOTTOM = 70   -- px from bottom edge

local function CreateCofferButtons()
    local frame = UIParent:CreateWidget("window", "psCofferBtns", "UIParent")
    frame:SetUILayer("hud")
    frame:SetExtent(BTN_W, BTN_H * 2 + 4)
    frame:Show(true)

    local btnExisting = frame:CreateChildWidget("button", "psBtnExisting", 0, true)
    btnExisting:SetStyle("text_default")
    btnExisting:SetText("Store Existing")
    btnExisting:SetExtent(BTN_W, BTN_H)
    btnExisting:AddAnchor("TOPLEFT", frame, 0, 0)
    btnExisting:SetHandler("OnClick", function() doSort("coffer") end)

    local btnAll = frame:CreateChildWidget("button", "psBtnAll", 0, true)
    btnAll:SetStyle("text_default")
    btnAll:SetText("Store Everything")
    btnAll:SetExtent(BTN_W, BTN_H)
    btnAll:AddAnchor("TOPLEFT", frame, 0, BTN_H + 4)
    btnAll:SetHandler("OnClick", function() doStoreAll() end)

    local blFrame = UIParent:CreateWidget("window", "psCofferBLBtn", "UIParent")
    blFrame:SetUILayer("hud")
    blFrame:SetExtent(BTN_W, BTN_H)
    blFrame:Show(false)

    local btnBlacklist = blFrame:CreateChildWidget("button", "psBtnBlacklist", 0, true)
    btnBlacklist:SetStyle("text_default")
    btnBlacklist:SetText("Blacklist Settings")
    btnBlacklist:SetExtent(BTN_W, BTN_H)
    btnBlacklist:AddAnchor("TOPLEFT", blFrame, 0, 0)
    btnBlacklist:SetHandler("OnClick", function()
        local ui = _G.PocketSorterBlacklistUI
        if not ui then return end
        for slot = 1, 150 do
            local info = X2Bag:GetBagItemInfo(2, slot)
            if info and info.category_id == 201 and info.locked then
                ui.openForChest(info.itemType)
                return
            end
        end
    end)

    local hiding   = false
    local wasOpen  = false
    local isPocket = false
    frame:SetHandler("OnUpdate", function()
        local x, y, w, h, visible = ADDON:GetContentMainScriptPosVis(UIC_COFFER)
        if visible then
            if not wasOpen then
                wasOpen  = true
                isPocket = false
                for slot = 1, 150 do
                    local info = X2Bag:GetBagItemInfo(2, slot)
                    if info and info.category_id == 201 and info.locked then
                        isPocket = true
                        break
                    end
                end
            end
            frame:AddAnchor("TOPLEFT", "UIParent", x + BTN_LEFT, y + h - BTN_BOTTOM)
            hiding = false
            if isPocket then
                blFrame:AddAnchor("TOPLEFT", "UIParent", x + math.floor((w - BTN_W) / 2), y + h - BTN_H - 8)
                blFrame:Show(true)
            end
        else
            wasOpen = false
            if not hiding then
                frame:AddAnchor("TOPLEFT", "UIParent", "BOTTOMRIGHT", 100, 100)
                blFrame:Show(false)
                hiding = true
            end
        end
    end)
end

CreateCofferButtons()

X2:AddEscMenuButton(5, 9001, "bag", "PS Blacklist")
ADDON:RegisterContentTriggerFunc(9001, function()
    local ui = _G.PocketSorterBlacklistUI
    if ui then ui.toggle() end
end)

X2Chat:DispatchChatMessage(CMF_SYSTEM, "PocketSorter by Wyatt_LW Loaded! Type /ps info.")
