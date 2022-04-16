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

--Libraries--------------------------------------------------------------------
local LMP = LibMapPins
local LMD = LibMapData
local GPS = LibGPS3
local Postmail = {}
local c = LoreBooks.Constants


--Local variables -------------------------------------------------------------
local updatePins = {}
local updating = false
local mapIsShowing
local db --user settings

local INFORMATION_TOOLTIP
local loreLibraryReportKeybind
local eideticModeAsked
local reportShown
local copyReport

--prints message to chat
local function MyPrint(...)
  local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
  if (not ChatEditControl:HasFocus()) then StartChatInput() end
  ChatEditControl:InsertText(...)
end

local function InvalidPoint(x, y)
  return (x < 0 or x > 1 or y < 0 or y > 1)
end

local function GetLorebooksMapInfo()
  local _, zone = LMP:GetZoneAndSubzone(false, false, true)
  local zoneId = GetZoneId(GetCurrentMapZoneIndex())
  local mapIndex = GetCurrentMapIndex()
  if IsInImperialCity() then mapIndex = GetImperialCityMapIndex() end
  if IsInCyrodiil() then mapIndex = GetCyrodiilMapIndex end
  local mapId = GetCurrentMapId()
  --d(zone)
  --d(zoneId)
  --d(mapIndex)
  --d(mapId)

  local name, mapType, mapContentType, zoneIndex, description = GetMapInfoById(mapId)
  local isMainZone = mapType == MAPTYPE_ZONE
  --d(isMainZone)

  return { ["z"] = zoneId, ["mn"] = mapIndex, ["md"] = mapId, ["mt"] = isMainZone }
end

-- Pins -----------------------------------------------------------------------
local function GetPinTextureBookshelf(self)
  local zoneId = self.m_PinTag.z
  local texture
  if LoreBooks.Constants.icon_list_zoneid[zoneId] then
    texture = LoreBooks.Constants.icon_list_zoneid[zoneId]
  else
    texture = LoreBooks.Constants.icon_list_zoneid[1261]
  end
  return texture
end

local function GetPinTexture(self)
  local _, texture, known = GetLoreBookInfo(1, self.m_PinTag[3], self.m_PinTag[4])
  local textureType = db.pinTexture.type
  if texture == c.MISSING_TEXTURE then texture = c.PLACEHOLDER_TEXTURE end
  return (textureType == c.PIN_ICON_REAL) and texture or c.PIN_TEXTURES[textureType][known and 1 or 2]
end

local function GetPinTextureEidetic(self)
  local _, texture, known = GetLoreBookInfo(3, self.m_PinTag.c, self.m_PinTag.b)
  local textureType = db.pinTextureEidetic
  if texture == c.MISSING_TEXTURE then texture = c.PLACEHOLDER_TEXTURE end
  return (textureType == c.PIN_ICON_REAL) and texture or c.PIN_TEXTURES[textureType][known and 1 or 2]
end

local function IsShaliPinGrayscale()
  return db.pinTexture.type == c.PIN_ICON_REAL and db.pinGrayscale
end

local function IsEideticPinGrayscale()
  return db.pinTextureEidetic == c.PIN_ICON_REAL and db.pinGrayscaleEidetic
end

--tooltip creator
local pinTooltipCreator = {}
pinTooltipCreator.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreator.creator = function(pin)

  local pinTag = pin.m_PinTag
  local title, icon, known = GetLoreBookInfo(1, pinTag[3], pinTag[4])
  local collection = GetLoreCollectionInfo(1, pinTag[3])
  local moreinfo = {}
  if icon == c.MISSING_TEXTURE then icon = c.PLACEHOLDER_TEXTURE end
  -- /script d(zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetUnitZoneIndex("player"))))
  if pinTag[5] then
    if pinTag[5] < 5 then
      table.insert(moreinfo, "[" .. GetString("LBOOKS_MOREINFO", pinTag[5]) .. "]")
    else
      table.insert(moreinfo, "[" .. zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(pinTag[5]))) .. "]")
    end
  end
  if known then
    table.insert(moreinfo, "[" .. GetString(LBOOKS_KNOWN) .. "]")
  end

  if IsInGamepadPreferredMode() then
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat(collection), INFORMATION_TOOLTIP.tooltip:GetStyle("mapTitle"))
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, icon, title, { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3 })
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, table.concat(moreinfo, " / "), INFORMATION_TOOLTIP.tooltip:GetStyle("worldMapTooltip"))
    end
  else
    INFORMATION_TOOLTIP:AddLine(zo_strformat(collection), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
    ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
    INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:AddLine(table.concat(moreinfo, " / "), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
    end
  end

end

--tooltip creator
local pinTooltipCreatorBookshelf = {}
pinTooltipCreatorBookshelf.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreatorBookshelf.creator = function(pin)

  local pinTag = pin.m_PinTag
  local title = pinTag.pinName
  local icon = pinTag.texture
  local moreinfo = {}

  if IsInGamepadPreferredMode() then
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, icon, title, { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3 })
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, table.concat(moreinfo, " / "), INFORMATION_TOOLTIP.tooltip:GetStyle("worldMapTooltip"))
    end
  else
    INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:AddLine(table.concat(moreinfo, " / "), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
    end
  end

end

local function getQuestName(q)
  if type(q) == "string" then
    return q
  else
    local questName = GetQuestName(q)
    return questName
  end
end

local function getQuestLocation(q)
  local zoneId = GetQuestZoneId(q)
  return zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameById(zoneId))
end

--tooltip creator
local pinTooltipCreatorEidetic = {}
pinTooltipCreatorEidetic.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreatorEidetic.creator = function(pin)

  local pinTag = pin.m_PinTag
  local title, icon, known = GetLoreBookInfo(3, pinTag.c, pinTag.b)
  local collection = GetLoreCollectionInfo(3, pinTag.c)
  if icon == MISSING_TEXTURE then icon = PLACEHOLDER_TEXTURE end
  local mapId = pinTag.pm
  local name, _, _, zoneIndex, _ = GetMapInfoById(mapId)
  local zoneName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(zoneIndex))
  local mapName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(mapId))

  if IsInGamepadPreferredMode() then
    -- Gamepad Mode

    local bookColor = ZO_HIGHLIGHT_TEXT
    if known then
      bookColor = ZO_SUCCEEDED_TEXT
    end

    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat(collection), INFORMATION_TOOLTIP.tooltip:GetStyle("mapTitle"))
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, bookColor:Colorize(title), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3 })

    if pinTag.q then
      local qName = getQuestName(pinTag.q)
      if qName then
        INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, GetString(LBOOKS_QUEST_BOOK), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })
        INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, qName, { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })

        --local questDetails
        --if pinTag.qt then
        --	questDetails = zo_strformat(GetString("LBOOKS_SPECIAL_QUEST"), pinTag.qt)
        --else
        --	questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(pinTag.qm)))
        --end
        --INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, questDetails, {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
      end
    end

    if pinTag.d then

      if zoneName == mapName then
        INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat("[<<1>>]", GetString(SI_QUESTTYPE5)), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })
      else
        INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, string.format("[%s]", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, zoneName)), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })
      end

    end

    if (pinTag.i and pinTag.i == INTERACTION_NONE) or pinTag.l then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, GetString(LBOOKS_MAYBE_NOT_HERE), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })
    elseif pinTag.r then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, GetString(LBOOKS_RANDOM_POSITION), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })
    end

  else
    -- Keyboard Mode

    INFORMATION_TOOLTIP:AddLine(zo_strformat(collection), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
    ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)

    local bookColor = ZO_HIGHLIGHT_TEXT
    if known then
      bookColor = ZO_SUCCEEDED_TEXT
    end

    INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", bookColor:UnpackRGB())

    if pinTag.q then
      local qName = getQuestName(pinTag.q)
      if qName then
        INFORMATION_TOOLTIP:AddLine(GetString(LBOOKS_QUEST_BOOK), "", ZO_SELECTED_TEXT:UnpackRGB())
        INFORMATION_TOOLTIP:AddLine(string.format("[%s]", qName), "", ZO_SELECTED_TEXT:UnpackRGB())

        --local questDetails
        --if pinTag.qt then
        --	questDetails = zo_strformat(GetString("LBOOKS_SPECIAL_QUEST"), pinTag.qt)
        --elseif pinTag.qm then
        --	questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(pinTag.qm)))
        --end
        --if questDetails then
        --	INFORMATION_TOOLTIP:AddLine(questDetails, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        --end
      end
    end

    if pinTag.d then

      if zoneName == mapName then
        INFORMATION_TOOLTIP:AddLine(zo_strformat("[<<1>>]", GetString(SI_QUESTTYPE5)), "", ZO_SELECTED_TEXT:UnpackRGB())
      else
        INFORMATION_TOOLTIP:AddLine(string.format("[%s]", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, zoneName)), "", ZO_SELECTED_TEXT:UnpackRGB())
      end
    end

    if (pinTag.i and pinTag.i == INTERACTION_NONE) or pinTag.l then
      INFORMATION_TOOLTIP:AddLine(GetString(LBOOKS_MAYBE_NOT_HERE))
    elseif pinTag.r then
      INFORMATION_TOOLTIP:AddLine(GetString(LBOOKS_RANDOM_POSITION))
    end

  end

end

local function ShouldDisplayLoreBooks()

  if db.immersiveMode == 1 then
    return true
  end

  local info = GetLorebooksMapInfo()
  local zoneId
  local mapIndex
  local mapId
  local isMainZone
  if info.z then zoneId = info.z end
  if info.mn then mapIndex = info.mn end
  if info.md then mapId = info.md end
  if info.mt then isMainZone = info.mt end

  if mapIndex then
    if db.immersiveMode == 2 then
      -- MainQuest

      local conditionData = LoreBooks_GetImmersiveModeCondition(db.immersiveMode, mapIndex)
      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    elseif db.immersiveMode == 3 then
      -- Wayshrines

      if mapIndex ~= GetCyrodiilMapIndex() then
        -- It is impossible to unlock all Wayshrines in Cyrodiil
        local conditionData = LoreBooks_GetImmersiveModeCondition(db.immersiveMode, mapIndex)
        return conditionData
      end

    elseif db.immersiveMode == 4 then
      -- Exploration

      local conditionData = LoreBooks_GetImmersiveModeCondition(db.immersiveMode, mapIndex)
      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    elseif db.immersiveMode == 5 then
      -- Zone Quests

      local conditionData = LoreBooks_GetImmersiveModeCondition(db.immersiveMode, mapIndex)

      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    end
  end

  return true

end

local function IsValidZone()
  local zoneIndex = GetCurrentMapZoneIndex()
  local invalidZones = {
    [0] = true, -- is the value returned when there is no zoneIndex
    [930] = true, -- Darkshade Caverns II
    [931] = true, -- Elden Hollow II
    [932] = true, -- Crypt of Hearts II
    [933] = true, -- Wayrest Sewers II
    [934] = true, -- Fungal Grotto II
    [935] = true, -- The Banished Cells II
    [936] = true, -- Spindleclutch II
  }

  if invalidZones[zoneIndex] then
    return false
  end

  return true

end

