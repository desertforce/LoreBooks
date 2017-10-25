--[[
-------------------------------------------------------------------------------
-- LoreBooks, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

local GPS = LibStub("LibGPS2")

local pinInserts
local creations
local eideticCreations
local canProcess
local iReport
local reportIndex
local bookDataIndex
local iHomonym
local ExtractBookData
local losts = {}
local extractionDone
local mapIsShowing

local MAX_ZONE_ID = 1043 -- Need to be raised at each API bump
local NUM_MAPS = GetNumMaps()

local function InvalidPoint(x, y)
	return x < 0 or x > 1 or y < 0 or y > 1
end

local function OnMailReadable(_, mailId)
	
	local mailDataSubject = "CM_DATA"
	local mailFixSubject = "CM_FIX"
	
	local mailIdStr = Id64ToString(mailId)
	if not COLLAB[mailIdStr] then
		local senderDisplayName, _, subject = GetMailItemInfo(mailId)
		if subject == mailDataSubject then
			local body = ReadMail(mailId)
			COLLAB[mailIdStr] = {body = body, sender = senderDisplayName, received = GetDate()}
			d("Don't forget to ReloadUI")
		elseif subject == mailFixSubject then
			local body = ReadMail(mailId)
			d(body)
		end
	end
	
end

local function CoordsNearby(locX, locY, x, y)

	local nearbyIs = 0.0005 --It should be 0.00028, but we add a large diff just in case of. 0.0004 is not enough.
	if math.abs(locX - x) < nearbyIs and math.abs(locY - y) < nearbyIs then
		return true
	end
	return false
	
end

function Base62(value)
	local r = false
	local state = type( value )
	if state == "number" then
		local k = math.floor( value )
		if k == value  and  value > 0 then
			local m
			r = ""
			while k > 0 do
				m = k % 62
				k = ( k - m ) / 62
				if m >= 36 then
					m = m + 61
				elseif m >= 10 then
					m = m + 55
				else
					m = m + 48
				end
				r = string.char( m ) .. r
			end
		elseif value == 0 then
			r = "0"
		end
	elseif state == "string" then
		if value:match( "^%w+$" ) then
			local n = #value
			local k = 1
			local c
			r = 0
			for i = n, 1, -1 do
				c = value:byte( i, i )
				if c >= 48  and  c <= 57 then
					c = c - 48
				elseif c >= 65  and  c <= 90 then
					c = c - 55
				elseif c >= 97  and  c <= 122 then
					c = c - 61
				else    -- How comes?
					r = nil
					break    -- for i
				end
				r = r + c * k
				k = k * 62
			end -- for i
		end
	end
	return r
end

local function RevertUnsignedBase62(value)
	local isNegative = value:find("^%-%w+$")
	if isNegative then
		return 0 - Base62(string.sub(value, 2))
	end
	return Base62(value)
end

local function Explode(divider, stringtoParse)
	if divider == "" then return false end
	local position, values = 0, {}
	for st, sp in function() return string.find(stringtoParse, divider, position, true) end do
		table.insert(values,string.sub(stringtoParse, position, st-1))
		position = sp + 1
	end
	table.insert(values,string.sub(stringtoParse, position))
	return values
end

local function EideticValidEntry(categoryIndex)
	if categoryIndex and (categoryIndex == 1 or categoryIndex == 3) then
		return true
	end
end

-- Book we know that they are book quest but not mined for now (mainly used to avoid  tons of pins everywhere).
local function IsBookQuest(bookId)
	
	local data = LoreBooks_GetAdditionnalBookData(bookId)
	if data and data.q then
		return true
	end
	
end

local function GetQuestData(bookId)
	
	local data = LoreBooks_GetAdditionnalBookData(bookId)
	if data and data.q then
		return data.q
	end
	
end

local function GetQuestMapData(bookId)

	local data = LoreBooks_GetAdditionnalBookData(bookId)
	if data and data.m then
		return data.m
	end

end

local function CheckShalidorBook(bookId)

	local dontCheck = {
		[117] = true, -- Shalidor special book
		[101] = true, -- Shalidor special book
		[119] = true, -- Shalidor special book
	}
	
	if dontCheck[bookId] then
		return false
	end

	return true

end

local function GetQuestsDataByName(questName)
	
	local languageFrom = 0
	local questCode = 0
	local questNames = {en = 0, fr = 0, de = 0}
	local quests = LoreBooks_GetGameWholeQuestsData("en")
	
	for questId, questNameInArray in pairs(quests) do
		if questName == questNameInArray then
			languageFrom = 1
			questCode = questId
			break
		end
	end
	
	if questCode == 0 then
		quests = LoreBooks_GetGameWholeQuestsData("fr")
		for questId, questNameInArray in pairs(quests) do
			if questName == questNameInArray then
				languageFrom = 2
				questCode = questId
				break
			end
		end
	end
	
	if questCode == 0 then
		quests = LoreBooks_GetGameWholeQuestsData("de")
		for questId, questNameInArray in pairs(quests) do
			if questName == questNameInArray then
				languageFrom = 3
				questCode = questId
				break
			end
		end
	end
	
	if questCode ~= 0 then
		local questNameEN, questNameFR, questNameDE = LoreBooks_GetGameQuestData(questCode)
		questNames = {en = questNameEN, fr = questNameFR, de = questNameDE}
	end
	
	return questCode, languageFrom, questNames
	
end

-- 100021
local function GetZoneIdWithMapIndex(mapIndex)

	local maps = {
		[1] = 0,
		[2] = 3,
		[3] = 20,
		[4] = 19,
		[5] = 104,
		[6] = 92,
		[7] = 383,
		[8] = 58,
		[9] = 117,
		[10] = 57,
		[11] = 41,
		[12] = 103,
		[13] = 101,
		[14] = 181,
		[15] = 381,
		[16] = 108,
		[17] = 382,
		[18] = 281,
		[19] = 534,
		[20] = 535,
		[21] = 537,
		[22] = 280,
		[23] = 347,
		[24] = 0,
		[25] = 888,
		[26] = 584,
		[27] = 684,
		[28] = 816,
		[29] = 823,
		[30] = 849,
		[31] = 980,
	}
	
	return maps[mapIndex]

end

local function JumpToNextBook(index)

	if DATAMINED_DATA.decoded[index + 1] then
		
		if index % 2000 == 0 then
			d("ExtractBookData -> " .. index)
		end
		
		if index % 100 == 0 then
			zo_callLater(function() ExtractBookData(index + 1) end, 1) -- Mandatory or game will crash
		else
			ExtractBookData(index + 1)
		end
		
	else
		d("Process complete")
		d(pinInserts .. " pinInserts")
		d(creations .. " creations")
		d(eideticCreations .. " eideticCreations")
	end
	
end

function ExtractBookData(index)
	
	local bookData = DATAMINED_DATA.decoded[index]
	if not bookData then return end
	
	local coordsOK = false
	local bookOK = false
	
	local x							= bookData.x / 100000
	local y							= bookData.y / 100000
	
	local version					= bookData.v
	local questLinked				= bookData.q
	local zoneId					= bookData.z
	local mapIndex					= bookData.m
	local mapContentType			= bookData.d
	local langCode					= bookData.a
	local interactionType		= bookData.i
	local bookId					= bookData.k
	
	local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
	
	if not categoryIndex then
		JumpToNextBook(index)
		return
	end
	
	local isRandom					= true
	
	if bookData.r == 0 then
		isRandom = false
	end
	
	local bookConfirmed
	local bookLost
	
	local inDungeon				= mapContentType == MAP_CONTENT_DUNGEON
	
	if mapIndex == GetCyrodiilMapIndex() and (zoneId == 584 or zoneId == 643 or zoneId == 678 or zoneId == 688) then -- IC/Sewers/ICP/WGT
		mapIndex = GetImperialCityMapIndex()
	end
	
	if zoneId < 1 or zoneId > MAX_ZONE_ID or mapIndex < 1 or mapIndex > NUM_MAPS then
	
		if mapIndex > 1 and mapIndex ~= 24 then
			zoneId = GetZoneIdWithMapIndex(mapIndex)
			inDungeon = true
			bookLost = true
		elseif not InvalidPoint(x, y) then
			
			ZO_WorldMap_SetMapByIndex(1) -- Tamriel
			local wouldProcess, resultingMapIndex = WouldProcessMapClick(x, y)
			if wouldProcess then
				mapIndex = resultingMapIndex
				zoneId = GetZoneIdWithMapIndex(mapIndex)
				inDungeon = true
				bookLost = true
			end
			
		else
			d("Book Lost : [".. GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) .."]")
		end
		
	end
	
	if EideticValidEntry(categoryIndex) then
		
		if not DATAMINED_DATA.build[bookId] then DATAMINED_DATA.build[bookId] = {} end
		
		if not DATAMINED_DATA.build[bookId].c then
		
			DATAMINED_DATA.build[bookId].c = true
			DATAMINED_DATA.build[bookId].k = bookId
			
			creations = creations + 1
			
			if categoryIndex == 3 then
				eideticCreations = eideticCreations + 1
			end
			
		end
		
		if (DATAMINED_DATA.build[bookId].e and #DATAMINED_DATA.build[bookId].e >= 1) or DATAMINED_DATA.build[bookId].r then
			
			if interactionType == INTERACTION_NONE then
				
				-- book have quest data but reference don't have
				if questLinked ~= "0" and (not DATAMINED_DATA.build[bookId].q or DATAMINED_DATA.build[bookId].q == "0") then
					DATAMINED_DATA.build[bookId].q = questLinked
				end

				-- If book was read from inventory (or with case addon breaking interaction) and we have a book read from an interaction, don't push it
				for entryIndex, entryData in ipairs(DATAMINED_DATA.build[bookId].e) do
					
					if entryData.i == INTERACTION_BOOK then
						JumpToNextBook(index)
						return
					end
					
				end
			else
			
				-- If book was read from inventory (or with case addon breaking interaction) and we have a book read from an interaction, don't push it
				if DATAMINED_DATA.build[bookId].e then
					for entryIndex = #DATAMINED_DATA.build[bookId].e, 1, -1 do
						
						if DATAMINED_DATA.build[bookId].e[entryIndex].i == INTERACTION_NONE then
							table.remove(DATAMINED_DATA.build[bookId].e, entryIndex)
						end
						
					end
				end
			
			end
			
			if isRandom then
				
				-- Was 100% random
				if DATAMINED_DATA.build[bookId].r then
					
					-- If random was only found in 1 map and it is the same map
					if NonContiguousCount(DATAMINED_DATA.build[bookId].m) == 1 and DATAMINED_DATA.build[bookId].m[mapIndex] then
						
						-- Random at the same loc.
						if DATAMINED_DATA.build[bookId].e then
							for entryIndex, entryData in ipairs(DATAMINED_DATA.build[bookId].e) do
								
								if entryData.z == zoneId and entryData.d == inDungeon and CoordsNearby(x, y, entryData.x, entryData.y) then
									bookFound = true
									break
								end
								
							end
						end
						
						-- New pin
						if not bookFound then
						
							DATAMINED_DATA.build[bookId].m[mapIndex] = DATAMINED_DATA.build[bookId].m[mapIndex] + 1
							
							table.insert(DATAMINED_DATA.build[bookId].e, {
								r = isRandom,
								x = x,
								y = y,
								z = zoneId,
								m = mapIndex,
								d = inDungeon,
								i = interactionType,
								l = bookLost,
							})
							
							if questLinked ~= "0" then
								DATAMINED_DATA.build[bookId].q = questLinked
							end
							
							pinInserts = pinInserts + 1
							
						end
					
					-- Keep books with q flag. they'll be stripped later after checking
					elseif not DATAMINED_DATA.build[bookId].q then
						
						-- Random on multiple maps, delete pins
						DATAMINED_DATA.build[bookId].e = {}
						if not DATAMINED_DATA.build[bookId].m[mapIndex] then
							DATAMINED_DATA.build[bookId].m[mapIndex] = 1
						else
							DATAMINED_DATA.build[bookId].m[mapIndex] = DATAMINED_DATA.build[bookId].m[mapIndex] + 1
						end
						
					end
					
				end
				
			else
				
				-- Was 100% random
				if DATAMINED_DATA.build[bookId].r then
					DATAMINED_DATA.build[bookId].r = nil
					DATAMINED_DATA.build[bookId].m = nil
					DATAMINED_DATA.build[bookId].e = {}
				end
				
				local bookFound
				
				-- Check if we have the book at its coordinates
				if DATAMINED_DATA.build[bookId].e then
					for entryIndex, entryData in ipairs(DATAMINED_DATA.build[bookId].e) do
						if entryData.z == zoneId and entryData.d == inDungeon and CoordsNearby(x, y, entryData.x, entryData.y) then
							bookFound = true
							break
						end
					end
				end
				
				-- New pin
				if not bookFound then
				
					d("NewStaticPos: " .. categoryIndex .."/" .. collectionIndex .."/" .. bookIndex .. " [".. GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) .."]")
					
					table.insert(DATAMINED_DATA.build[bookId].e, {
						r = isRandom,
						x = x,
						y = y,
						z = zoneId,
						m = mapIndex,
						d = inDungeon,
						i = interactionType,
						l = bookLost,
					})
					
					if questLinked ~= "0" then
						DATAMINED_DATA.build[bookId].q = questLinked
					end
					
					pinInserts = pinInserts + 1
				
				end
				
			end
			
		-- New random entry
		elseif isRandom then
		
			d("NewRandom: " .. categoryIndex .."/" .. collectionIndex .."/" .. bookIndex .. " [".. GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) .."]")
		
			DATAMINED_DATA.build[bookId].e = {}
			
			table.insert(DATAMINED_DATA.build[bookId].e, {
				r = isRandom,
				x = x,
				y = y,
				z = zoneId,
				m = mapIndex,
				d = inDungeon,
				i = interactionType,
				l = bookLost,
			})
			
			DATAMINED_DATA.build[bookId].r = true
			DATAMINED_DATA.build[bookId].m = {}
			DATAMINED_DATA.build[bookId].m[mapIndex] = 1
			
			if questLinked ~= "0" then
				DATAMINED_DATA.build[bookId].q = questLinked
			end
			
			pinInserts = pinInserts + 1
			
		else
			
			d("NewStatic: " .. categoryIndex .."/" .. collectionIndex .."/" .. bookIndex .. " [".. GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) .."]")
			
			-- New static entry
			DATAMINED_DATA.build[bookId].e = {}
			
			table.insert(DATAMINED_DATA.build[bookId].e, {
				r = isRandom,
				x = x,
				y = y,
				z = zoneId,
				m = mapIndex,
				d = inDungeon,
				i = interactionType,
				l = bookLost,
			})
			
			if questLinked ~= "0" then
				DATAMINED_DATA.build[bookId].q = questLinked
			end
			
			pinInserts = pinInserts + 1
			
		end
		
	end
	
	JumpToNextBook(index)
	
