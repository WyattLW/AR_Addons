-- Maps pocket chest itemType to the set of category_ids it accepts.
-- Multiple chests can share the same category_id.

local CHEST_FILTER = {

    -- Adventurer's Chest (confirmed itemType from dump)
    [9003195] = {
        [138]     = true,  -- COIN
        [9000017] = true,  -- COINPURSE
        [9000019] = true,  -- CURRENCY
        [106]     = true,  -- KEY
        [9000016] = true,  -- MECHANICAL_COMPONENT_DESIGN_BAG
        [9000018] = true,  -- VALUABLE_CRATE
    },

    -- Alchemist's Chest
    [9002085] = {
        [9000015] = true,  -- ALCHEMY_OIL
        [62]      = true,  -- ALCHEMY
        [32]      = true,  -- ARCHEUM
        [53]      = true,  -- HERB
        [9000003] = true,  -- SPECIAL_MATERIAL
    },

    -- Animal Breeder's Chest (50-slot: 9002044)
    [9002044] = {
        [36]      = true,  -- COOKING_OIL
        [9000013] = true,  -- FEED
        [9000004] = true,  -- LIVESTOCK_PRODUCTS
        [45]      = true,  -- MEAT
        [41]      = true,  -- PELT
        [46]      = true,  -- SEAFOOD
        [9000021] = true,  -- SPECIAL_CONSUMABLES
        [42]      = true,  -- TEXTILE
    },

    -- Artisan's Chest (50-slot: 9002037)
    [9002037] = {
        [27]      = true,  -- FABRIC
        [59]      = true,  -- GEM
        [39]      = true,  -- HARDWOOD
        [26]      = true,  -- HIDE
        [24]      = true,  -- LUMBER
        [23]      = true,  -- METAL
        [38]      = true,  -- ORE
        [41]      = true,  -- PELT
        [58]      = true,  -- PRECIOUS_METAL
        [40]      = true,  -- RAW_STONE
        [31]      = true,  -- RUBBER
        [9000003] = true,  -- SPECIAL_MATERIAL
        [25]      = true,  -- STONE_BRICK
        [42]      = true,  -- TEXTILE
    },

    -- Builder's Chest
    [9003579] = {
        [6] = true,  -- BUILDINGS
    },

    -- Design Chest (50/70-slot: 52575, 52576, 8002823, 8003453 | 100-slot: 9004339)
    [52575] = { [150] = true },  -- CREST_AND_DYE_ITEMS
    [52576] = { [150] = true },
    [8002822] = { [150] = true },
    [8002823] = { [150] = true },
    [8003453] = { [150] = true },
    [9004339] = { [150] = true },

    -- Dream Designer's Chest
    [9004236] = {
        [9000027] = true,  -- ART_OBJECT
        [9000026] = true,  -- DREAM_DESIGN
    },

    -- Equipment Enhancement Chest
    [9001640] = {
        [200]     = true,  -- AWAKENING_MATERIALS
        [9000010] = true,  -- ENCHANCEMENT_MATERIALS
        [152]     = true,  -- LUNAGEM
        [20]      = true,  -- LUNASTONE
        [199]     = true,  -- SYNTHESIS_MATERIALS
    },

    -- Equipment Material Chest (50-slot: 50259)
    [50258] = {
        [200] = true,  -- AWAKENING_MATERIALS
        [199] = true,  -- SYNTHESIS_MATERIALS
    },
    [50259] = {
        [200] = true,
        [199] = true,
    },

    -- Farmer's Large Chest
    [9002035] = {
        [55]      = true,  -- FLOWER
        [49]      = true,  -- FRUIT
        [47]      = true,  -- GRAIN
        [53]      = true,  -- HERB
        [9000004] = true,  -- LIVESTOCK_PRODUCTS
        [21]      = true,  -- LIVESTOCK
        [45]      = true,  -- MEAT
        [41]      = true,  -- PELT
        [8]       = true,  -- SAPLINGS
        [46]      = true,  -- SEAFOOD
        [51]      = true,  -- SEED
        [56]      = true,  -- SOIL
        [9000021] = true,  -- SPECIAL_CONSUMABLES
        [9000003] = true,  -- SPECIAL_MATERIAL
        [52]      = true,  -- SPICE
        [42]      = true,  -- TEXTILE
        [48]      = true,  -- VEGETABLE
    },

    -- Fisherman's Chest
    [9003735] = {
        [145]     = true,  -- FISHING_ROD
        [46]      = true,  -- SEAFOOD
        [9000021] = true,  -- SPECIAL_CONSUMABLES
        [9000024] = true,  -- UNDERWATER_EQUIPMENT
    },

    -- Flutter Vessel (base: 46158 | 50-slot: 47222 | 70-slot: 49454)
    [46158] = {
        [118] = true,  -- GLIDER
        [175] = true,  -- MAGITHOPTER
    },
    [47222] = {
        [118] = true,
        [175] = true,
    },
    [49454] = {
        [118] = true,
        [175] = true,
    },

    -- Furniture Chest (base: 47192 | 50-slot: 47224 | 70-slot: 47452 | 100-slot: 9004014)
    [47192] = {
        [7]   = true,  -- FURNITURE
        [146] = true,  -- TAXIDERMY
    },
    [47224] = {
        [7]   = true,
        [146] = true,
    },
    [47452] = {
        [7]   = true,
        [146] = true,
    },
    [9004014] = {
        [7]   = true,
        [146] = true,
    },

    -- Gear Chest
    [9001803] = {
        [73]      = true,  -- AXE
        [77]      = true,  -- BOW
        [121]     = true,  -- CLOAK
        [83]      = true,  -- CLOTH_ARMOR
        [74]      = true,  -- CLUB
        [69]      = true,  -- DAGGER
        [125]     = true,  -- EARRING
        [204]     = true,  -- FARMHAND_EQUIPMENT
        [145]     = true,  -- FISHING_ROD
        [81]      = true,  -- FLUTE
        [129]     = true,  -- GREATAXE
        [130]     = true,  -- GREATCLUB
        [127]     = true,  -- GREATSWORD
        [72]      = true,  -- KATANA
        [84]      = true,  -- LEATHER_ARMOR
        [132]     = true,  -- LONGSPEAR
        [80]      = true,  -- LUTE
        [86]      = true,  -- NECKLACE
        [128]     = true,  -- NODACHI
        [108]     = true,  -- PET_GEAR
        [85]      = true,  -- PLATE_ARMOR
        [203]     = true,  -- RIFLE
        [87]      = true,  -- RING
        [75]      = true,  -- SCEPTER
        [79]      = true,  -- SHIELD
        [76]      = true,  -- SHORTSPEAR
        [131]     = true,  -- STAFF
        [70]      = true,  -- SWORD
        [173]     = true,  -- SYNTHESIS_GEAR_1
        [9000020] = true,  -- SYNTHESIS_GEAR_2
        [9000024] = true,  -- UNDERWATER_EQUIPMENT
        [9000014] = true,  -- UNIDENTIFIED_EQUIPMENT
    },

    -- Instrument Chest (50-slot: 52577 | 70-slot: 52578, 8003452)
    [52577] = {
        [81] = true,  -- FLUTE
        [80] = true,  -- LUTE
    },
    [52578] = {
        [81] = true,
        [80] = true,
    },
    [8003452] = {
        [81] = true,
        [80] = true,
    },

    -- Librarian's Chest
    [9004156] = {
        [18] = true,  -- BOOK
    },

    -- Machine's Chest
    [9002065] = {
        [157]     = true,  -- ARMAMENT
        [162]     = true,  -- BOARDING_EQUIPMENT
        [166]     = true,  -- FIGUREHEAD
        [161]     = true,  -- LIGHTING
        [9000006] = true,  -- MACHINE_COMPONENT_SCROLL
        [28]      = true,  -- MACHINING
        [159]     = true,  -- MAST
        [9000016] = true,  -- MECHANICAL_COMPONENT_DESIGN_BAG
        [206]     = true,  -- MECHANICAL_COMPONENTS
        [165]     = true,  -- MISC_APPARATUS
        [9000009] = true,  -- MUSIC_DISC
        [164]     = true,  -- NAVIGATION
        [160]     = true,  -- SAIL
        [9000007] = true,  -- SHIP_COMPONENT_DESIGN
        [9000005] = true,  -- SHIP_DESIGN
        [170]     = true,  -- SHIP_PROPELLANT
        [169]     = true,  -- SOUND_EQUIPMENT
        [158]     = true,  -- STEERING_GEAR
        [167]     = true,  -- STORAGE
        [9000011] = true,  -- VEHICLE_COMPONENT_DESIGN
    },

    -- Music Chest (50-slot: 8002819, 49449 | 70-slot: 47256, 49450 | 100-slot: 9004012)
    [8002819] = {
        [9000009] = true,  -- MUSIC_DISC
        [148]     = true,  -- SHEET_MUSIC
    },
    [47256] = {
        [9000009] = true,
        [148]     = true,
    },
    [49449] = {
        [9000009] = true,
        [148]     = true,
    },
    [49450] = {
        [9000009] = true,
        [148]     = true,
    },
    [9004012] = {
        [9000009] = true,
        [148]     = true,
    },

    -- Pet Collector's Trunk
    [9001679] = {
        [95]  = true,  -- BATTLE_PET
        [191] = true,  -- PETS
        [197] = true,  -- POWERSTONE_PET
    },

    -- Rider's Trunk (base: 45872 | 50-slot: 47221 | 70-slot: 49453 | 100-slot: 9004350)
    [45872] = {
        [176] = true,  -- GIANT_PET
        [109] = true,  -- MARINE_MOUNT
        [92]  = true,  -- MOUNT
    },
    [47221] = {
        [176] = true,
        [109] = true,
        [92]  = true,
    },
    [49453] = {
        [176] = true,
        [109] = true,
        [92]  = true,
    },
    [9004350] = {
        [176] = true,
        [109] = true,
        [92]  = true,
    },

    -- Shard Collector's Chest (30-slot: 9002328 | 50-slot: 9002435 | 70-slot: 9003742 | 100-slot: 9003743)
    [9002328] = {
        [9000008] = true,  -- SHARD
    },
    [9002435] = {
        [9000008] = true,
    },
    [9003742] = {
        [9000008] = true,
    },
    [9003743] = {
        [9000008] = true,
    },

    -- Traveler Necessities Chest
    [9001725] = {
        [9000002] = true,  -- BOOSTERS
        [114]     = true,  -- DEFENSE_POTION
        [97]      = true,  -- DRINK
        [13]      = true,  -- FOOD
        [116]     = true,  -- HEALING_POTION
        [113]     = true,  -- MANA_POTION
        [12]      = true,  -- POTION
        [9000021] = true,  -- SPECIAL_CONSUMABLES
    },

    -- Treasure Hunter's Chest
    [9003693] = {
        [126]     = true,  -- RELIC
        [9000023] = true,  -- TREASURE_HUNTERS_CONSUMABLES
        [9000022] = true,  -- TREASURE_MAP
    },

    -- Trophy Hunter's Chest
    [9004044] = {
        [9000025] = true,  -- LEGENDARY_TROPHY
    },
}

_G.PocketSorterChestFilter = CHEST_FILTER
return CHEST_FILTER