local function CreatePins()

  local shouldDisplay = ShouldDisplayLoreBooks()
  local info = GetLorebooksMapInfo()
  local zoneId
  local mapIndex
  local mapId
  local isMainZone
  local zoneidToMapId
  if info.z then zoneId = info.z end
  if info.mn then mapIndex = info.mn end
  if info.md then mapId = info.md end
  if info.mt then isMainZone = info.mt end
  zoneidToMapId = GetMapIdByZoneId(zoneId)

  -- Shalidor's Books
  if (updatePins[c.PINS_COLLECTED] and LMP:IsEnabled(c.PINS_COLLECTED))
    or (shouldDisplay and updatePins[c.PINS_UNKNOWN] and LMP:IsEnabled(c.PINS_UNKNOWN))
    or (shouldDisplay and updatePins[c.PINS_COMPASS] and db.filters[c.PINS_COMPASS]) then
    if IsValidZone() then
      local lorebooks = LoreBooks_GetLocalData(mapId)
      if lorebooks then
        for _, pinData in ipairs(lorebooks) do
          local _, _, known = GetLoreBookInfo(1, pinData[3], pinData[4])

          if pinData[6] then
          elseif known and updatePins[c.PINS_COLLECTED] and LMP:IsEnabled(c.PINS_COLLECTED) then
            LMP:CreatePin(c.PINS_COLLECTED, pinData, pinData[1], pinData[2])
          elseif not known then
            if updatePins[c.PINS_UNKNOWN] and LMP:IsEnabled(c.PINS_UNKNOWN) then
              LMP:CreatePin(c.PINS_UNKNOWN, pinData, pinData[1], pinData[2])
            end
            if updatePins[c.PINS_COMPASS] and db.filters[c.PINS_COMPASS] then
              COMPASS_PINS.pinManager:CreatePin(c.PINS_COMPASS, pinData, pinData[1], pinData[2])
            end
          end
        end
      end
    end
  end

  -- Bookshelves
  if (updatePins[c.PINS_BOOKSHELF] and LMP:IsEnabled(c.PINS_BOOKSHELF))
    or (updatePins[c.PINS_COMPASS_BOOKSHELF] and db.filters[c.PINS_COMPASS_BOOKSHELF]) then
    local bookshelves = LoreBooks_GetBookshelfDataFromMapId(mapId)
    if bookshelves then
      for _, pinData in ipairs(bookshelves) do
        pinData.texture = LoreBooks.Constants.icon_list_zoneid[zoneId]
        pinData.pinName = GetString(LBOOKS_BOOKSHELF)
        if updatePins[c.PINS_BOOKSHELF] and db.filters[c.PINS_BOOKSHELF] then
          LMP:CreatePin(c.PINS_BOOKSHELF, pinData, pinData.x, pinData.y)
        end
        if updatePins[c.PINS_COMPASS_BOOKSHELF] and db.filters[c.PINS_COMPASS_BOOKSHELF] then
          COMPASS_PINS.pinManager:CreatePin(c.PINS_COMPASS_BOOKSHELF, pinData, pinData.x, pinData.y)
        end
      end
    end
  end

  -- Eidetic Memory
  if (updatePins[c.PINS_EIDETIC_COLLECTED] and LMP:IsEnabled(c.PINS_EIDETIC_COLLECTED))
    or (shouldDisplay and updatePins[c.PINS_EIDETIC] and LMP:IsEnabled(c.PINS_EIDETIC))
    or (shouldDisplay and updatePins[c.PINS_COMPASS_EIDETIC] and db.filters[c.PINS_COMPASS_EIDETIC]) then
    local mapContentType = GetMapContentType()
    local eideticBooks
    local z_mapId = GetMapIdByZoneId(zoneId)

    eideticBooks = LoreBooks_GetNewEideticDataForMapUniqueId(mapId, z_mapId)

    if eideticBooks then
      for _, pinData in ipairs(eideticBooks) do
        local _, _, known = GetLoreBookInfo(3, pinData.c, pinData.b)
        if (not known and LMP:IsEnabled(c.PINS_EIDETIC)) or (known and LMP:IsEnabled(c.PINS_EIDETIC_COLLECTED)) then

          if zoneId == 584 and (pinData.z == 643 or pinData.z == 678 or pinData.z == 688) then
            --IC Sewers/ICP/WGT
            -- Don't render
          else
            --[[ if qm or the map location which could be the zoneId or
            the mapIndex is not there OR when qm equals mn which means
            when the quest location equals the mapInedx.

            elseif not pinData.qm or pinData.qm == pinData.mn then

            so if there is no qm or when qm equals the mapIndex then display
            the pin

            04/22 changed to else only because the old conditions were

            -- if not .qm show the pin
            -- if the quest location equals the mapIndex show the pin

            mn (mapIndex) may not exist and eideticBooks are already correct
            and even when mn exists, it is ignored because q (questId) is used
            for the zone name
            ]]--

            --[[
            if usePrecalculatedCoords and pinData.zx and pinData.zy then
              pinData.xLoc = pinData.zx
              pinData.yLoc = pinData.zy
            else
              pinData.xLoc, pinData.yLoc = GPS:GlobalToLocal(pinData.x, pinData.y)
            end

            .px
            ]]--

            if mapId == pinData.pm then
              pinData.xLoc, pinData.yLoc = GPS:GlobalToLocal(pinData.px, pinData.py)
            elseif z_mapId == pinData.zm then
              if pinData.zx and pinData.zy then
                pinData.xLoc, pinData.yLoc = GPS:GlobalToLocal(pinData.zx, pinData.zy)
              else
                pinData.xLoc, pinData.yLoc = GPS:GlobalToLocal(pinData.px, pinData.py)
              end
            end

            local _, currentMapType, currentMapContentType, _, _ = GetMapInfoById(pinData.pm)
            if (currentMapContentType == MAP_CONTENT_DUNGEON and pinData.d) or (currentMapContentType ~= MAP_CONTENT_DUNGEON and not pinData.d) then
              if not known and updatePins[c.PINS_EIDETIC] and LMP:IsEnabled(c.PINS_EIDETIC) then
                LMP:CreatePin(c.PINS_EIDETIC, pinData, pinData.xLoc, pinData.yLoc)
              elseif known and updatePins[c.PINS_EIDETIC_COLLECTED] and LMP:IsEnabled(c.PINS_EIDETIC_COLLECTED) then
                LMP:CreatePin(c.PINS_EIDETIC_COLLECTED, pinData, pinData.xLoc, pinData.yLoc)
              end
            end
            if not known then
              if updatePins[c.PINS_COMPASS_EIDETIC] and db.filters[c.PINS_COMPASS_EIDETIC] and ((currentMapContentType == MAP_CONTENT_DUNGEON and pinData.d) or (currentMapContentType ~= MAP_CONTENT_DUNGEON and not pinData.d)) then
                COMPASS_PINS.pinManager:CreatePin(c.PINS_COMPASS_EIDETIC, pinData, pinData.xLoc, pinData.yLoc)
              end
            end -- end show Compass Pin
          end -- end of if not IC or if not qm
        end -- end of if not known or known Eidetic Memory
      end -- end of for loop

    end -- end of if eideticBooks table

  end -- Eidetic Memory

  updatePins = {}
  updating = false

end

local function QueueCreatePins(pinType)
  updatePins[pinType] = true

  if not updating then
    updating = true
    if IsPlayerActivated() then
      CreatePins()
    else
      EVENT_MANAGER:RegisterForEvent("LoreBooks_PinUpdate", EVENT_PLAYER_ACTIVATED,
        function(event)
          EVENT_MANAGER:UnregisterForEvent("LoreBooks_PinUpdate", event)
          CreatePins()
        end)
    end
  end
end

local function MapCallback_bookshelf()
  if not LMP:IsEnabled(c.PINS_BOOKSHELF) or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_BOOKSHELF)
end

local function MapCallback_unknown()
  if not LMP:IsEnabled(c.PINS_UNKNOWN) or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_UNKNOWN)
end

local function MapCallback_collected()
  if not LMP:IsEnabled(c.PINS_COLLECTED) or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_COLLECTED)
end

local function MapCallback_eidetic()
  if not LMP:IsEnabled(c.PINS_EIDETIC) or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_EIDETIC)
end

local function MapCallback_eideticCollected()
  if not LMP:IsEnabled(c.PINS_EIDETIC_COLLECTED) or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_EIDETIC_COLLECTED)
end

local function CompassCallback()
  if not db.filters[c.PINS_COMPASS] or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_COMPASS)
end

local function CompassCallbackEidetic()
  if not db.filters[c.PINS_COMPASS_EIDETIC] or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_COMPASS_EIDETIC)
end

local function CompassCallbackBookshelf()
  if not db.filters[c.PINS_COMPASS_BOOKSHELF] or GetMapType() > MAPTYPE_ZONE then return end
  QueueCreatePins(c.PINS_COMPASS_BOOKSHELF)
end