end

local function ExtractData()
	
	if not ZO_WorldMap_IsWorldMapShowing() and (not LBooks_SavedVariables or (LBooks_SavedVariables and LBooks_SavedVariables.Default[GetDisplayName()][GetUnitName("player")].unlockEidetic == false)) then
	
		d("DO NOT OPEN MAP UNTIL PROCESS IS FINISHED")
		d("LOREBOOKS PREHOOKING MUST BE DISABLED WHILE EXTRACTING")
		
		losts = {}
		creations = 0
		eideticCreations = 0
		pinInserts = 0
		extractionDone = true
		
		if not DATAMINED_DATA.build then DATAMINED_DATA.build = {} end
		
		ExtractBookData(1)
		
	end

end

-- those errors are still not understood and ned to be wiped
local function CleanUnknownErrors()

	local bookData = DATAMINED_DATA.build[231] -- Crow and Raven: Three Short Fables. if book have an homonym in en/fr, it don't have homonym in german. But 1 german report set this book instead of the other one (2/18/83) in Bangkorai
	
	if bookData then
	
		if bookData.e then
			for entryIndex, entryData in ipairs(bookData.e) do
				if entryData.m == 6 then -- Bangkorai
					if CoordsNearby(0.28158, 0.31449, entryData.x, entryData.y) then
						table.remove(DATAMINED_DATA.build[231].e, entryIndex) -- remove it
					end
				end
			end
		end
		
	end
	
	local bookData = DATAMINED_DATA.build[2061] -- Rites of the Scion. Vampire gift. No locations.
	if bookData and bookData.e then
		bookData.e = {}
	end

