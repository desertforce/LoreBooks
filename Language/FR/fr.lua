----------------------------------------
-- French localization for LoreBooks --
----------------------------------------
--
-- Translated by:
-- Ykses (http://www.esoui.com/forums/member.php?u=1521)
--

SafeAddString(LBOOKS_QUEST_BOOK, "Livre accessible via une quête", 1)
SafeAddString(LBOOKS_MAYBE_NOT_HERE, "[Le livre n'est peut être pas là]", 1)
SafeAddString(LBOOKS_QUEST_IN_ZONE, "Quête en <<1>>", 1)
SafeAddString(LBOOKS_SPECIAL_QUEST, "Quête spéciale dans <<1>>", 1)
SafeAddString(LBOOKS_LBPOS_OPEN_BOOK, "Vous devez lire un livre pour utiliser /lbpos", 1)
SafeAddString(LBOOKS_LBPOS_ERROR, "Livre d'artisanat ou aucun rapport avec la mémoire eidétique ou la bibliothèque de Shalidor.", 1)
SafeAddString(LBOOKS_PIN_UPDATE, "Veuillez aider à mettre à jour", 1)

--Camera Actions
SafeAddString(LBOOKS_CLIMB, "Monter", 1)


--tooltips
SafeAddString(LBOOKS_KNOWN, "collecté", 1)
SafeAddString(LBOOKS_BOOKSHELF, "Bibliothèque", 1)

SafeAddString(LBOOKS_MOREINFO1, "Ville", 1)
SafeAddString(LBOOKS_MOREINFO2, GetString(SI_INSTANCEDISPLAYTYPE7), 1)
SafeAddString(LBOOKS_MOREINFO3, GetString(SI_INSTANCEDISPLAYTYPE6), 1)
SafeAddString(LBOOKS_MOREINFO4, "sous la terre", 1)
SafeAddString(LBOOKS_MOREINFO5, GetString(SI_INSTANCETYPE2), 1)
SafeAddString(LBOOKS_MOREINFO6, "À l'intérieur de l'auberge", 1)

SafeAddString(LBOOKS_SET_WAYPOINT, GetString(SI_WORLD_MAP_ACTION_SET_PLAYER_WAYPOINT) .. " : |cFFFFFF<<1>>|r", 1)

--settings menu header
--SafeAddString(LBOOKS_TITLE,						"LoreBooks", 1)

--appearance
SafeAddString(LBOOKS_PIN_TEXTURE, "Choix des icônes", 1)
SafeAddString(LBOOKS_PIN_TEXTURE_EIDETIC, "Choix des icônes (<<1>>)", 1)
SafeAddString(LBOOKS_PIN_TEXTURE_DESC, "Choisir l'apparence des icônes sur la carte.", 1)
SafeAddString(LBOOKS_PIN_GRAYSCALE, " - Utiliser les niveaux de gris", 1)
SafeAddString(LBOOKS_PIN_GRAYSCALE_DESC, "Utilisez des niveaux de gris pour les livres de traditions collectés. (Ne s'applique qu'aux 'vraies icônes')", 1)
SafeAddString(LBOOKS_PIN_GRAYSCALE_EIDETIC_DESC, "Utilisez des niveaux de gris pour les livres eidétiques non collectés. (S'applique uniquement aux 'vraies icônes')", 1)
SafeAddString(LBOOKS_PIN_SIZE, "Taille des icônes", 1)
SafeAddString(LBOOKS_PIN_SIZE_DESC, "Choisir la taille des icônes sur la carte.", 1)
SafeAddString(LBOOKS_PIN_LAYER, "Épaisseur des icônes", 1)
SafeAddString(LBOOKS_PIN_LAYER_DESC, "Choisir l'épaisseur des icônes sur la carte.", 1)
SafeAddString(LBOOKS_PIN_CLICK_MENU, "Activer l'option de clic sur le passage du joueur", 1)
SafeAddString(LBOOKS_PIN_CLICK_MENU_DESC, "Activer et désactiver l'option de clic lorsque les Lorebooks sont empilés pour définir le point de passage du joueur.", 1)

SafeAddString(LBOOKS_PIN_TEXTURE1, "Icônes réelles", 1)
SafeAddString(LBOOKS_PIN_TEXTURE2, "Jeu d'icônes de livre 1", 1)
SafeAddString(LBOOKS_PIN_TEXTURE3, "Jeu d'icônes de livre 2", 1)
SafeAddString(LBOOKS_PIN_TEXTURE4, "Les icônes d'Esohead (Rushmik)", 1)

--compass
SafeAddString(LBOOKS_COMPASS_UNKNOWN, "Positions indiquées sur la boussole", 1)
SafeAddString(LBOOKS_COMPASS_UNKNOWN_DESC, "Afficher/cacher les Livres (de la Guilde des Mages) non collectés sur la boussole.", 1)
SafeAddString(LBOOKS_COMPASS_DIST, "Distance d'affichage maximum", 1)
SafeAddString(LBOOKS_COMPASS_DIST_DESC, "Choisir la distance à partir de laquelle les Livres apparaissent sur la boussole.", 1)

--filters
SafeAddString(LBOOKS_UNKNOWN, "Afficher les Livres inconnus", 1)
SafeAddString(LBOOKS_UNKNOWN_DESC, "Afficher/Masquer les icônes des Livres (de la Guilde des Mages) inconnus sur la carte.", 1)
SafeAddString(LBOOKS_COLLECTED, "Afficher les Livres collectés", 1)
SafeAddString(LBOOKS_COLLECTED_DESC, "Afficher/Masquer les icônes des Livres (de la Guilde des Mages) déjà collectés sur la carte.", 1)

SafeAddString(LBOOKS_SHARE_DATA, "Partagez vos découvertes avec l'auteur de LoreBooks", 1)
SafeAddString(LBOOKS_SHARE_DATA_DESC,
  "L'activation de cette option partagera vos découvertes avec l'auteur de LoreBooks en envoyant automatiquement un e-mail dans le jeu avec les données collectées.\nCette option n'est disponible que pour les utilisateurs de l'UE, même si les données collectées sont partagées avec ceux de NA\nVeuillez noter que vous pouvez rencontrer un léger décalage avec vos compétences lors de l'envoi du courrier. Le courrier est envoyé silencieusement tous les 30 livres lus.",
  1)

SafeAddString(LBOOKS_EIDETIC, "Mémoire Éidétique inconnue sur la carte", 1)
SafeAddString(LBOOKS_EIDETIC_DESC, "Afficher/Masquer les parchemins inconnus présents dans la Mémoire Éidétique sur la carte. Ces parchemins promulguent diverses informations sur le lore de Tamriel et ne sont en rien impliqués dans la progression de la Guilde des Mages", 1)
SafeAddString(LBOOKS_EIDETIC_COLLECTED, "Mémoire Éidétique connue sur la carte", 1)
SafeAddString(LBOOKS_EIDETIC_COLLECTED_DESC, "Affiche/Masque les parchemins connus présents dans la Mémoire Éidétique sur la carte. Ces parchemins promulguent diverses informations sur le lore de Tamriel et ne sont en rien impliqués dans la progression de la Guilde des Mages", 1)

SafeAddString(LBOOKS_BOOKSHELF_NAME, "Voir la Bibliothèque", 1)
SafeAddString(LBOOKS_BOOKSHELF_DESC, "Afficher/Masquer les Bibliothèques sur la carte. Les Bibliothèques contiennent un livre aléatoire de la zone.", 1)
SafeAddString(LBOOKS_COMPASS_EIDETIC, "Mémoire Éidétique inconnue sur le compas", 1)
SafeAddString(LBOOKS_COMPASS_EIDETIC_DESC, "Affiche/Masque les parchemins inconnus présents dans la Mémoire Éidétique sur le compas. Ces parchemins promulguent diverses informations sur le lore de Tamriel et ne sont en rien impliqués dans la progression de la Guilde des Mages", 1)

SafeAddString(LBOOKS_COMPASS_BOOKSHELF_NAME, "Afficher les Bibliothèques sur la boussole", 1)
SafeAddString(LBOOKS_COMPASS_BOOKSHELF_DESC, "Afficher/Masquer les Bibliothèques sur la boussole. Les Bibliothèques contiennent un livre aléatoire de la zone.", 1)
SafeAddString(LBOOKS_UNLOCK_EIDETIC, "Déverrouiller la bibliothèque eidétique", 1)
SafeAddString(LBOOKS_UNLOCK_EIDETIC_DESC, "Cela débloquera la bibliothèque eidétique même si vous n'avez pas terminé la série de quêtes de la guilde des mages. Cette option n'est valable que pour les utilisateurs EN/FR/DE.", 1)
SafeAddString(LBOOKS_UNLOCK_EIDETIC_WARNING, "Cette option est désactivée car soit LoreBooks n'a pas encore été mis à jour pour la dernière mise à jour du jeu, soit votre langue n'est pas prise en charge", 1)

--worldmap filters
SafeAddString(LBOOKS_FILTER_UNKNOWN, "Livres inconnus", 1)
SafeAddString(LBOOKS_FILTER_COLLECTED, "Livres collectés", 1)
SafeAddString(LBOOKS_FILTER_EICOLLECTED, "<<1>> (Collectés)", 1)
SafeAddString(LBOOKS_FILTER_BOOKSHELF, "Bibliothèque Lorebooks", 1)

--research
SafeAddString(LBOOKS_SEARCH_LABEL, "Recherche dans la bibliothèque :", 1)
SafeAddString(LBOOKS_SEARCH_PLACEHOLDER, "Nom du livre", 1)
SafeAddString(LBOOKS_INCLUDE_MOTIFS_CHECKBOX, "Inclure les motifs", 1)

SafeAddString(LBOOKS_RANDOM_POSITION, "[Étagères]", 1)

-- Report

SafeAddString(LBOOKS_REPORT_KEYBIND_RPRT, "Rapport", 1)
SafeAddString(LBOOKS_REPORT_KEYBIND_SWITCH, "Changer de mode", 1)
SafeAddString(LBOOKS_REPORT_KEYBIND_COPY, "Copier", 1)

SafeAddString(LBOOKS_RS_FEW_BOOKS_MISSING, "Quelques livres sont encore manquants dans la Bibliothèque de Shalidor ..", 1)
SafeAddString(LBOOKS_RS_MDONE_BOOKS_MISSING, "Niveau maximum de la Guilde des Mages ! Mais quelques livres sont encore manquants ..", 1)
SafeAddString(LBOOKS_RS_GOT_ALL_BOOKS, "Vous avez retrouvé tous les livres de la Bibliothèque de Shalidor. Félicitations !", 1)

SafeAddString(LBOOKS_RE_FEW_BOOKS_MISSING, "Quelques livres sont encore manquants dans la Mémoire Éidétique..", 1)
SafeAddString(LBOOKS_RE_THREESHOLD_ERROR, "Encore quelques livres avant de consulter le détail de votre progression sur la Mémoire Éidétique ..", 1)

-- Immersive Mode
SafeAddString(LBOOKS_IMMERSIVE, "Activer le mode immersif basé sur", 1)
SafeAddString(LBOOKS_IMMERSIVE_DESC, "Les livres inconnus ne seront pas affichés suivant la réalisation de l'objectif suivant", 1)

SafeAddString(LBOOKS_IMMERSIVE_CHOICE1, "Désactivé", 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE2, "Quête de zone principale", 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE3, GetString(SI_MAPFILTER8), 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE4, GetAchievementCategoryInfo(6), 1)
SafeAddString(LBOOKS_IMMERSIVE_CHOICE5, "Quêtes de zone", 1)

-- Quest Books
SafeAddString(LBOOKS_USE_QUEST_BOOKS, "Utiliser les livres de quête (Beta)", 1)
SafeAddString(LBOOKS_USE_QUEST_BOOKS_DESC, "Essaiera d'utiliser les outils de quête lorsqu'ils seront reçus pour éviter de manquer des livres d'inventaire uniquement. Peut également utiliser des choses comme des cartes car il n'y a pas de distinction entre les livres et les autres objets de quête utilisables.", 1)