local function InitializePins()

  local pinTextures = c.PIN_TEXTURES
  local pinTextureLevel = db.pinTexture.level
  local pinTextureSize = db.pinTexture.size
  local compassMaxDistance = db.compassMaxDistance

  local mapPinLayout_eidetic = { level = pinTextureLevel, texture = GetPinTextureEidetic, size = pinTextureSize, grayscale = IsEideticPinGrayscale }
  local mapPinLayout_eideticCollected = { level = pinTextureLevel, texture = GetPinTextureEidetic, size = pinTextureSize }
  local mapPinLayout_unknown = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize }
  local mapPinLayout_collected = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize, grayscale = IsShaliPinGrayscale }
  local mapPinLayout_bookshelf = { level = pinTextureLevel, texture = GetPinTextureBookshelf, size = pinTextureSize }

  local compassPinLayout = { maxDistance = compassMaxDistance, texture = pinTextures[db.pinTexture.type][2],
                             sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
                               if zo_abs(normalizedAngle) > 0.25 then
                                 pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
                               else
                                 pin:SetDimensions(48, 48)
                               end
                             end,
                             additionalLayout = {
                               function(pin, angle, normalizedAngle, normalizedDistance)
                                 if (db.pinTexture.type == c.PIN_ICON_REAL) then
                                   --replace icon with icon from LoreLibrary
                                   local _, texture = GetLoreBookInfo(1, pin.pinTag[3], pin.pinTag[4])
                                   if icon == c.MISSING_TEXTURE then icon = c.PLACEHOLDER_TEXTURE end
                                   local icon = pin:GetNamedChild("Background")
                                   icon:SetTexture(texture)
                                 end
                               end,
                               function(pin)
                                 --I do not need to reset anything (texture is changed automatically), so the function is empty
                               end
                             }
  }
  local compassPinLayoutEidetic = { maxDistance = compassMaxDistance, texture = pinTextures[db.pinTextureEidetic][2],
                                    sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
                                      if zo_abs(normalizedAngle) > 0.25 then
                                        pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
                                      else
                                        pin:SetDimensions(48, 48)
                                      end
                                    end,
                                    additionalLayout = {
                                      function(pin, angle, normalizedAngle, normalizedDistance)
                                        if (db.pinTextureEidetic == c.PIN_ICON_REAL) then
                                          --replace icon with icon from LoreLibrary
                                          local _, texture = GetLoreBookInfo(3, pin.pinTag.c, pin.pinTag.b)
                                          if icon == c.MISSING_TEXTURE then icon = c.PLACEHOLDER_TEXTURE end
                                          local icon = pin:GetNamedChild("Background")
                                          icon:SetTexture(texture)
                                        end
                                      end,
                                      function(pin)
                                        --I do not need to reset anything (texture is changed automatically), so the function is empty
                                      end
                                    }
  }
  local compassPinLayoutBookshelf = { maxDistance = compassMaxDistance, texture = LoreBooks.Constants.icon_list_zoneid[1261],
                                      sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
                                        if zo_abs(normalizedAngle) > 0.25 then
                                          pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
                                        else
                                          pin:SetDimensions(48, 48)
                                        end
                                      end
  }

  --initialize map pins
  LMP:AddPinType(c.PINS_UNKNOWN, MapCallback_unknown, nil, mapPinLayout_unknown, pinTooltipCreator)
  LMP:AddPinType(c.PINS_COLLECTED, MapCallback_collected, nil, mapPinLayout_collected, pinTooltipCreator)
  LMP:AddPinType(c.PINS_EIDETIC, MapCallback_eidetic, nil, mapPinLayout_eidetic, pinTooltipCreatorEidetic)
  LMP:AddPinType(c.PINS_EIDETIC_COLLECTED, MapCallback_eideticCollected, nil, mapPinLayout_eideticCollected, pinTooltipCreatorEidetic)
  LMP:AddPinType(c.PINS_BOOKSHELF, MapCallback_bookshelf, nil, mapPinLayout_bookshelf, pinTooltipCreatorBookshelf)

  --add map filters
  LMP:AddPinFilter(c.PINS_UNKNOWN, GetString(LBOOKS_FILTER_UNKNOWN), nil, db.filters)
  LMP:AddPinFilter(c.PINS_COLLECTED, GetString(LBOOKS_FILTER_COLLECTED), nil, db.filters)
  LMP:AddPinFilter(c.PINS_EIDETIC, GetLoreCategoryInfo(3), nil, db.filters)
  LMP:AddPinFilter(c.PINS_EIDETIC_COLLECTED, zo_strformat(LBOOKS_FILTER_EICOLLECTED, GetLoreCategoryInfo(3)), nil, db.filters)
  LMP:AddPinFilter(c.PINS_BOOKSHELF, GetString(LBOOKS_FILTER_BOOKSHELF), nil, db.filters)

  --add handler for the left click
  LMP:SetClickHandlers(c.PINS_UNKNOWN, {
    [1] = {
      name = function(pin) return zo_strformat(LBOOKS_SET_WAYPOINT, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) end,
      show = function(pin) return not select(3, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) end,
      duplicates = function(pin1, pin2) return (pin1.m_PinTag[3] == pin2.m_PinTag[3] and pin1.m_PinTag[4] == pin2.m_PinTag[4]) end,
      callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
    }
  })

  LMP:SetClickHandlers(c.PINS_EIDETIC, {
    [1] = {
      name = function(pin) return zo_strformat(LBOOKS_SET_WAYPOINT, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) end,
      show = function(pin) return not select(3, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) end,
      duplicates = function(pin1, pin2) return (pin1.m_PinTag.b == pin2.m_PinTag.c and pin1.m_PinTag.b == pin2.m_PinTag.b) end,
      callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
    }
  })
  LMP:SetClickHandlers(c.PINS_EIDETIC_COLLECTED, {
    [1] = {
      name = function(pin) return zo_strformat(LBOOKS_SET_WAYPOINT, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) end,
      show = function(pin) return select(3, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) == true end,
      duplicates = function(pin1, pin2) return (pin1.m_PinTag.b == pin2.m_PinTag.c and pin1.m_PinTag.b == pin2.m_PinTag.b) end,
      callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
    }
  })

  --initialize compass pins
  COMPASS_PINS:AddCustomPin(c.PINS_COMPASS, CompassCallback, compassPinLayout)
  COMPASS_PINS:AddCustomPin(c.PINS_COMPASS_EIDETIC, CompassCallbackEidetic, compassPinLayoutEidetic)
  COMPASS_PINS:AddCustomPin(c.PINS_COMPASS_BOOKSHELF, CompassCallbackBookshelf, compassPinLayoutBookshelf)
  COMPASS_PINS:RefreshPins(c.PINS_COMPASS)
  COMPASS_PINS:RefreshPins(c.PINS_COMPASS_EIDETIC)
  COMPASS_PINS:RefreshPins(c.PINS_COMPASS_BOOKSHELF)
end

local function ConfigureMail(data)

  if data then

    Postmail = data
    if (not (Postmail.subject and type(Postmail.subject) == "string" and string.len(Postmail.subject) > 0)) then
      return false
    end
    if (not (Postmail.recipient and type(Postmail.recipient) == "string" and string.len(Postmail.recipient) > 0)) then
      return false
    end
    if (not (Postmail.maxDelay and type(Postmail.maxDelay) == "number" and Postmail.maxDelay >= 0)) then
      return false
    end
    if (not (Postmail.mailMaxSize and type(Postmail.mailMaxSize) == "number" and Postmail.mailMaxSize >= 0 and Postmail.mailMaxSize <= 700)) then
      return false
    end

    Postmail.isConfigured = true
    return true

  end

  return false

end

local function EnableMail()
  if Postmail.isConfigured then
    Postmail.isActive = true
  end
end

local function DisableMail()
  if Postmail.isConfigured and Postmail.isActive then
    Postmail.isActive = false
  end
end

local function SendData(data)

  --local function SendMailData(data)
  --	if Postmail.recipient ~= GetDisplayName() then -- Cannot send to myself
  --		RequestOpenMailbox()
  --		SendMail(Postmail.recipient, Postmail.subject, data)
  --		CloseMailbox()
  --	else -- Directly add to COLLAB
  --		d(data)
  --		COLLAB[GetDisplayName() .. GetTimeStamp()] = {body = data, sender = Postmail.recipient, received = GetDate()}
  --	end
  --end
  --
  --local pendingData = db.postmailData
  --if Postmail.recipient == GetDisplayName() then
  --	SendMailData(data)
  --elseif Postmail.isActive then
  --	local dataLen = string.len(data)
  --	local now = GetTimeStamp()
  --	if pendingData ~= "" then
  --		if not string.find(pendingData, data) then
  --			local dataMergedLen = string.len(pendingData) + dataLen + 1 -- 1 is \n
  --			if now - db.postmailFirstInsert > Postmail.maxDelay then -- A send must be done
  --				if dataMergedLen > Postmail.mailMaxSize then
  --					SendMailData(pendingData) -- too big, send pendingData and save the modulo
  --					db.postmailData = data
  --					db.postmailFirstInsert = now
  --				else
  --					SendMailData(pendingData .. "\n" .. data) -- Send all data
  --					db.postmailData = ""
  --					db.postmailFirstInsert = now
  --				end
  --			else
  --				-- Send only if data is too big
  --				if dataMergedLen > Postmail.mailMaxSize then
  --					SendMailData(pendingData) -- too big, send pendingData and save the modulo
  --					db.postmailData = data
  --					db.postmailFirstInsert = now
  --				else
  --					db.postmailData = db.postmailData .. "\n" .. data
  --				end
  --			end
  --		end
  --	elseif dataLen < Postmail.mailMaxSize then
  --		db.postmailData = data
  --		db.postmailFirstInsert = now
  --	end
  --end

end

local function BuildLorebooksLoreLibrary()

  --for categoryIndex = 1, GetNumLoreCategories() do
  --	local _, numCollections = GetLoreCategoryInfo(categoryIndex)
  --	for collectionIndex = 1, numCollections do
  --		local _, _, _, totalBooks, hidden = LoreBooks_GetNewLoreCollectionInfo(categoryIndex, collectionIndex)
  --		if not hidden and totalBooks ~= nil then
  --			for bookIndex = 1, totalBooks do
  --				local _, _, known = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
  --				if known then
  --					if categoryIndex == 3 then
  --						eideticCurrentlyCollected = eideticCurrentlyCollected + 1
  --					end
  --					totalCurrentlyCollected = totalCurrentlyCollected + 1
  --				end
  --			end
  --		end
  --	end
  --end

end

local minerEnabled = false
local minerCallback = function() end --overwritten if miner is enabled
function LoreBooks_ReportBook(bookId)
  local dataToShare = minerCallback(bookId)
  --if dataToShare then
  --	SendData(dataToShare)
  --end
end

function LoreBooks.ToggleShareData()

  --if not LoreBooks.CanShareData() then return end
  --
  --local PostmailData = {
  --	subject = "CM_DATA", -- Subject of the mail
  --	recipient = "@Kyoma", -- Recipient of the mail. The recipient *IS GREATLY ENCOURAGED* to run CollabMiner
  --	maxDelay = 3600*12, -- 12h
  --	mailMaxSize = MAIL_MAX_BODY_CHARACTERS - 50, -- Mail limitation is 700 Avoid > 675. (some books with additional data can have 14 additional chars, so we'll still have 16 in case of).
  --}
  --
  --minerEnabled, minerCallback = LoreBooks.IsMinerEnabled()
  --
  --if db.shareData and minerEnabled and minerCallback then
  --	local postmailIsConfigured = ConfigureMail(PostmailData)
  --	if postmailIsConfigured then
  --		EnableMail()
  --	else
  --		-- shouldn't really happen
  --		minerEnabled = false
  --		DisableMail()
  --	end
  --else
  --	minerEnabled = false
  --end

end

local function OnGamepadPreferredModeChanged()
  if IsInGamepadPreferredMode() then
    INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
  else
    INFORMATION_TOOLTIP = InformationTooltip
  end
end

local function OnSearchTextChanged(self)

  ZO_EditDefaultText_OnTextChanged(self)

  local search = self:GetText()
  LORE_LIBRARY.search = search

  LORE_LIBRARY.navigationTree:ClearSelectedNode()
  LORE_LIBRARY:BuildCategoryList()

end

local function NameSorter(left, right)
  return left.name < right.name
end

local function IsFoundInLoreLibrary(search, data)

  if string.find(string.lower(data.name), search) then
    return true
  else

    for bookIndex = 1, data.totalBooks do
      local title = GetLoreBookInfo(data.categoryIndex, data.collectionIndex, bookIndex)
      if string.find(string.lower(title), search) then
        return true
      end
    end

  end

  return false

end

local function ShowLoreLibraryReport(forceHide)

  LoreBooksCopyReport:SetHidden(true)
  if forceHide then
    reportShown = false
    LoreBooksReport:SetHidden(forceHide)
  else
    if ZO_LoreLibrary:IsHidden() then
      LoreBooksReport:SetHidden(true)
      ZO_LoreLibrary:SetHidden(false)
      reportShown = false
    else
      LoreBooksReport:SetHidden(false)
      ZO_LoreLibrary:SetHidden(true)
      reportShown = true
    end
  end

  KEYBIND_STRIP:UpdateKeybindButtonGroup(loreLibraryReportKeybind)

end

local function ShowLoreLibraryCopyReport()

  LoreBooksReport:SetHidden(true)

  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SelectAll()
  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):TakeFocus()
  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SetTopLineIndex(1)

  LoreBooksCopyReport:SetHidden(false)

end

local function IsReportShown()
  return reportShown
end