end

-- those errors are made to help people because ZOS data can be wrong
local function CleanKnownErrors()

	local neverDatamined = {
		[3170] = true, -- [A Less Rude Song]
	}
	
	local questRelated = {
		[882] = select(3, GetQuestsDataByName("Partners in Crime")), -- [Giant Warning]
		[3046] = select(3, GetQuestsDataByName("Taking the Undaunted Pledge")), -- [Tome of the Undaunted]
		[4576] = select(3, GetQuestsDataByName("Divine Conundrum")), -- [Invitation to Morrowind]
	}
	
	local lost = {
		[1737] = true, -- [Adainaz's Journal]
	}
	
	local bugged = {
		[1733] = true, -- [A Plea for the Elder Scrolls]
	}
	
	local errors = {
	
		{
			bookId = 2743, -- Book in Dragonstar Arena
			flag = "z=888",
			value = 635,
		},
		{
			bookId = 2744, -- Book in Dragonstar Arena
			flag = "z=888",
			value = 635,
		},
		{
			bookId = 2745, -- Book in Dragonstar Arena
			flag = "z=888",
			value = 635,
		},
		{
			bookId = 2746, -- Book in Dragonstar Arena
			flag = "z=888",
			value = 635,
		},
		{
			bookId = 2747, -- Book in Dragonstar Arena
			flag = "z=888",
			value = 635,
		},
		
		{
			bookId = 2788, -- Book in Sanctum Ophidia
			flag = "z=888",
			value = 639,
		},
		{
			bookId = 2647, -- Book in Sanctum Ophidia
			flag = "z=888",
			value = 639,
		},
		{
			bookId = 2684, -- Book in Sanctum Ophidia
			flag = "z=888",
			value = 639,
		},
		
		{
			bookId = 2769, -- Book in Aetherian Archive
			flag = "z=888",
			value = 638,
		},
		{
			bookId = 2625, -- Book in Aetherian Archive
			flag = "z=888",
			value = 638,
		},
		{
			bookId = 2626, -- Book in Aetherian Archive
			flag = "z=888",
			value = 638,
		},
		{
			bookId = 2630, -- Book in Aetherian Archive
			flag = "z=888",
			value = 638,
		},
		{
			bookId = 2636, -- Book in Aetherian Archive
			flag = "z=888",
			value = 638,
		},
		
		{
			bookId = 2559, -- Book in Hel Ra Citadel
			flag = "z=888",
			value = 636,
		},
		
		{
			bookId = 3334, -- Book in Maw of Lorkhaj
			flag = "z=382",
			value = 725,
		},
		{
			bookId = 3245, -- Book in Maw of Lorkhaj
			flag = "z=382",
			value = 725,
		},
		{
			bookId = 3331, -- Book in Maw of Lorkhaj
			flag = "z=382",
			value = 725,
		},
		{
			bookId = 3237, -- Book in Maw of Lorkhaj
			flag = "z=382",
			value = 725,
		},
		

		{
			bookId = 3726, -- Book in Halls of Fabrication
			flag = "z=849",
			value = 975,
		},
		{
			bookId = 4535, -- Book in Halls of Fabrication
			flag = "z=849",
			value = 975,
		},
		{
			bookId = 4536, -- Book in Halls of Fabrication
			flag = "z=849",
			value = 975,
		},
		{
			bookId = 4537, -- Book in Halls of Fabrication
			flag = "z=849",
			value = 975,
		},
		

		{
			bookId = 4627, -- Book in Falkreath Hold
			flag = "z=888",
			value = 974,
		},
		{
			bookId = 4628, -- Book in Falkreath Hold
			flag = "z=888",
			value = 974,
		},
		{
			bookId = 4629, -- Book in Falkreath Hold
			flag = "z=888",
			value = 974,
		},
		{
			bookId = 4630, -- Book in Falkreath Hold
			flag = "z=888",
			value = 974,
		},
		
		--[[
		{
			bookId = 4616, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4617, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4618, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4619, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4620, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4621, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4622, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4623, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4624, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4625, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		{
			bookId = 4626, -- Book in Bloodroot Forge
			flag = "z=888",
			value = 973,
		},
		]]
	}

	for bookId in pairs(neverDatamined) do
		if not DATAMINED_DATA.build[bookId] then
			DATAMINED_DATA.build[bookId] = {k = bookId, l = true}
		else
			d("Book tagged Unknown (NeverFound) has been found : " .. bookId)
		end
	end
	
	for bookId, questData in pairs(questRelated) do
		if not DATAMINED_DATA.build[bookId] then
			DATAMINED_DATA.build[bookId] = {k = bookId, q = questData}
		else
			d("Book tagged Unknown (QuestLnked) has been found : " .. bookId)
		end
	end
	
	for bookId in pairs(lost) do
		if not DATAMINED_DATA.build[bookId] then
			DATAMINED_DATA.build[bookId] = {k = bookId, l = true}
		else
			d("Book tagged Unknown (Lost) has been found : " .. bookId)
		end
	end
	
	for bookId in pairs(bugged) do
		if not DATAMINED_DATA.build[bookId] then
			DATAMINED_DATA.build[bookId] = {k = bookId, l = true}
		else
			d("Book tagged Unknown (Bugged) has been found : " .. bookId)
		end
	end
	
	for bookIndex, bookData in pairs(errors) do
		local bookId = bookData.bookId
		if DATAMINED_DATA.build[bookId] then
			if DATAMINED_DATA.build[bookId].e then
				local flag = Explode("=", bookData.flag)
				for entryIndex, entryData in ipairs(DATAMINED_DATA.build[bookId].e) do
					if entryData[flag[1]] == tonumber(flag[2]) then
						entryData.zc = bookData.value
					end
				end
			end
		else
			d("Error with book (err) " .. bookId)
		end
	end
	
end

local function BuildBooks()
	
	d("LOREBOOKS PREHOOKING MUST BE DISABLED WHILE EXTRACTING")
	
	if not LBooks_SavedVariables or LBooks_SavedVariables.Default[GetDisplayName()][GetUnitName("player")].unlockEidetic == false then
		
		if extractionDone then
			DATAMINED_DATA.decoded = nil -- too much data in sv will crash eso
		end
		
		for bookId, bookData in pairs(DATAMINED_DATA.build) do
			
			if bookData.e then
				
				local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
				
				if categoryIndex == 3 then
					
					-- Add q flag to books we know they are book quests
					if IsBookQuest(bookId) then
					
						bookData.q = GetQuestData(bookId)
						bookData.qm = GetQuestMapData(bookId)
						bookData.r = false
						
					elseif bookData.q and type(bookData.q) == "string" and bookData.q ~= "0" then
						local questCode, _, questNames = GetQuestsDataByName(bookData.q)
						if questCode then
							local questInfos = "{ en = \"" .. tostring(questNames.en) .. "\", fr = \"" .. tostring(questNames.fr) .. "\", de = \"" .. tostring(questNames.de) .. "\" }, -- " .. questCode
							d("q = " .. bookData.q .. " " .. questInfos .. " : Book " .. bookId .. " [" .. GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) .. "]")
						else
							d("New quest to add to Destinations Reference : " .. bookData.q)
						end
					end
				else
					bookData.q = nil
				end
				
				if #bookData.e >= 1 then
					
					for entryIndex, entryData in ipairs(bookData.e) do
						
						-- Shalidor warning
						if categoryIndex == 1 and zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(entryData.m)) == zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(entryData.z))) then
							
							local bookFound
							if CheckShalidorBook(bookId) then
								local mapData = LoreBooks_GetMapIndexMainData(entryData.m)
								if mapData then
									for index, data in ipairs(mapData) do
										if data[3] == collectionIndex and data[4] == bookIndex then
											local gX, gY = GPS:ZoneToGlobal(entryData.m, data[1], data[2])
											if CoordsNearby(gX, gY, entryData.x, entryData.y) then
												bookFound = true
												break
											end
										end
									end
									if not bookFound then
										local xT, yT, coords
										if entryData.zx then
											xT = ("%0.05f"):format(zo_round(entryData.zx*10000)/100)
											yT = ("%0.05f"):format(zo_round(entryData.zy*10000)/100)
											coords= "Z"
										else
											xT = entryData.x
											yT = entryData.y
											coords = "G"
										end
										d("Shali : [" .. GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) .."], Coords : " .. zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(entryData.z))) .. " : " .. coords .. " " .. xT .. "x" .. yT .. " (Dungeon=" .. tostring(entryData.d) .. ")")
									end
								end
							end
						end
						
					end
					
				end
			elseif extractionDone and not bookData.r then
				if EideticValidEntry(categoryIndex) then
					d("StillUnknown : " .. categoryIndex .. "/" .. collectionIndex .. "/" .. bookIndex .. " [".. GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) .."]")
				end
			end
		
		end
		
		CleanUnknownErrors()
		CleanKnownErrors()

		d("DATAMINED_DATA.build done")
		d("Order is /lbd (decode) /lbb (each language prebuild) /lbe (extract) /lbc (coords) /lbb (postbuild)")
	
	end

