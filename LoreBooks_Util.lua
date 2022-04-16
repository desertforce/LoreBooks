function Lorebooks_ShowLorebookMissingMapId()
  local categoryIndex
  local collectionIndex
  local bookIndex
  local bookTitle
  local name
  local bookId
  local mapId
  local mapIndex
  local zoneId
  local LoreBooks_bookData = ZO_DeepTableCopy(LoreBooks.bookData)
  for id, book in pairs(LoreBooks_bookData) do
    local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(id)
    if categoryIndex == 3 and collectionIndex and bookIndex then
      bookTitle, _, _, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
      name, _, _, _, _, _, _ = GetLoreCollectionInfo(categoryIndex, collectionIndex)
      if book then
        if NonContiguousCount(book.e) > 0 then
          for _, data in pairs(LoreBooks_bookData[bookId].e) do
            if not data.md then
              --d(bookId)
              --d(data)
            end
          end -- end for
        end -- end if
      end
    end

  end
end

function LoreBooks_ConvertMapInfoToMapId(booksData, bookId)
  local mapIndex = nil
  local zoneId = nil
  local mapId = nil
  if not booksData.md then
    local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
    local bookTitle, _, _, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)

    if booksData and booksData.mn and booksData.z then
      mapIndex = booksData.mn
      mapId = GetMapIdByIndex(mapIndex)
    elseif booksData and not booksData.mn and booksData.z then
      zoneId = booksData.z
      mapId = GetMapIdByZoneId(zoneId)
    end
  else
    mapId = booksData.md
  end

  booksData.md = mapId
  if not booksData.md then
    --d(bookTitle)
    d("D -----")
    d(bookId)
    d(booksData)
    return booksData
  end
  booksData.mn = nil
  return booksData
end

function LoreBooks_NormalizeToMapId(booksData)
  local mapIndex = nil
  local zoneId = nil
  local mapId = nil

  if booksData and booksData.mn and booksData.z then
    mapIndex = booksData.mn
    mapId = GetMapIdByIndex(mapIndex)
  elseif booksData and not booksData.mn and booksData.z then
    zoneId = booksData.z
    mapId = GetMapIdByZoneId(zoneId)
  end
  if booksData and booksData.md then
    mapId = booksData.md
  end
  booksData.md = mapId
  return mapId
end
