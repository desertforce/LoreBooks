----------------------------------------
-- Russian localization for LoreBooks --
----------------------------------------
--
-- Translated by:
-- @KiriX (http://www.esoui.com/forums/member.php?u=105)

SafeAddString(LBOOKS_QUEST_BOOK, "Book available through a quest", 1)
SafeAddString(LBOOKS_MAYBE_NOT_HERE, "[Book is maybe not here]", 1)
SafeAddString(LBOOKS_QUEST_IN_ZONE, "Quest in <<1>>", 1)
SafeAddString(LBOOKS_SPECIAL_QUEST, "Special quest in <<1>>", 1)
SafeAddString(LBOOKS_LBPOS_OPEN_BOOK, "You must be reading a book to use /lbpos", 1)
SafeAddString(LBOOKS_LBPOS_ERROR, "Crafting Book or no relation to Eidetic Memory or Shalidor's Library.", 1)
SafeAddString(LBOOKS_PIN_UPDATE, "Please Help Update", 1)

--Camera Actions
SafeAddString(LBOOKS_CLIMB, "Climb", 1)


--tooltips
SafeAddString(LBOOKS_KNOWN, "Собрано", 1)
SafeAddString(LBOOKS_BOOKSHELF, "Bookshelf", 1)

SafeAddString(LBOOKS_MOREINFO1, "Город", 1)
SafeAddString(LBOOKS_MOREINFO2, GetString(SI_INSTANCEDISPLAYTYPE7), 1)
SafeAddString(LBOOKS_MOREINFO3, GetString(SI_INSTANCEDISPLAYTYPE6), 1)
SafeAddString(LBOOKS_MOREINFO4, "Пещера", 1)
SafeAddString(LBOOKS_MOREINFO5, GetString(SI_INSTANCETYPE2), 1)
SafeAddString(LBOOKS_MOREINFO6, "Inside Inn", 1)

SafeAddString(LBOOKS_SET_WAYPOINT, GetString(SI_WORLD_MAP_ACTION_SET_PLAYER_WAYPOINT) .. " : |cFFFFFF<<1>>|r", 1)

--settings menu header
SafeAddString(LBOOKS_TITLE, "LorеBooks", 1)

--appearance
SafeAddString(LBOOKS_PIN_TEXTURE, "Иконка на карте", 1)
SafeAddString(LBOOKS_PIN_TEXTURE_EIDETIC, "Иконка на карте (<<1>>)", 1)
SafeAddString(LBOOKS_PIN_TEXTURE_DESC, "Выберите иконку на карте.", 1)
SafeAddString(LBOOKS_PIN_GRAYSCALE, " - Use grayscale", 1)
SafeAddString(LBOOKS_PIN_GRAYSCALE_DESC, "Use grayscale for collected lore books. (Only applies to 'real icons')", 1)
SafeAddString(LBOOKS_PIN_GRAYSCALE_EIDETIC_DESC, "Use grayscale for uncollected eidetic books. (Only applies to 'real icons')", 1)
SafeAddString(LBOOKS_PIN_SIZE, "Размер иконки", 1)
SafeAddString(LBOOKS_PIN_SIZE_DESC, "Задать размер иконки на карте.", 1)
SafeAddString(LBOOKS_PIN_LAYER, "Слой иконки", 1)
SafeAddString(LBOOKS_PIN_LAYER_DESC, "Задать слой иконки на карте", 1)
SafeAddString(LBOOKS_PIN_CLICK_MENU, "Enable Lorebook player waypoint click option", 1)
SafeAddString(LBOOKS_PIN_CLICK_MENU_DESC, "Enable and disable the click option when Lorebooks are stacked to set player waypoint.", 1)

SafeAddString(LBOOKS_PIN_TEXTURE1, "Real icons", 1)
SafeAddString(LBOOKS_PIN_TEXTURE2, "Book icon set 1", 1)
SafeAddString(LBOOKS_PIN_TEXTURE3, "Book icon set 2", 1)
SafeAddString(LBOOKS_PIN_TEXTURE4, "Esohead's icons (Rushmik)", 1)

--compass
SafeAddString(LBOOKS_COMPASS_UNKNOWN, "Показывать книги знаний на компасе.", 1)
SafeAddString(LBOOKS_COMPASS_UNKNOWN_DESC, "Показать/скрыть иконки для неизвестных книг знаний на компасе.", 1)
SafeAddString(LBOOKS_COMPASS_DIST, "Макс. дистанция", 1)
SafeAddString(LBOOKS_COMPASS_DIST_DESC, "Максимальная дистанция, на которой иконки будут появляться на компасе.", 1)

--filters
SafeAddString(LBOOKS_UNKNOWN, "Показывать неизвестные книги знаний", 1)
SafeAddString(LBOOKS_UNKNOWN_DESC, "Показать/скрыть иконки для неизвестных книг знаний на карте.", 1)
SafeAddString(LBOOKS_COLLECTED, "Показывать уже собранные книги знаний", 1)
SafeAddString(LBOOKS_COLLECTED_DESC, "Показать/скрыть иконки для уже собранных книг знаний на карте.", 1)

SafeAddString(LBOOKS_SHARE_DATA, "Share your discoveries with LoreBooks author", 1)
SafeAddString(LBOOKS_SHARE_DATA_DESC, "Enabling this option will share your discoveries with LoreBooks author by sending automatically an ingame mail with data collected.\nThis option is only available for EU Users, even if data collected is shared with NA ones\nPlease note that you may encounter a small lag with your skills when the mail is sent. Mail is silently sent every 30 books read.", 1)

SafeAddString(LBOOKS_EIDETIC, "Show unknown Eidetic Memory", 1)
SafeAddString(LBOOKS_EIDETIC_DESC, "Show/Hide unknown Eidetic Memory scrolls on map. Those scrolls are lore-related scrolls not involved into Mages Guild Progression, but only informative about Tamriel", 1)
SafeAddString(LBOOKS_EIDETIC_COLLECTED, "Show known Eidetic Memory", 1)
SafeAddString(LBOOKS_EIDETIC_COLLECTED_DESC, "Show/Hide known Eidetic Memory scrolls on map. Those scrolls are lore-related scrolls not involved into Mages Guild Progression, but only informative about Tamriel", 1)

SafeAddString(LBOOKS_BOOKSHELF_NAME, "Show bookshelves", 1)
SafeAddString(LBOOKS_BOOKSHELF_DESC, "Show/Hide bookshelves on map. Bookshelves contain a random book from the zone.", 1)
SafeAddString(LBOOKS_COMPASS_EIDETIC, "Show unknown Eidetic Memory on compass", 1)
SafeAddString(LBOOKS_COMPASS_EIDETIC_DESC, "Show/Hide unknown Eidetic Memory scrolls on compass. Those scrolls are lore-related scrolls not involved into Mages Guild Progression, but only informative about Tamriel", 1)

SafeAddString(LBOOKS_COMPASS_BOOKSHELF_NAME, "Show bookshelves on compass", 1)
SafeAddString(LBOOKS_COMPASS_BOOKSHELF_DESC, "Show/Hide bookshelves on compass. Bookshelves contain a random book from the zone.", 1)
SafeAddString(LBOOKS_UNLOCK_EIDETIC, "Unlock Eidetic Library", 1)
SafeAddString(LBOOKS_UNLOCK_EIDETIC_DESC, "This will unlock Eidetic Library even if you haven't done the Mage Guild questline. This option is only valid for EN/FR/DE users.", 1)
SafeAddString(LBOOKS_UNLOCK_EIDETIC_WARNING, "This option is disabled because either LoreBooks has not yet been updated for the latest game update or your language is not supported", 1)

--worldmap filters
SafeAddString(LBOOKS_FILTER_UNKNOWN, "Неизвестные книги знаний", 1)
SafeAddString(LBOOKS_FILTER_COLLECTED, "Собранные книги знаний", 1)
SafeAddString(LBOOKS_FILTER_EICOLLECTED, "<<1>> (Collected)", 1)
SafeAddString(LBOOKS_FILTER_BOOKSHELF, "Lorebooks Bookshelf", 1)

--research
SafeAddString(LBOOKS_SEARCH_LABEL, "ПОИСК в библиотеке lоrе :", 1)
SafeAddString(LBOOKS_SEARCH_PLACEHOLDER, "Название книги знаний", 1)
SafeAddString(LBOOKS_INCLUDE_MOTIFS_CHECKBOX, "Include Motifs", 1)

SafeAddString(LBOOKS_RANDOM_POSITION, "[Bookshelves]", 1)

-- Report
SafeAddString(LBOOKS_REPORT_KEYBIND_RPRT, "Report", 1)
SafeAddString(LBOOKS_REPORT_KEYBIND_SWITCH, "Switch Mode", 1)
SafeAddString(LBOOKS_REPORT_KEYBIND_COPY, "Copy", 1)

SafeAddString(LBOOKS_RS_FEW_BOOKS_MISSING, "Few books are still missing in the Shalidor Library..", 1)
SafeAddString(LBOOKS_RS_MDONE_BOOKS_MISSING, "You maxed Mages Guild Skillline ! But few books are still missing", 1)
SafeAddString(LBOOKS_RS_GOT_ALL_BOOKS, "You collected all Shalidor Library. Congratulations !", 1)

SafeAddString(LBOOKS_RE_FEW_BOOKS_MISSING, "Few books are still missing in the Eidetic Memory..", 1)
SafeAddString(LBOOKS_RE_THREESHOLD_ERROR, "You need to collect few more books in order to get a report on Eidetic Memory ..", 1)

-- Immersive Mode
SafeAddString(LBOOKS_IMMERSIVE, "Enable Immersive Mode based on", 1)
SafeAddString(LBOOKS_IMMERSIVE_DESC, "Unknown Lorebooks won't be displayed based on the completion of the following objective on the current zone you are looking at", 1)

SafeAddString(LBOOKS_IMMERSIVE_CHOICE1, "Disabled", 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE2, "Zone Main Quest", 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE3, GetString(SI_MAPFILTER8), 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE4, GetAchievementCategoryInfo(6), 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE5, "Zone Quests", 1)

-- Quest Books
SafeAddString(LBOOKS_USE_QUEST_BOOKS, "Use Quest Books (Beta)", 1)
SafeAddString(LBOOKS_USE_QUEST_BOOKS_DESC, "Will try to use quest tools when they are received to avoid missing inventory-only books. May also use things like maps because there's no distinction between books and other usable quest items.", 1)