end

local function CalculateCoordsForMap(mapIndex)

	for bookId, bookData in pairs(DATAMINED_DATA.build) do
		if bookData.e and #bookData.e >= 1 then
			for entryIndex, entryData in ipairs(bookData.e) do
				if not entryData.zx and entryData.m == mapIndex then
					local xLoc, yLoc = GPS:GlobalToLocal(entryData.x, entryData.y)
					if xLoc ~= nil and yLoc ~= nil and xLoc > 0 and yLoc > 0 and xLoc < 1 and yLoc < 1 then
						entryData.zx = xLoc
						entryData.zy = yLoc
					end
				end
			end
		end
	end
	
end

local function PrecalculateCoords(mapIndex)
	
	if mapIndex == "" then mapIndex = 1 end
	
	if not LBooks_SavedVariables or LBooks_SavedVariables.Default[GetDisplayName()][GetUnitName("player")].unlockEidetic == false then
		if mapIndex <= NUM_MAPS then
			if mapIndex ~= 0 and mapIndex ~= 1 and mapIndex ~= 24 then -- Tamriel & Aurbis
				ZO_WorldMap_SetMapByIndex(mapIndex)
				CalculateCoordsForMap(mapIndex)
			end
		end
	end
	
	if mapIndex == NUM_MAPS then
		d("PrecalculateCoords finished")
	else
		zo_callLater(function() PrecalculateCoords(mapIndex + 1) end, 10)
	end
	
