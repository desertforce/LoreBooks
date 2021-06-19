LoreBooks = LoreBooks or {}

local c = {}
LoreBooks.Constants = c

--Local constants -------------------------------------------------------------
c.ADDON_NAME = "LoreBooks"
c.ADDON_AUTHOR = "Ayantir, Garkin & Kyoma"
c.ADDON_VERSION = "24"
c.ADDON_WEBSITE = "http://www.esoui.com/downloads/info288-LoreBooks.html"
c.ADDON_PANEL = "LoreBooksPanel"


-- Pins
c.PINS_UNKNOWN = "LBooksMapPin_unknown"
c.PINS_COLLECTED = "LBooksMapPin_collected"
c.PINS_EIDETIC = "LBooksMapPin_eidetic"
c.PINS_EIDETIC_COLLECTED = "LBooksMapPin_eideticCollected"
c.PINS_COMPASS = "LBooksCompassPin_unknown"
c.PINS_COMPASS_EIDETIC = "LBooksCompassPin_eidetic"

-- Pin Textures
c.PIN_ICON_REAL = 1
c.PIN_ICON_SET1 = 2
c.PIN_ICON_SET2 = 3
c.PIN_ICON_ESOHEAD = 4
c.PIN_TEXTURES = {
  [c.PIN_ICON_REAL] = { "EsoUI/Art/Icons/lore_book4_detail4_color5.dds", "EsoUI/Art/Icons/lore_book4_detail4_color5.dds" },
  [c.PIN_ICON_SET1] = { "LoreBooks/Icons/book1.dds", "LoreBooks/Icons/book1-invert.dds" },
  [c.PIN_ICON_SET2] = { "LoreBooks/Icons/book2.dds", "LoreBooks/Icons/book2-invert.dds" },
  [c.PIN_ICON_ESOHEAD] = { "LoreBooks/Icons/book3.dds", "LoreBooks/Icons/book3-invert.dds" },
}
c.MISSING_TEXTURE = "/esoui/art/icons/icon_missing.dds"
c.PLACEHOLDER_TEXTURE = "/esoui/art/icons/lore_book4_detail1_color2.dds"


-- Immersive Modes
c.IMMERSIVE_DISABLED = 1
c.IMMERSIVE_MAINQUEST = 2
c.IMMERSIVE_WAYSHRINES = 3
c.IMMERSIVE_EXPLORATION = 4
c.IMMERSIVE_ZONEQUESTS = 5

c.zone_names_list = {
  [281] = "balfoyen_base_0",
  [280] = "bleakrock_base_0",
  [57] = "deshaan_base_0",
  [101] = "eastmarch_base_0",
  [117] = "shadowfen_base_0",
  [41] = "stonefalls_base_0",
  [103] = "therift_base_0",
  [104] = "alikr_base_0",
  [92] = "bangkorai_base_0",
  [535] = "betnihk_base_0",
  [3] = "glenumbra_base_0",
  [20] = "rivenspire_base_0",
  [19] = "stormhaven_base_0",
  [534] = "strosmkai_base_0",
  [381] = "auridon_base_0",
  [383] = "grahtwood_base_0",
  [108] = "greenshade_base_0",
  [537] = "khenarthisroost_base_0",
  [58] = "malabaltor_base_0",
  [382] = "reapersmarch_base_0",
  [1027] = "artaeum_base_0",
  [1208] = "u28_blackreach_base_0", -- Arkthzand
  [1161] = "blackreach_base_0", -- Greymoor
  [1261] = "blackwood_base_0",
  [980] = "clockwork_base_0",
  [981] = "brassfortress_base_0",
  [982] = "clockworkoutlawsrefuge_base_0",
  [347] = "coldharbour_base_0",
  [888] = "craglorn_base_0",
  [1283] = "u32_fargravezone_base_0", -- The zone
  [1282] = "u32_fargrave_base_0", -- Fargrave City
  [1283] = "u32_theshambles_base_0", -- The Shambles
  [823] = "goldcoast_base_0",
  [816] = "hewsbane_base_0",
  [726] = "murkmire_base_0",
  [1086] = "elsweyr_base_0",
  [1133] = "southernelsweyr_base_0",
  [1011] = "summerset_base_0",
  [1286] = "u32deadlandszone_base_0",
  [1207] = "reach_base_0",
  [849] = "vvardenfell_base_0",
  [1160] = "westernskryim_base_0",
  [684] = "wrothgar_base_0",
  [181] = "ava_whole_0",
  [584] = "imperialcity_base_0",
  [267] = "eyevea_base_0",
}