local function BuildShalidorReport()

  local function DisplayCollectionsReport(collectionsData)

    local yCollectionIndex = 48

    table.sort(collectionsData, function(a, b)
      return a.totalBooks - a.numKnownBooks < b.totalBooks - b.numKnownBooks
    end)

    local lastObject = 0
    for collectionIndex, data in pairs(collectionsData) do

      local shalidorCollectionName = GetControl(LoreBooksReportContainerScrollChild, "CollectionName" .. collectionIndex)
      local shalidorCollectionValue = GetControl(LoreBooksReportContainerScrollChild, "CollectionValue" .. collectionIndex)

      if data.numKnownBooks ~= data.totalBooks then

        --[[TODO why was this a local assignment shadowed above and why is it here? ]]--
        shalidorCollectionName = GetControl(LoreBooksReportContainerScrollChild, "CollectionName" .. collectionIndex)
        shalidorCollectionValue = GetControl(LoreBooksReportContainerScrollChild, "CollectionValue" .. collectionIndex)

        if not shalidorCollectionName then
          shalidorCollectionName = CreateControlFromVirtual("$(parent)CollectionName", LoreBooksReportContainerScrollChild, "Lorebook_ShaliCollectionName_Template", collectionIndex)
          shalidorCollectionValue = CreateControlFromVirtual("$(parent)CollectionValue", LoreBooksReportContainerScrollChild, "Lorebook_ShaliCollectionValue_Template", collectionIndex)
        end

        shalidorCollectionValue:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 20, yCollectionIndex)
        shalidorCollectionName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 70, yCollectionIndex)

        yCollectionIndex = yCollectionIndex + 32

        shalidorCollectionName:SetText(data.name)
        shalidorCollectionValue:SetText(zo_strformat("<<1>>/<<2>>", data.numKnownBooks, data.totalBooks))

        copyReport = copyReport .. "\n\n" .. data.name .. " :\n" .. zo_strformat("<<1>>/<<2>>", data.numKnownBooks, data.totalBooks)
        lastObject = yCollectionIndex
      elseif shalidorCollectionName then
        -- Dirty trick
        shalidorCollectionName:SetHidden(true)
        shalidorCollectionValue:SetHidden(true)
      end

    end

    return lastObject + 10

  end

  local POINTS_FOR_RANK_MAX = 1380

  local totalKnown = 0
  local points = 0
  local booksInShalidor = 0

  collectionsData = {}
  local _, numCollections = GetLoreCategoryInfo(1)
  for collectionIndex = 1, numCollections do
    local name, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(1, collectionIndex)
    if not hidden then
      totalKnown = totalKnown + numKnownBooks
      booksInShalidor = booksInShalidor + totalBooks
      points = points + numKnownBooks * 5
      collectionsData[collectionIndex] = { name = name, numKnownBooks = numKnownBooks, totalBooks = totalBooks }
      if numKnownBooks == totalBooks then
        points = points + 20
      end
    end
  end

  local shalidorHeaderText = GetControl(LoreBooksReport, "ShalidorHeaderText")
  local lastObject = 52

  if points < POINTS_FOR_RANK_MAX then
    copyReport = GetString(LBOOKS_RS_FEW_BOOKS_MISSING)
    shalidorHeaderText:SetText(copyReport)
    lastObject = DisplayCollectionsReport(collectionsData)
  elseif totalKnown < booksInShalidor then
    copyReport = GetString(LBOOKS_RS_MDONE_BOOKS_MISSING)
    shalidorHeaderText:SetText(copyReport)
    lastObject = DisplayCollectionsReport(collectionsData)
  else
    copyReport = GetString(LBOOKS_RS_GOT_ALL_BOOKS)
    shalidorHeaderText:SetText(copyReport)
  end

  return lastObject

end

local function AllowEideticReport()
  return LORE_LIBRARY.eideticPossibleCollected - (LORE_LIBRARY.eideticCurrentlyCollected or 0) <= 225
end

local function BuildEideticReportPerMap(lastObject)

  local eideticHeaderText = GetControl(LoreBooksReport, "EideticHeaderText")
  eideticHeaderText:ClearAnchors()

  eideticHeaderText:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 4, lastObject)

  if AllowEideticReport() then

    eideticHeaderText:SetText(GetString(LBOOKS_RE_FEW_BOOKS_MISSING))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_FEW_BOOKS_MISSING)

    local eideticData = {}
    local eideticSeen = {}
    local yCollectionIndex = lastObject + 48

    for mapIndex = 1, GetNumMaps() do

      eideticData[mapIndex] = {}
      eideticBooks = LoreBooks_GetNewEideticDataForMapIndex(mapIndex)

      if eideticBooks then

        for _, bookData in ipairs(eideticBooks) do
          local _, _, known = GetLoreBookInfo(3, bookData.c, bookData.b)

          if not known and not eideticSeen[bookData.c .. "-" .. bookData.b] then
            table.insert(eideticData[mapIndex], bookData)
            eideticSeen[bookData.c .. "-" .. bookData.b] = true
          end

        end

        -- Create controls

        local eideticBooksInMap = GetControl(LoreBooksReportContainerScrollChild, "EideticBooksInMap" .. mapIndex)
        local eideticMapName = GetControl(LoreBooksReportContainerScrollChild, "EideticMapName" .. mapIndex)
        local eideticReportForMap = GetControl(LoreBooksReportContainerScrollChild, "EideticReportForMap" .. mapIndex)

        if not eideticMapName then
          eideticBooksInMap = CreateControlFromVirtual("$(parent)EideticBooksInMap", LoreBooksReportContainerScrollChild, "Lorebook_EideticBooksInMap_Template", mapIndex)
          eideticMapName = CreateControlFromVirtual("$(parent)EideticMapName", LoreBooksReportContainerScrollChild, "Lorebook_EideticMapName_Template", mapIndex)
          eideticReportForMap = CreateControlFromVirtual("$(parent)EideticReportForMap", LoreBooksReportContainerScrollChild, "Lorebook_EideticReportForMap_Template", mapIndex)
        else
          eideticBooksInMap:SetHidden(false)
          eideticMapName:SetHidden(false)
          eideticReportForMap:SetHidden(false)
        end

        local missingInMap = #eideticData[mapIndex]
        if missingInMap > 0 then

          eideticBooksInMap:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 0, yCollectionIndex)
          eideticMapName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 25, yCollectionIndex)
          eideticReportForMap:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 50, yCollectionIndex + 24)

          eideticBooksInMap:SetText(missingInMap)
          eideticMapName:SetText(zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)))

          local eideticReport = ""
          for index, data in ipairs(eideticData[mapIndex]) do
            local bookName = GetLoreBookInfo(3, data.c, data.b)
            eideticReport = zo_strjoin(" ; ", bookName, eideticReport)
          end

          if string.len(eideticReport) > 0 then
            eideticReport = string.sub(eideticReport, 0, -3)
          end

          eideticReportForMap:SetText(eideticReport)
          copyReport = copyReport .. "\n\n" .. zo_strformat("<<1>> (<<2>>):\n<<3>>", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)), missingInMap, eideticReport)

          eideticReportForMap:GetHeight() -- Needed to let the UI recalculate the correct value. Anchors could be optimized.

          yCollectionIndex = yCollectionIndex + eideticReportForMap:GetHeight() + 32

        end

      end
    end

  else
    eideticHeaderText:SetText(GetString(LBOOKS_RE_THREESHOLD_ERROR))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_THREESHOLD_ERROR)
  end

end

local function BuildEideticReportPerCollection(lastObject)

  local eideticHeaderText = GetControl(LoreBooksReport, "EideticHeaderText")
  eideticHeaderText:ClearAnchors()

  eideticHeaderText:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 4, lastObject)

  if AllowEideticReport() then

    eideticHeaderText:SetText(GetString(LBOOKS_RE_FEW_BOOKS_MISSING))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_FEW_BOOKS_MISSING)

    local totalBooks = 0
    local eideticData = {}
    local yCollectionIndex = lastObject + 48

    local categoryName, numCollections = GetLoreCategoryInfo(3) -- Only Eidetic

    for collectionIndex = 1, numCollections do

      eideticData[collectionIndex] = {}

      local collectionName, _, _, totalBooksInCollection, hidden = GetLoreCollectionInfo(3, collectionIndex)

      if not hidden then

        for bookIndex = 1, totalBooksInCollection do
          local bookName, _, known = GetLoreBookInfo(3, collectionIndex, bookIndex)

          if not known then
            eideticData[collectionIndex][bookIndex] = bookName
          end
        end

        -- Create controls

        local missingInCollection = NonContiguousCount(eideticData[collectionIndex])
        if missingInCollection > 0 then

          local eideticReport = ""

          local eideticBooksInCollection = GetControl(LoreBooksReportContainerScrollChild, "EideticBooksInCollection" .. collectionIndex)
          local eideticCollectionName = GetControl(LoreBooksReportContainerScrollChild, "EideticCollectionName" .. collectionIndex)
          local eideticReportForCollection = GetControl(LoreBooksReportContainerScrollChild, "EideticReportForCollection" .. collectionIndex)

          if not eideticCollectionName then
            eideticBooksInCollection = CreateControlFromVirtual("$(parent)EideticBooksInCollection", LoreBooksReportContainerScrollChild, "Lorebook_EideticBooksInCollection_Template", collectionIndex)
            eideticCollectionName = CreateControlFromVirtual("$(parent)EideticCollectionName", LoreBooksReportContainerScrollChild, "Lorebook_EideticCollectionName_Template", collectionIndex)
            eideticReportForCollection = CreateControlFromVirtual("$(parent)EideticReportForCollection", LoreBooksReportContainerScrollChild, "Lorebook_EideticReportForCollection_Template", collectionIndex)
          else
            eideticBooksInCollection:SetHidden(false)
            eideticCollectionName:SetHidden(false)
            eideticReportForCollection:SetHidden(false)
          end

          eideticBooksInCollection:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 0, yCollectionIndex)
          eideticCollectionName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 25, yCollectionIndex)
          eideticReportForCollection:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 50, yCollectionIndex + 24)

          eideticBooksInCollection:SetText(missingInCollection)
          eideticCollectionName:SetText(collectionName)

          for bookIndex, bookName in pairs(eideticData[collectionIndex]) do

            local bookLocation = ""
            local bookData = LoreBooks_GetNewEideticData(3, collectionIndex, bookIndex)
            if bookData then
              if bookData.r then
                bookLocation = "[B] "
              elseif bookData.e then
                if bookData.e[1] then
                  bookLocation = string.format("[%s] ", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(bookData.e[1].m)))
                else
                  bookLocation = "[Q] "
                end
              end
            end

            eideticReport = zo_strjoin("; ", bookLocation .. bookName, eideticReport)

          end

          if string.len(eideticReport) > 0 then
            eideticReport = string.sub(eideticReport, 0, -3)
          end
          eideticReportForCollection:SetText(eideticReport)

          copyReport = copyReport .. "\n\n" .. zo_strformat("<<1>> (<<2>>):\n<<3>>", collectionName, missingInCollection, eideticReport)

          eideticReportForCollection:GetHeight() -- Needed to let the UI recalculate the correct value. Anchors could be optimized.

          yCollectionIndex = yCollectionIndex + eideticReportForCollection:GetHeight() + 32

          totalBooks = totalBooks + missingInCollection
        end
      end
    end

  else
    eideticHeaderText:SetText(GetString(LBOOKS_RE_THREESHOLD_ERROR))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_THREESHOLD_ERROR)
  end