end

local function SetEmptyDataToZero(array)
	local t = {}
	for i in ipairs(array) do
		if array[i] == "" then --2nd is a bug client side (v10)
			t[i] = "0" -- Optimization client side
		else
			t[i] = array[i]
		end
	end
	return t
end

local function DecodeData(data, onlyOne)

	for entryIndex, entryData in ipairs(data) do
		
		local rawEntry = Explode("@", entryData)
		local coordsEntry = Explode(";", rawEntry[1])
		
		if #coordsEntry >= 11 then
			
			local bookEntry = Explode(";", rawEntry[2])
			
			local coordsRewrited = SetEmptyDataToZero(coordsEntry)
			local bookRewrited = SetEmptyDataToZero(bookEntry)
			
			local miscEntry, miscRewrited
			if rawEntry[3] then
				miscEntry = Explode(";", rawEntry[3])
				miscRewrited = SetEmptyDataToZero(miscEntry)
			end
			
			-- Coordinates
			local xGPS					= RevertUnsignedBase62(coordsRewrited[1]) -- can be negative
			local yGPS					= RevertUnsignedBase62(coordsRewrited[2]) -- can be negative
			local zoneId				= Base62(coordsRewrited[3])
			
			local mapContentType		= tonumber(coordsRewrited[4])
			local mapIndex				= Base62(coordsRewrited[5])
			local randomFlag			= tonumber(coordsRewrited[6])
			local langCode				= tonumber(coordsRewrited[7])
			
			local minerVersion		= Base62(coordsRewrited[8])
			local esoVersion			= Base62(coordsRewrited[9])
			local interactionType	= Base62(coordsRewrited[10])
			local associatedQuest	= coordsRewrited[11]
			
			-- Book Data
			local bookId				= tonumber(bookRewrited[1])
         
         if xGPS == false or yGPS == false then
				d(entryData)
         elseif esoVersion >= 325 then
				
				local data = {
					x		= xGPS,					-- X
					y		= yGPS,					-- Y
					z		= zoneId,				-- Zone
					d		= mapContentType,		-- Dungeon
					m		= mapIndex,				-- Map
					r		= randomFlag,			-- Random
					a		= langCode,				-- Lang
					v		= esoVersion,			-- Version
					i		= interactionType,	-- Interaction
					q		= associatedQuest,	-- Quest
					e		= minerVersion,		-- LoreBooks Version
					k		= bookId,				-- bookId
				}
				
				if onlyOne then
					return data
				else
					table.insert(DATAMINED_DATA.decoded, data)
				end
				
			end
		end
		
	end

	return false

