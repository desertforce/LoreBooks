LoreBooks = LoreBooks or {}

local c = {}
LoreBooks.Constants = c

--Local constants -------------------------------------------------------------
c.ADDON_NAME = "LoreBooks"
c.ADDON_AUTHOR = "Ayantir, Garkin & Kyoma"
c.ADDON_VERSION = "25"
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

c.icon_list_zoneid = {
  [281] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- balfoyen_base_0
  [280] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- bleakrock_base_0
  [57] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- deshaan_base_0
  [101] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- eastmarch_base_0
  [117] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- shadowfen_base_0
  [41] ="/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- stonefalls_base_0
  [103] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- therift_base_0
  [104] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- alikr_base_0
  [92] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- bangkorai_base_0
  [535] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- betnihk_base_0
  [3] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- glenumbra_base_0
  [20] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- rivenspire_base_0
  [19] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- stormhaven_base_0
  [534] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- strosmkai_base_0
  [381] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- auridon_base_0
  [383] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- grahtwood_base_0
  [108] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- greenshade_base_0
  [537] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- khenarthisroost_base_0
  [58] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- malabaltor_base_0
  [382] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- reapersmarch_base_0
  [1027] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- artaeum_base_0
  [1208] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- u28_blackreach_base_0
  [1161] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- blackreach_base_0
  [1261] = "/esoui/art/icons/housing_bad_fur_housingleybookcasetallfilled001.dds", -- blackwood_base_0
  [980] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- clockwork_base_0
  [981] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- brassfortress_base_0
  [982] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- clockworkoutlawsrefuge_base_0
  [347] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- coldharbour_base_0
  [888] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- craglorn_base_0
  [2119] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- The zone - using mapId
  [1282] = "/esoui/art/icons/housing_bad_fur_dedlargebookshelves001.dds", -- Fargrave City - using zoneId
  [2082] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- The Shambles - using mapId
  [823] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- goldcoast_base_0
  [816] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- hewsbane_base_0
  [726] = "/esoui/art/icons/housing_arg_fur_mrkshelftall001.dds", -- murkmire_base_0
  [1086] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- elsweyr_base_0
  [1133] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- southernelsweyr_base_0
  [1011] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- summerset_base_0
  [1286] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- u32deadlandszone_base_0
  [1207] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- reach_base_0
  [849] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- vvardenfell_base_0
  -- /esoui/art/icons/housing_skr_fur_vampirebookcase001.dds vampire style
  [1160] = "/esoui/art/icons/housing_skr_fur_housingbookshelffancyfilled003.dds", -- westernskryim_base_0
  [684] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- wrothgar_base_0
  [181] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- ava_whole_0
  [584] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- imperialcity_base_0
  [267] = "/esoui/art/icons/housing_coh_inc_housingbookcase001.dds", -- eyevea_base_0
}