end

local function BuildEideticReport(lastObject)

  if eideticModeAsked == 2 then
    BuildEideticReportPerCollection(lastObject)
  else
    BuildEideticReportPerMap(lastObject)
  end

end

local function HidePreviousReport()
  for childIndex = 1, LoreBooksReportContainerScrollChild:GetNumChildren() do
    local childObject = LoreBooksReportContainerScrollChild:GetChild(childIndex)
    local childName = childObject:GetName()
    if childName ~= "LoreBooksReportEideticHeaderText" and string.find(childName, "Eidetic") then
      childObject:SetHidden(true)
    end
  end
end

-- Todo : use ZO_ScrollList. Difficulty : height is not the same
local function BuildLoreBookSummary()

  HidePreviousReport()

  local lastObject = BuildShalidorReport()

  BuildEideticReport(lastObject)

  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SetText(copyReport)

end

local function SwitchLoreLibraryReportMode()

  if not eideticModeAsked or eideticModeAsked == 1 then
    eideticModeAsked = 2
  else
    eideticModeAsked = 1
  end

  BuildLoreBookSummary()

end

local function BuildCategoryList(self)

  if self.control:IsControlHidden() then
    self.dirty = true
    return
  end

  self.totalCurrentlyCollected = 0
  self.totalPossibleCollected = 0
  self.motifsCurrentlyCollected = 0
  self.motifsPossibleCollected = 0
  self.shalidorCurrentlyCollected = 0
  self.shalidorPossibleCollected = 0
  self.eideticCurrentlyCollected = 0
  self.eideticPossibleCollected = 0

  self.navigationTree:Reset()

  local lbcategories = {}

  for categoryIndex = 1, GetNumLoreCategories() do
    local categoryName, numCollections = GetLoreCategoryInfo(categoryIndex)
    for collectionIndex = 1, numCollections do
      local collectionName, _, _, _, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
      if collectionName and (not hidden) then
        lbcategories[#lbcategories + 1] = { categoryIndex = categoryIndex, name = categoryName, numCollections = numCollections }
        break --Don't really understand why ZOS added this.
      end
    end
  end

  table.sort(lbcategories, NameSorter)

  for i, categoryData in ipairs(lbcategories) do
    local parent = self.navigationTree:AddNode("ZO_LabelHeader", categoryData)

    lbcategories[i].lbcollections = {}

    for collectionIndex = 1, categoryData.numCollections do
      local collectionName, description, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryData.categoryIndex, collectionIndex)
      if collectionName and ((db.unlockEidetic and collectionName ~= "") or not hidden) then
        lbcategories[i].lbcollections[#lbcategories[i].lbcollections + 1] = { categoryIndex = categoryData.categoryIndex, collectionIndex = collectionIndex, name = collectionName, description = description, numKnownBooks = numKnownBooks, totalBooks = totalBooks }
        self.totalCurrentlyCollected = self.totalCurrentlyCollected + numKnownBooks
        self.totalPossibleCollected = self.totalPossibleCollected + totalBooks

        if categoryData.categoryIndex == 2 then
          -- CRAFTING
          self.motifsCurrentlyCollected = self.motifsCurrentlyCollected + numKnownBooks
          self.motifsPossibleCollected = self.motifsPossibleCollected + totalBooks
        elseif categoryData.categoryIndex == 3 then
          --
          self.eideticCurrentlyCollected = self.eideticCurrentlyCollected + numKnownBooks
          self.eideticPossibleCollected = self.eideticPossibleCollected + totalBooks
        end
      end
    end

    table.sort(lbcategories[i].lbcollections, NameSorter)

    local search = string.lower(LORE_LIBRARY.search)
    for _, collectionData in ipairs(lbcategories[i].lbcollections) do
      if search ~= "" and string.len(search) >= 2 then
        if IsFoundInLoreLibrary(search, collectionData) then
          self.navigationTree:AddNode("ZO_LoreLibraryNavigationEntry", collectionData, parent)
        end
      else
        self.navigationTree:AddNode("ZO_LoreLibraryNavigationEntry", collectionData, parent)
      end
    end

  end

  self.navigationTree:Commit()
  self:RefreshCollectedInfo()

  --Dirty hack to unselect all nodes and select the 1st one.

  if self.navigationTree.rootNode.children then
    if self.navigationTree.rootNode.children[1] and self.navigationTree.rootNode.children[1].children then
      self.navigationTree:SelectNode(self.navigationTree.rootNode.children[1].children[1])
    elseif self.navigationTree.rootNode.children[2] and self.navigationTree.rootNode.children[2].children then
      self.navigationTree:SelectNode(self.navigationTree.rootNode.children[2].children[1])
    end
  end

  KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

  self.dirty = false

  return true

end

local function Sanitize(value)
  return value:gsub("[-*+?^$().[%]%%]", "%%%0") -- escape meta characters
end

local function FilterScrollList(self)

  local BOOK_DATA_TYPE = 1

  local categoryIndex = self.owner:GetSelectedCategoryIndex()
  local collectionIndex = self.owner:GetSelectedCollectionIndex()

  local totalBooks = select(4, GetLoreCollectionInfo(categoryIndex, collectionIndex))

  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ScrollList_Clear(self.list)

  local search = Sanitize(string.lower(LORE_LIBRARY.search))

  if search ~= "" and string.len(search) >= 2 then
    for bookIndex = 1, totalBooks do
      local bookName = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
      if string.find(string.lower(bookName), search) then
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(BOOK_DATA_TYPE, { categoryIndex = categoryIndex, collectionIndex = collectionIndex, bookIndex = bookIndex })
      end
    end
  else
    for bookIndex = 1, totalBooks do
      scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(BOOK_DATA_TYPE, { categoryIndex = categoryIndex, collectionIndex = collectionIndex, bookIndex = bookIndex })
    end
  end

  return true

end

-- "Right clic"
local function OnRowMouseUp(control, button)
  if button == MOUSE_BUTTON_INDEX_RIGHT then
    ClearMenu()

    -- Cannot access to self. (and self ~= control here)
    --SetMenuHiddenCallback(function() self:UnlockSelection() end)
    --self:LockSelection()

    if control.known then
      AddCustomMenuItem(GetString(SI_LORE_LIBRARY_READ), function() ZO_LoreLibrary_ReadBook(control.categoryIndex, control.collectionIndex, control.bookIndex) end)
    end

    if IsChatSystemAvailableForCurrentPlatform() then
      AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
        local link = ZO_LinkHandler_CreateChatLink(GetLoreBookLink, control.categoryIndex, control.collectionIndex, control.bookIndex)
        ZO_LinkHandler_InsertLink(link)
      end)
    end

    if control.categoryIndex == 1 then
      local lorebookInfoOnBook = LoreBooks_GetDataOfBook(control.categoryIndex, control.collectionIndex, control.bookIndex)
      for resultEntry, resultData in ipairs(lorebookInfoOnBook) do

        if resultData.mapId then
          AddCustomMenuItem(zo_strformat("<<1>> : <<2>>x<<3>>", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(resultData.mapId)), (resultData.locX * 100), (resultData.locY * 100)),
            function()
              local changeResult = SetMapToMapId(resultData.mapId)
              GPS:SetPlayerChoseCurrentMap()
              CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
              PingMap(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, resultData.locX, resultData.locY)
              PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, resultData.locX, resultData.locY)

              if (not ZO_WorldMap_IsWorldMapShowing()) then
                if IsInGamepadPreferredMode() then
                  SCENE_MANAGER:Push("gamepad_worldMap")
                else
                  MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)
                end
                zo_callLater(function() ZO_WorldMap_GetPanAndZoom():PanToNormalizedPosition(resultData.locX, resultData.locY) end, 1000)
              end
            end)
        end

      end
    elseif control.categoryIndex == 3 then

      local bookData = LoreBooks_GetNewEideticData(control.categoryIndex, control.collectionIndex, control.bookIndex)

      if bookData and bookData.c and bookData.e then

        for index, data in ipairs(bookData.e) do
          local mapId = data.pm
          local mapName = GetMapNameById(mapId)

          if not data.r and not data.fp and data.px and data.py then

            local xTooltip = ("%0.02f"):format(zo_round(data.px * 10000) / 100)
            local yTooltip = ("%0.02f"):format(zo_round(data.py * 10000) / 100)
            local xLoc, yLoc = GPS:GlobalToLocal(data.px, data.py)
            AddCustomMenuItem(zo_strformat("<<1>> (<<2>>x<<3>>)", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, mapName), xTooltip, yTooltip),
              function()
                local changeResult = SetMapToMapId(mapId)
                GPS:SetPlayerChoseCurrentMap()
                CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
                PingMap(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, xLoc, yLoc)
                PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, xLoc, yLoc)

                if (not ZO_WorldMap_IsWorldMapShowing()) then
                  if IsInGamepadPreferredMode() then
                    SCENE_MANAGER:Push("gamepad_worldMap")
                  else
                    MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)
                  end
                  mapIsShowing = true
                  zo_callLater(function() ZO_WorldMap_GetPanAndZoom():PanToNormalizedPosition(xLoc, yLoc) end, 1000)
                end

              end)

          end -- end if
        end
      end

    end

    ShowMenu(control)

  end
end