end

local function CleanCollab()
	
	for entryIndex, entryData in pairs(COLLAB) do
		if entryData.decoded then entryData.decoded = nil end
	end
	
	DATAMINED_DATA.build = {}
	DATAMINED_DATA.decoded = {}
	
	d("Cleaned")
	
end

local function DecodeReport(reportData)
	
	if canProcess then
	
		canProcess = false
		
		local rawReport = Explode("\n", reportData.body)
		
		DecodeData(rawReport)
		
		reportIndex = reportIndex + 1
		reportData.decoded = true
		
		if reportIndex == iReport then
			d("Decode complete")
			d(tostring(#DATAMINED_DATA.decoded) .. " entries in .decoded")
		elseif reportIndex % 500 == 0 then
			d("DecodeCollab -> " .. reportIndex)
		end

		canProcess = true
		
	else
		d("Report tried to be processed before end of other one, raise timeShift")
	end
	
end

local function SeeData(rawData)
	local rawReport = Explode("\n", rawData)
	local data = DecodeData(rawReport, true)
	
	if data then
			d("GPS-X=" .. tostring(data.x))
			d("GPS-Y=" .. tostring(data.y))
			d("ZoneId=" .. tostring(data.z) .. " " .. zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(data.z))))
			d("InDungeon=" .. tostring(data.d))
			d("Map=" .. tostring(data.m) .. " " .. zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(data.m)))
			d("IsRandom=" .. tostring(data.r))
			d("Lang=" .. tostring(data.a))
			d("EsoVersion=" .. tostring(data.v))
			d("Interaction=" .. tostring(data.i))
			d("Quest=" .. tostring(data.q))
			d("MinerVersion=" .. tostring(data.e))
			d("BookId=" .. tostring(data.k) .. " " .. GetLoreBookInfo(GetLoreBookIndicesFromBookId(data.k)))
	else
		d("Data has not being pushed")
	end
	
