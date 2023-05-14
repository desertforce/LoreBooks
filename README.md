# Lorebooks

By: Kyoma, Ayantir, Garkin, Sharlikran

# Description

Displays map pins for Shalidor's Library books and Eidetic Memory Scrolls

# Shalidor Data Syntax

format: (table) `{` Normalized Coordinates X`,` Normalized Coordinates Y`,` collectionIndex`,` bookIndex`,`Map ID`,`Location Details `}`

- Map ID:
  - Map Id used to get the Map Name
- Location Details: (table)
  - nil or false = default
  - 1 = on town map
  - 2 = Delve (SI CONST)
  - 3 = Public Dungeon (SI CONST)
  - 4 = under ground
  - 5 = Group Instance (SI CONST)
  - 6 = Inside Inn
  - 7 = Guest Room
  - 8 = Attic Room
  - 9 = Hidden Basement
  - 10 = Bookshelf
  - 9999 = Breadcrumb so don't add to right click menu
  - ld = { X } where X is the arbitrary key for the location details
  - `["ld"] = { 6, 7 }`, "Inside Inn" and "Guest Room" would be added to the Tooltip for the details

NOTE: (SI CONST): Means it is an ingame localization and doesn't have to be translated

## Example of fake Shalidor Library pin

- `{ 0.5086468458, 0.8415690064, 1, 5, ["ld"] = { 9999, } } -- Guide to the Daggerfall Covenant, systres/u34_systreszone_base_0`

# Eidetic Memory Data Syntax

- `["c"] = true`: Collection information exists for this book
- `["cn"]`: Catagory Name of the Lorebook
- `["n"]`: Lorebook Name
- `["q"]`: Quest ID of the Lorebook
- `["e"]`: Eidetic Memory Locations for the book
  - `["pm"]`: Map ID of the books Primary Location
  - `["zm"]` Zone's Map ID of the Lorebook
  - `["sm"]`: Map ID of the source map the Coordinates were taken from
  - `["px"], ["py"]`: LibGPS Global Coordinates for the Primary Location
  - `["zx"], ["zy"]`: LibGPS Global Coordinates for the Zone's Map ID
  - `["pnx"], ["pny"]`: Normalized Coordinates for the Primary Location
  - `["znx"], ["zny"]`: Normalized Coordinates for the Zone's Map ID
  - `["d"]= true`: Dungeon Pin. Usually anything in a zone that you enter Delve, Mine, Cave, etc.
  - `["fp"] = true`: Indicates this is a fake pin. It will be used as a Map Pin but but not for Loocations from the Lore Library menu.
  - `["ld"]`: Location Details for the Lorebook
  - `["qp"] = true`: Player must have the Quest in their Quest Journal to view the location of the book
  - `["qc"] = true`: Player must have Completed the Quest to view the location of the book
- `["r"]= true`: Random book appears in a Bookshelf
- `["m"]`: Map ID locations where the book can be found
  - `[MapIdNumber] = count`: Map ID and count or times reported