-- Mouse "hover"
local function OnMouseEnter(self, categoryIndex, collectionIndex, bookIndex)
  --d("we are here")
  local STD_ZONE = 0

  -- No 1 for now.
  if categoryIndex == 3 then

    local bookData = LoreBooks_GetNewEideticData(categoryIndex, collectionIndex, bookIndex)
    --d(bookData)

    if bookData and bookData.c then
      --d("first c or cn")
      local bookName = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) -- Could be retrieved automatically
      InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 0, TOPRIGHT)
      InformationTooltip:AddLine(bookName, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
      ZO_Tooltip_AddDivider(InformationTooltip)

      local addDivider
      local entryWeight = {}
      if bookData.q then
        --d("second with q")
        local qName = getQuestName(bookData.q)
        InformationTooltip:AddLine(GetString(LBOOKS_QUEST_BOOK), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        InformationTooltip:AddLine(string.format("[%s]", qName), "", ZO_SELECTED_TEXT:UnpackRGB())

        --[[TODO LBOOKS_SPECIAL_QUEST was added in version 4, not before
        However, there is no strings definition for it.

        Added a string but no idea what the intention was

        04/22 qt doesn't exist

        qm is whatever is being used at the time for the quest location.
        Meaning that when qm is 13 then the zoneId could be 13, but
        if qm is 43 and that is the mapIndex then qm was set to 43.
        However, to get the zone name of the quest you just use the
        questId to get the zoneId and then the name of the zone.

        Bacause of that

        local questDetails
        if bookData.qt then
          questDetails = zo_strformat(GetString(LBOOKS_SPECIAL_QUEST), bookData.qt)
        elseif bookData.qm then
          questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), getQuestLocation(bookData.q))
        end
        ]]--
        local questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), getQuestLocation(bookData.q))
        InformationTooltip:AddLine(questDetails)

      elseif bookData.r and bookData.m and NonContiguousCount(bookData.m) > 1 then
        --d("third r and m")

        InformationTooltip:AddLine(GetString(LBOOKS_RANDOM_POSITION), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        ZO_Tooltip_AddDivider(InformationTooltip)

        for mapId, count in pairs(bookData.m) do
          InformationTooltip:AddLine(zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(mapId)), "", ZO_SELECTED_TEXT:UnpackRGB())
        end

      else
        --d("the else")
        for index, data in ipairs(bookData.e) do
          if data and not data.fp then
            local insert = true
            local isRandom = data.r
            local inDungeon = data.d
            local isFromBag = data.i == INTERACTION_NONE

            local mapId = data.pm
            local name, _, _, zoneIndex, _ = GetMapInfoById(mapId)
            --d(name)
            --d(zoneIndex)

            local weight = 0
            if isRandom then
              weight = weight + 1
            end
            if inDungeon then
              weight = weight + 2
            end

            local zoneName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(zoneIndex))
            local mapName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(mapId))

            local bookPosition
            if zoneName ~= mapName then
              bookPosition = zo_strformat("<<1>> - <<2>>", mapName, zoneName)
              if entryWeight[bookPosition] and entryWeight[bookPosition][weight] then
                insert = false
              end
            else
              bookPosition = mapName
              if entryWeight[bookPosition] and entryWeight[bookPosition][weight] then
                insert = false
              end
            end

            if not entryWeight[bookPosition] then entryWeight[bookPosition] = {} end
            entryWeight[bookPosition][weight] = true

            if insert then
              if addDivider then
                ZO_Tooltip_AddDivider(InformationTooltip)
              end
              addDivider = true

              InformationTooltip:AddLine(bookPosition, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())

              if inDungeon then
                InformationTooltip:AddLine(zo_strformat("[<<1>>]", GetString(SI_QUESTTYPE5)), "", ZO_SELECTED_TEXT:UnpackRGB())
              end

              if isFromBag then
                InformationTooltip:AddLine(GetString(LBOOKS_MAYBE_NOT_HERE), "", ZO_SELECTED_TEXT:UnpackRGB())
              elseif isRandom then
                InformationTooltip:AddLine(GetString(LBOOKS_RANDOM_POSITION))
              end

            end

          end
        end

      end -- end else

    elseif bookData and bookData.l then

      local bookName = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) -- Could be retrieved automatically
      InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 0, TOPRIGHT)
      InformationTooltip:AddLine(bookName, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
      ZO_Tooltip_AddDivider(InformationTooltip)

      if bookData.q then
        local qName = getQuestName(bookData.q)
        InformationTooltip:AddLine(GetString(LBOOKS_QUEST_BOOK), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        InformationTooltip:AddLine(string.format("[%s]", qName), "", ZO_SELECTED_TEXT:UnpackRGB())

        local questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), getQuestLocation(bookData.q))
        InformationTooltip:AddLine(questDetails)
        ZO_Tooltip_AddDivider(InformationTooltip)

      end

      InformationTooltip:AddLine(GetString(LBOOKS_MAYBE_NOT_HERE), "", ZO_SELECTED_TEXT:UnpackRGB())

    end

  end

  self.owner:EnterRow(self)

end

local function OnMouseExit(self)
  ClearTooltip(InformationTooltip)
  self.owner:ExitRow(self)
end

function BuildBookListPostHook()
  local orgCallback = LORE_LIBRARY.list.list.dataTypes[1].setupCallback
  LORE_LIBRARY.list.list.dataTypes[1].setupCallback = function(control, data)
    orgCallback(control, data)
    if not control.lbhooked then
      control.lbhooked = true
      control:SetHandler("OnMouseUp", OnRowMouseUp)
      control:SetHandler("OnMouseEnter", function(control) OnMouseEnter(control, control.categoryIndex, control.collectionIndex, control.bookIndex) end)
      control:SetHandler("OnMouseExit", function(control) OnMouseExit(control) end)
      control:GetNamedChild("Text"):SetMouseEnabled(false)
    end
  end
end

local canShare
function LoreBooks.CanShareData()
  --if canShare == nil then
  --	canShare = false
  --	if GetAPIVersion() == c.SUPPORTED_API and c.SUPPORTED_LANG[lang] and GetWorldName() == "EU Megaserver" then
  --		canShare = true
  --	end
  --end
  return canShare
end

local function RebuildLoreLibrary()

  loreLibraryReportKeybind = {
    {
      alignment = KEYBIND_STRIP_ALIGN_LEFT,
      name = GetString(LBOOKS_REPORT_KEYBIND_RPRT),
      keybind = "UI_SHORTCUT_SECONDARY",
      callback = ShowLoreLibraryReport,
    },
    {
      alignment = KEYBIND_STRIP_ALIGN_LEFT,
      name = GetString(LBOOKS_REPORT_KEYBIND_SWITCH),
      keybind = "UI_SHORTCUT_QUATERNARY",
      callback = SwitchLoreLibraryReportMode,
      visible = IsReportShown,
    },
    {
      alignment = KEYBIND_STRIP_ALIGN_LEFT,
      name = GetString(LBOOKS_REPORT_KEYBIND_COPY),
      keybind = "UI_SHORTCUT_TERTIARY",
      callback = ShowLoreLibraryCopyReport,
      visible = IsReportShown,
    },
  }

  local function OnStateChanged(oldState, newState)
    if newState == SCENE_SHOWING then
      KEYBIND_STRIP:AddKeybindButtonGroup(loreLibraryReportKeybind)
    elseif newState == SCENE_HIDDEN then
      KEYBIND_STRIP:RemoveKeybindButtonGroup(loreLibraryReportKeybind)
      ShowLoreLibraryReport(true)
    end
  end

  LORE_LIBRARY_SCENE:RegisterCallback("StateChange", OnStateChanged)

  local lorebookResearch = WINDOW_MANAGER:CreateControlFromVirtual("Lorebook_Research", ZO_LoreLibrary, "Lorebook_Research_Template")
  lorebookResearch.searchBox = GetControl(lorebookResearch, "Box")
  lorebookResearch.searchBox:SetHandler("OnTextChanged", OnSearchTextChanged)

  ZO_PreHook(LORE_LIBRARY, "BuildCategoryList", BuildCategoryList)
  ZO_PreHook(LORE_LIBRARY.list, "FilterScrollList", FilterScrollList)

  --LoreBooks.EmulateLibrary()
  BuildLorebooksLoreLibrary()
  --BuildLoreBookSummary()

  local origLoreLibraryBuildBookList = LORE_LIBRARY.BuildBookList
  LORE_LIBRARY.BuildBookList = function(self, ...)
    origLoreLibraryBuildBookList(self, ...)
    BuildBookListPostHook()
  end

  local includeMotifsCheckbox = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)IncludeMotifs", LORE_LIBRARY.totalCollectedLabel, "ZO_CheckButton")

  includeMotifsCheckbox:SetAnchor(LEFT, LORE_LIBRARY.totalCollectedLabel, RIGHT, 85, 0)

  ZO_CheckButton_SetLabelText(includeMotifsCheckbox, GetString(LBOOKS_INCLUDE_MOTIFS_CHECKBOX))
  ZO_CheckButton_SetToggleFunction(includeMotifsCheckbox, function()
    LORE_LIBRARY:RefreshCollectedInfo()
  end)

  LORE_LIBRARY.RefreshCollectedInfo = function(library)

    local currentlyCollected = library.totalCurrentlyCollected
    local possibleCollected = library.totalPossibleCollected

    if not ZO_CheckButton_IsChecked(includeMotifsCheckbox) then
      currentlyCollected = currentlyCollected - library.motifsCurrentlyCollected
      possibleCollected = possibleCollected - library.motifsPossibleCollected
    end
    library.totalCollectedLabel:SetText(zo_strformat(SI_LORE_LIBRARY_TOTAL_COLLECTED, currentlyCollected, possibleCollected))
  end
end

--[[TODO is this needed anymore? ]]--
local function IsPlayerOnCurrentMap()

  local x, y = GetMapPlayerPosition("player")
  if not InvalidPoint(x, y) then
    return true
  end
  return false

end

local lastReadBook
local shownBookId
local currentOpenBook
local function OnShowBook(eventCode, bookTitle, body, medium, showTitle, bookId)
  lastReadBook = bookTitle
  currentOpenBook = bookTitle
  shownBookId = bookId
  --if minerEnabled and db.shareData then
  --    local dataToShare = minerCallback(bookId)
  --    if dataToShare then
  --        SendData(dataToShare)
  --    end
  --end
end

local function OnHideBook(eventCode)
  currentOpenBook = nil
  shownBookId = nil
end

local function OnBookLearned(_, categoryIndex)

  if categoryIndex ~= 2 then

    --Refresh map if needed and get player position
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
      CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end

    local x, y = GetMapPlayerPosition("player")

    if not InvalidPoint(x, y) then
      -- can be false in some very rare place (mainly fighters/mages/main questline dungeons).

      if categoryIndex == 1 then
        LMP:RefreshPins(c.PINS_UNKNOWN)
        LMP:RefreshPins(c.PINS_COLLECTED)
        COMPASS_PINS:RefreshPins(c.PINS_COMPASS)
      elseif categoryIndex == 3 then
        LMP:RefreshPins(c.PINS_EIDETIC)
        LMP:RefreshPins(c.PINS_EIDETIC_COLLECTED)
        LMP:RefreshPins(c.PINS_BOOKSHELF)
        COMPASS_PINS:RefreshPins(c.PINS_COMPASS_EIDETIC)
        COMPASS_PINS:RefreshPins(c.PINS_COMPASS_BOOKSHELF)
      end

    end
  end

  --BuildLoreBookSummary()

end

function LoreBooks.ToggleUseQuestBooks()

  if db.useQuestBooks then

    local function ScanQuestTools(_, journalIndex, questName)
      local questData = SHARED_INVENTORY:GetOrCreateQuestCache(journalIndex)
      if questData then
        for itemId, itemData in pairs(questData) do
          if itemData.toolIndex and CanUseQuestTool(journalIndex, itemData.toolIndex) and db.questTools[itemId] ~= questName then
            db.questTools[itemId] = questName
            if itemData.name ~= lastReadBook then
              -- some quests are started by reading a note/book which is then also added as a quest item, skip those
              UseQuestTool(journalIndex, itemData.toolIndex)
            end
          end
        end
      end
    end

    local function ClearQuestTools(_, isCompleted, journalIndex, questName)
      if isCompleted then
        -- we only clear it when it gets completed so it doesn't keep reading it if the player restart the quest
        for itemId, parentQuest in pairs(db.questTools) do
          if parentQuest == questName then
            db.questTools[itemId] = nil
          end
        end
      end
    end
    EVENT_MANAGER:RegisterForEvent("LoreBooks", EVENT_QUEST_ADDED, ScanQuestTools)
    EVENT_MANAGER:RegisterForEvent("LoreBooks", EVENT_QUEST_ADVANCED, ScanQuestTools)
    EVENT_MANAGER:RegisterForEvent("LoreBooks", EVENT_QUEST_REMOVED, ClearQuestTools)
  else
    EVENT_MANAGER:UnregisterForEvent("LoreBooks", EVENT_QUEST_ADDED)
    EVENT_MANAGER:UnregisterForEvent("LoreBooks", EVENT_QUEST_ADVANCED)
    EVENT_MANAGER:UnregisterForEvent("LoreBooks", EVENT_QUEST_REMOVED)

  end

end