end

local function DecodeCollab()
	
	local timeShift = 0
	iReport = 0
	reportIndex = 0
	canProcess = true
	
	if not DATAMINED_DATA.decoded then DATAMINED_DATA.decoded = {} end
	
	for reportId, reportData in pairs(COLLAB) do
		--if not reportData.decoded then
			zo_callLater(function() DecodeReport(reportData) end, timeShift)
			timeShift = timeShift + 3 -- Mandatory or game will crash
			iReport = iReport + 1
		--end
	end
	
	d(iReport .. " to check")

end

function LoreBooks_InitializeCollab()

	local ADDON_AUTHOR_DISPLAY_NAME = "@Ayantir"

	if ADDON_AUTHOR_DISPLAY_NAME == GetDisplayName() then
	
		if not COLLAB then COLLAB = {} end
		if not DATAMINED_DATA then DATAMINED_DATA = {} end

		SLASH_COMMANDS["/lbe"] = ExtractData
		SLASH_COMMANDS["/lbb"] = BuildBooks
		SLASH_COMMANDS["/lbc"] = PrecalculateCoords

		SLASH_COMMANDS["/lbd"] = DecodeCollab
		SLASH_COMMANDS["/lbs"] = SeeData
		SLASH_COMMANDS["/lbcollab"] = CleanCollab
		
		EVENT_MANAGER:RegisterForEvent("PostmailDeamon", EVENT_MAIL_READABLE, OnMailReadable)
		
	end
	
end