-- slash commands -------------------------------------------------------------
local approved_interaction_types = {
  [GetString(SI_GAMECAMERAACTIONTYPE1)] = true, -- Search
  [GetString(SI_GAMECAMERAACTIONTYPE6)] = true, -- Read
  [GetString(SI_GAMECAMERAACTIONTYPE10)] = true, -- Inspect
  [GetString(SI_GAMECAMERAACTIONTYPE15)] = true, -- Examine
}

local reticleInteractionName
ZO_PreHook(ZO_Reticle, "TryHandlingInteraction", function(interactionPossible, currentFrameTimeSeconds)
  local action, name, interactBlocked, isOwned, additionalInfo, contextualInfo, contextualLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
  if name and approved_interaction_types[action] then
    --d(name)
    reticleInteractionName = name
  else
    reticleInteractionName = nil
  end
end)

local function is_in(search_value, search_table)
  for _, v in pairs(search_table) do
    if search_value == v then return true end
    if type(search_value) == "string" then
      if string.find(string.lower(v), string.lower(search_value)) then return true end
    end
  end
  return false
end

local function isMainMapId(mapId)
  if mapId == 0 or mapId == nil then return false end
  for _, data in pairs(LoreBooks.mapIndexData) do
    if data.mapId then return true end
  end
  if LoreBooks.mapIndexData then return true end
  return false
end
local function isMainZoneId(zoneId)
  if zoneId == 0 or zoneId == nil then return false end
  for _, data in pairs(LoreBooks.mapIndexData) do
    if data.zoneId then return true end
  end
  return false
end

local function GetLorebookNames()
  local categoryIndex
  local collectionIndex
  local bookIndex
  local bookTitle
  local name
  local bookId
  local mapIdFromZoneId
  local mapIdFromMapIndex
  local mapIdFromMapId
  local local_x
  local local_y
  local saveData = true
  local count = 0
  local count2 = 0
  local count3 = 0
  local bad = 0
  local isDungeon = false

  local allBookData = LoreBooks_GetBookData()
  local LoreBooks_bookData = ZO_DeepTableCopy(allBookData)
  for i = 1, 10000 do
    -- 45 zones by index
    local name, mapType, mapContentType, zoneIndex, description = GetMapInfoByIndex(i)
    local zoneNameByZoneIndex = GetZoneNameByIndex(zoneIndex)
    local zoneIdByZoneIndex = GetZoneId(zoneIndex)
    local mapIdByZoneId = GetMapIdByZoneId(zoneIdByZoneIndex)
    local mapTextureByMapId = GetMapTileTextureForMapId(mapIdByZoneId, 1)
    local mapTexture = string.lower(mapTextureByMapId)
    mapTexture = mapTexture:gsub("^.*/maps/", "")
    mapTexture = mapTexture:gsub("%.dds$", "")
    local theInfo = {
      zoneName = name,
      zoneId = zoneIdByZoneIndex,
      mapId = mapIdByZoneId,
      mapTexture = mapTexture,
      zoneIndex = zoneIndex,
      mapIndex = i,
    }
    local mapNameByMapIndex = GetMapNameByIndex(i)
    local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(i)
    if categoryIndex == 3 and collectionIndex and bookIndex then
      bookTitle, _, _, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
      name, _, _, _, _, _, _ = GetLoreCollectionInfo(categoryIndex, collectionIndex)
      if not LoreBooks_bookData[bookId] then LoreBooks_bookData[bookId] = {} end
      if LoreBooks_bookData[bookId] then
        if bookTitle then LoreBooks_bookData[bookId].n = bookTitle end
        if name then LoreBooks_bookData[bookId].cn = name end
        if not LoreBooks_bookData[bookId].e then
          LoreBooks_bookData[bookId].e = {}
          LoreBooks_bookData[bookId].c = false
        end
        LoreBooks_bookData[bookId].k = nil
        LoreBooks_bookData[bookId].qt = nil
        LoreBooks_bookData[bookId].qm = nil
        local newMapData = {}
        if LoreBooks_bookData[bookId].r and LoreBooks_bookData[bookId].m and NonContiguousCount(LoreBooks_bookData[bookId].m) > 1 then
          for mapIndex, numSeen in pairs(LoreBooks_bookData[bookId].m) do
            local mapId = GetMapIdByIndex(mapIndex)
            newMapData[mapId] = numSeen
          end
          LoreBooks_bookData[bookId].m = newMapData
        end -- good
        if LoreBooks_bookData[bookId].q then
          LoreBooks_bookData[bookId].m = nil
        end

        local newMapData = {}
        if NonContiguousCount(LoreBooks_bookData[bookId].e) > 0 then
          for _, data in pairs(LoreBooks_bookData[bookId].e) do
            mapIdFromZoneId = nil
            mapIdFromMapIndex = nil
            mapIdFromMapId = nil
            local_x = nil
            local_y = nil
            saveData = true
            isDungeon = false

            local badMapIndex = (data.mn and data.mn == 1 or data.mn and data.mn == 24)
            local validZoneId = data.z ~= 0
            if data.g then isDungeon = true end
            
            if data and data.z then
              local mapId = GetMapIdByZoneId(data.z) 
              if mapId ~= 0 then mapIdFromZoneId = mapId end
            end
            if data and data.mn then
              local mapIndex = GetMapIndexByZoneId(data.z)
              data.mn = mapIndex
              local mapId = GetMapIdByZoneId(data.mn)
              if mapId ~= 0 then mapIdFromMapIndex = mapId end
            end
            if data and data.md then mapIdFromMapId = data.md end

            if data.x and data.y then
              local_x = data.x
              local_y = data.y
            end
            if not data.md and mapIdFromZoneId then
              data.pm = mapIdFromZoneId
            elseif not data.md and mapIdFromMapIndex then
              data.pm = mapIdFromMapIndex
            elseif not data.md and data.z and data.z ~= 0 then
                local zoneName = GetZoneNameById(data.z) or "[Empty String]"
                local theMapIndex = data.mn or "[No MapIndex]"
                if zoneName and LMD.mapNamesLookup[zoneName] then
                  --[[
                  for i = LMD.MAPINDEX_MIN, LMD.MAPINDEX_MAX do
                    if LMD.mapIndexData[i].zoneId == GetParentZoneId(data.z) then
                      --d("Works")
                    else
                      d("Nope")
                    end
                  end
                  ]]--
                  data.pm = LMD.mapNamesLookup[zoneName]
                  count = count + 1
                else
                  d(string.format("[LookUp] zoneName %s : zoneId: %s : mapIndex: %s : BookId : %s", zoneName, data.z, theMapIndex, bookId))
                  --d(data)
                  count2 = count2 + 1
                  data.zt = data.z
                end
            elseif not data.md then
                d("-----")
                d(data)
                bad = bad + 1
                saveData = false
            end
            if data.md then 
              data.pm = mapIdFromMapId 
              count3 = count3 + 1
            end
            data.md = nil
            data.z = nil
            data.zx = nil
            data.zy = nil
            data.x = nil
            data.y = nil

            data.px = local_x
            data.py = local_y

            if data.px and data.py and saveData then
              table.insert(newMapData, data)
            end

          end -- end for
          LoreBooks_bookData[bookId].e = newMapData
        end -- end if

      end
    end
  end
  d(count) -- keep
  d(count2) -- keep
  d(count3) -- keep
  d(bad) -- keep
  LBooks_SavedVariables.names = LoreBooks_bookData
end

--/script SetCVar("Language.2", "fr")
local bookShelfLocalization = {
  ["en"] = "Bookshelf",
  ["de"] = "Bücherregal",
  ["fr"] = "Étagère de livres",
  ["ru"] = "Книжная полка",
}
local function ShowMyPosition()
  local _, zone = LMP:GetZoneAndSubzone()
  local x, y = GetMapPlayerPosition("player")
  local xpos, ypos = GPS:LocalToGlobal(x, y)
  local info = GetLorebooksMapInfo()
  local zoneId
  local mapIndex
  local mapId
  local isMainZone
  local mapContentType = GetMapContentType()
  local bookName = ""
  local categoryIndex = 0
  local collectionIndex = ""
  local bookIndex = ""
  local bookId
  local isBookshelf
  if reticleInteractionName then
    isBookshelf = reticleInteractionName == bookShelfLocalization[GetCVar("Language.2")]
  end
  --d(isBookshelf)
  if info.z then zoneId = info.z end
  if info.mn then mapIndex = info.mn end
  if info.md then mapId = info.md end
  if info.mt then isMainZone = info.mt end
  if currentOpenBook then
    bookName = currentOpenBook
  end
  --d(currentOpenBook)
  --d(shownBookId)
  if not shownBookId then
    d(GetString(LBOOKS_LBPOS_OPEN_BOOK))
    return
  end
  if shownBookId then
    categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(shownBookId)
  end
  if collectionIndex and bookIndex then
    _, _, _, bookId = GetLoreBookInfo(3, collectionIndex, bookIndex)
  end
  -- /script d({GetLoreBookIndicesFromBookId(151)})
  -- /script d({GetLoreBookInfo(3, 21, 1)})
  if categoryIndex and categoryIndex == 1 then
    MyPrint(string.format("[%d] = { %.6f, %.6f, %s, %s, moreInfo }, -- %s, %s", mapId, x, y, collectionIndex, bookIndex, bookName, zone))
  elseif categoryIndex and categoryIndex > 1 then
    --[[
              local mapIndex = data.mn
            local zoneId = data.z
            local isRandom = data.r
            local inDungeon = data.d
            local isFromBag = data.i == INTERACTION_NONE

            TODO Why do we have a data field for the InteractionType but
            GetInteractionType isn't used
  ]]--
    local ef = '"e"'
    local rf = '"r"' -- isRandom
    local df = '"d"' -- inDungeon
    local mdf = '"pm"' -- mapId
    local pxf = '"px"' -- LibGPS x
    local pyf = '"py"' -- LibGPS y
    local xf = '"x"' -- used for zone bookshelf
    local yf = '"y"' -- used for zone bookshelf
    local i_f = '"i"' -- InteractionType, INTERACTION_NONE 12, 7, 0 values found
    local qf = '"q"' -- integer of QuestId or quest name
    local qmf = '"qm"' -- integer of zone quest belongs to ???
    local cf = '"c"' -- true/false seems used for quests
    local nf = '"n"' -- name, used with quests accompanied by c = true and possibly q
    local mf = '"m"' -- used for zone booklist
    local zf = '"z"' -- used for zone bookshelf
    local eideticBookName = '"' .. bookName .. '"'
    -- local unum = 0
    -- [6531] = { ["e"] = { [1] = { ["zx"] = 0.163847, ["zy"] = 0.579908, ["x"] = 0.597716, ["y"] = 0.680002, ["z"] = 1261, ["mn"] = 0, }, }, ["c"] = true, ["k"] = 6531, }, -- Tribes of Blackwood: Gideon and the Border, u30_leyawiincity_base
    --[[Note: with /tbugm the map pin for the Eidetic Data will have a ["b"] and ["c"]
    ["b"] = bookIndex from GetLoreBookIndicesFromBookId
    ["c"] = collectionIndex GetLoreBookIndicesFromBookId
    ]]--
    -- [6262] = { ["e"] = { [1] = { ["r"] = false, ["d"] = true, ["md"] = 1875, ["i"] = 12, ["mn"] = 29, ["x"] = 0.3408000000, ["y"] = 0.5460000000, ["zx"] = 0.5405206747, ["zy"] = 0.2796056287, ["z"] = 1228, }, }, ["c"] = true, ["n"] = "The Crowned Dragon", ["k"] = 6262, },
    -- [8] = { ["e"] = { [1] = { ["r"] = false, ["d"] = true, ["d"] = 0, ["i"] = 0, ["mn"] = 0, ["x"] = 0, ["y"] = 0, ["zx"] = 0, ["zy"] = 0, ["z"] = 0, }, }, ["c"] = true, ["n"] = "The Wolf and the Pirate Queen", ["k"] = 8, },
    -- [8] = { ["e"] = { [1] = { ["r"] = false, ["d"] = true, ["md"] = 0, ["i"] = 0, ["mn"] = 0, ["x"] = 0.679438, ["y"] = 0.251476, ["zx"] = 0.678918, ["zy"] = 0.627487, ["z"] = 0, }, }, ["c"] = true, ["n"] = "The Wolf and the Pirate Queen", ["k"] = 8, },
    -- [3651] = { ["e"] = { [1] = { ["r"] = false, ["d"] = true, ["md"] = 0, ["i"] = 0, ["mn"] = 29, ["zx"] = 0.548708, ["zy"] = 0.404540, ["x"] = 0.341620, ["y"] = 0.558493, ["z"] = 823, }, }, ["c"] = true, ["n"] = "Gold Coast Guide, Part Two", ["k"] = 3651, },
    -- verified working MyPrint, still a few unknown fields
    -- MyPrint(string.format("[%d] = { [%s] = { [1] = { [%s] = false, [%s] = true, [%s] = %d, [%s] = %d, [%s] = %d, [%s] = %.6f, [%s] = %.6f, [%s] = %.6f, [%s] = %.6f, [%s] = %d, }, }, [%s] = true, [%s] = %s, },",
    -- shownBookId, ef, rf, df, mdf, unum, i_f, unum, mnf, mapIndex, xf, x, yf, y, gxf, xpos, gyf, ypos, zf, zoneId, cf, nf, eideticBookName))

    -- [3999] = { ["e"] = { [1] = { ["zx"] = 0.1864611820, ["zy"] = 0.3665820524, ["x"] = 0.7147000000, ["y"] = 0.2872200000, ["z"] = 849, ["mn"] = 30, }, }, ["c"] = true, ["k"] = 3999,
    -- [3678] = { ["e"] = { [1] = { ["zx"] = 0.269644, ["zy"] = 0.179828, ["x"] = 0.313714, ["y"] = 0.536022, ["z"] = 823, ["mn"] = 29, }, }, ["c"] = true, ["k"] = 3678, }, -- Knightsgrave: Legend or Legacy, goldcoast_base
    -- [3706] = { ["e"] = { [1] = { ["zx"] = 0.217336, ["zy"] = 0.196732, ["x"] = 0.308483, ["y"] = 0.537712, ["z"] = 823, ["mn"] = 29, }, }, ["c"] = true, ["k"] = 3706, }, -- Fantos Epilion's Journal, goldcoast_base
    -- verified working MyPrint, all fields match truncated data
    local outText = GetString(LBOOKS_LBPOS_ERROR)
    local dvalue = mapContentType == MAP_CONTENT_DUNGEON
    if dvalue then
      outText = string.format("[%d] = { [%s] = { [1] = { [%s] = %.10f, [%s] = %.10f, [%s] = %d, [%s] = %s, }, }, }, -- %s, %s",
        shownBookId, ef, pxf, xpos, pyf, ypos, mdf, mapId, df, tostring(dvalue), bookName, zone)
    else
      outText = string.format("[%d] = { [%s] = { [1] = { [%s] = %.10f, [%s] = %.10f, [%s] = %d, }, }, }, -- %s, %s",
        shownBookId, ef, pxf, xpos, pyf, ypos, mdf, mapId, bookName, zone)
    end
    -- [2828] = { ["e"] = { [1] = { ["zx"] = 0.255800, ["zy"] = 0.455359, ["x"] = 0.599286, ["y"] = 0.677876, ["md"] = 1940, }, }, ["k"] = 2828, }, -- The Black Fin: Foreign Adventures, Part 2, u30_leyawiincity_base
    -- [2828] = { ["m"] = { [mapId] = 1, }, ["k"] = 2828, }, [mapId] = { ["x"] = 0.255308, ["y"] = 0.454024, ["z"] = zoneId }, -- The Black Fin: Foreign Adventures, Part 2, u30_leyawiincity_base
    -- using the zone normalized coords but the key is x, y for bookshelf pin data
    -- [2828] = { ["m"] = { [1940] = 1, }, ["k"] = 2828, }, [1940] = { ["x"] = 0.255800, ["y"] = 0.455359, ["z"] = 1261 }, -- The Black Fin: Foreign Adventures, Part 2, u30_leyawiincity_base
    if isBookshelf then
      outText = string.format("[%d] = { [%s] = { [%d] = 1, }, }, [%d] = { [%s] = %.10f, [%s] = %.10f, [%s] = %d, }, -- %s, %s",
        shownBookId, mf, mapId, mapId, xf, xpos, yf, ypos, zf, zoneId, bookName, zone)
    end
    -- [6473] = { ["e"] = { [1] = { ["zx"] = 0.562083, ["zy"] = 0.524402, ["x"] = 0.378672, ["y"] = 0.287162, ["z"] = 1207, }, }, ["k"] = 6473, }, -- Great Spirits of the Reach: Volume 2, reach_base
    -- [6071] = { ["e"] = { [1] = { ["zx"] = 0.434603, ["zy"] = 0.227340, ["x"] = 0.344336, ["y"] = 0.305401, ["md"] = 1871, ["d"] = true, }, }, ["k"] = 6071, }, -- How to Pronounce Dwemer Words, briarrockruins_int01_base
    MyPrint(outText)
    -- [6531] = { ["e"] = { [1] = { ["zx"] = 0.163823, ["zy"] = 0.579908, ["x"] = 0.597716, ["y"] = 0.680002, ["z"] = 1261, ["mn"] = 0, }, }, ["c"] = true, ["k"] = 6531, }, -- Tribes of Blackwood: Gideon and the Border, u30_leyawiincity_base
    --[[
          bad argument #15 to 'string.format' (integer expected, got nil)
|rstack traceback:
[C]: in function 'string.format'
user:/AddOns/LoreBooks/LoreBooks.lua:1812: in function 'ShowMyPosition'
|caaaaaa<Locals> _ = "blackwood", zone = "u30_leyawiincity_base", x = 0.16342504322529, y = 0.57929885387421, xpos = 0.59770880491514, ypos = 0.67999160724935, zoneId = 1261, measurement = [table:1]{zoneId = 1261, offsetY = 0.67010320723057, offsetX = 0.59491920471191, scaleY = 0.017069600522518, scaleX = 0.017069600522518, id = 1940}, gpsZoneId = 1261, mapId = 1940, locX = 0.163425, locY = 0.579299, bookName = "Tribes of Blackwood: Gideon an...", bookID = "", categoryIndex = 3, collectionIndex = 42, bookIndex = 75, _ = "Tribes of Blackwood: Gideon an...", _ = "/esoui/art/icons/lore_book5_de...", _ = T </Locals>|r
/EsoUI/Ingame/SlashCommands/SlashCommands_Shared.lua:204: in function 'DoCommand'
|caaaaaa<Locals> text = "/lbpos", command = "/lbpos", arguments = "", fn = user:/AddOns/LoreBooks/LoreBooks.lua:1742 </Locals>|r
/EsoUI/Ingame/ChatSystem/SharedChatSystem.lua:1807: in function 'SharedChatSystem:SubmitTextEntry'
|caaaaaa<Locals> self = [table:2]{numUnreadMails = 0, ignoreTextEntryChangedEvent = F, minContainerHeight = 170, shouldMinimizeAfterEntry = F, maxContainerWidth = 550, currentNumNotifications = 0, currentChannel = 0, maxContainerHeight = 380, isMinimized = F, allowMultipleContainers = F, isMinimizingOrMaximizing = F, minContainerWidth = 300, isAgentChatActive = F, suppressSave = F, loaded = T}, text = "/lbpos", valid = F, prefix = 47 </Locals>|r
/EsoUI/Ingame/ChatSystem/SharedChatSystem.lua:2532: in function 'ZO_ChatTextEntry_Execute'
|caaaaaa<Locals> control = ud </Locals>|r
(tail call): ?
ZO_ChatWindowTextEntryEditBox_Enter:3: in function '(main chunk)'
|caaaaaa<Locals> self = ud </Locals>|r
(tail call): ?
(tail call): ?
]]--
  end
end

local function CreateFakePin()
  local _, zone = LMP:GetZoneAndSubzone()
  local x, y = GetMapPlayerPosition("player")
  local xpos, ypos = GPS:LocalToGlobal(x, y)
  local info = GetLorebooksMapInfo()
  local zoneId
  local mapId

  if info.z then zoneId = info.z end
  if info.md then mapId = info.md end

  local ef = '"e"'
  local mdf = '"pm"' -- mapId
  local pxf = '"px"' -- LibGPS x
  local pyf = '"py"' -- LibGPS y
  local fpf = '"fp"' -- used for zone booklist
  local shownBookId = "fake"
  local bookName = "fake book position provide the true location"
  outText = string.format("[%s] = { [%s] = { [1] = { [%s] = %.10f, [%s] = %.10f, [%s] = %d, [%s] = true, }, }, }, -- %s, %s",
    shownBookId, ef, pxf, xpos, pyf, ypos, mdf, mapId, fpf, bookName, zone)
  MyPrint(outText)
end

local function OnLoad(eventCode, name)

  if name == c.ADDON_NAME then

    EVENT_MANAGER:UnregisterForEvent(c.ADDON_NAME, EVENT_ADD_ON_LOADED)

    LoreBooks:CreateSettings()
    db = LoreBooks:GetSettings()

    -- Lorelibrary
    RebuildLoreLibrary()

    -- Tooltip Mode
    OnGamepadPreferredModeChanged()

    -- LibMapPins
    InitializePins()

    -- Data sniffer
    --LoreBooks.ToggleShareData()

    --LoreBooks.ToggleUseQuestBooks()

    --LoreBooks_InitializeCollab()

    -- slash commands
    SLASH_COMMANDS["/lbpos"] = ShowMyPosition

    SLASH_COMMANDS["/lbfake"] = CreateFakePin

    -- SLASH_COMMANDS["/lbgetn"] = GetLorebookNames

    --SLASH_COMMANDS["/lbshow"] = ShowLorebookMissingMapId

    --events
    EVENT_MANAGER:RegisterForEvent(c.ADDON_NAME, EVENT_SHOW_BOOK, OnShowBook)
    EVENT_MANAGER:RegisterForEvent(c.ADDON_NAME, EVENT_HIDE_BOOK, OnHideBook)
    EVENT_MANAGER:RegisterForEvent(c.ADDON_NAME, EVENT_LORE_BOOK_LEARNED, OnBookLearned)
    EVENT_MANAGER:RegisterForEvent(c.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)

  end

end

EVENT_MANAGER:RegisterForEvent(c.ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)