# uSkin - Character Customization

## Overview
uSkin is a comprehensive character customization resource for FiveM, part of the u* ecosystem. Fork of fivem-appearance, rewritten from React/TypeScript to vanilla JS/Lua with uGen integration. Full drop-in replacement for esx_skin.

## Architecture
- **Frontend**: Vanilla HTML/CSS/JS (no build step)
- **Client**: Lua 5.4 (no TypeScript)
- **Server**: Lua — ESX DB integration, dual-format save, backpack weight, admin command
- **Dependencies**: uGen, es_extended, oxmysql, skinchanger (kept for ESX.SpawnPlayer compat)
- **Design System**: uGen Overwatch/Marvel Rivals aesthetic (Teko, Archivo, Oxanium fonts)

## Files
| File | Purpose |
|---|---|
| `fxmanifest.lua` | Resource manifest |
| `config.lua` | Constants, format conversion functions (shared client+server) |
| `client.lua` | Core: appearance get/set, model loading, exports, ESX compat events |
| `client_camera.lua` | Camera system: orbital, instant rotation, ped turn around, clothes toggle |
| `client_nui.lua` | All NUI callbacks (20+) between JS and Lua |
| `server.lua` | DB save/load, dual format, backpack weight, /skin admin command |
| `html/index.html` | NUI shell with Google Fonts imports |
| `html/style.css` | uGen design system styling |
| `html/script.js` | All UI logic: section builders, component builders, state management |
| `peds.json` | Ped model list (loaded at runtime) |
| `tattoos.json` | Tattoo definitions by body zone (loaded at runtime) |

## DB Integration (replaces esx_skin)
- **Table**: `users.skin` column (LONGTEXT JSON)
- **Dual format**: Flat skinchanger keys (for backward compat) + `_uSkin` embedded data
- Skinchanger and ESX.SpawnPlayer read the flat keys
- uSkin reads `_uSkin` field for full appearance data
- Legacy skinchanger-only data auto-converted via `Config.flatToAppearance()`

## esx_skin Compatibility Events (all handled)
| Event | Source | Purpose |
|---|---|---|
| `esx_skin:playerRegistered` | uChar | Load saved skin or open creation |
| `esx_skin:resetFirstSpawn` | uChar | Reset state on logout/relog |
| `esx_skin:openSaveableMenu` | uChar, /skin cmd | Open customization + save to DB |
| `esx_skin:openMenu` | External | Open customization without save |
| `esx_skin:openRestrictedMenu` | esx_barbershop | Open with restricted sections |
| `esx_skin:openSaveableRestrictedMenu` | External | Restricted + save |
| `esx_skin:getLastSkin` | esx_property | Get cached last skin |
| `esx_skin:setLastSkin` | esx_property | Set cached skin |
| `esx_skin:save` (server) | Multiple | Save to DB |
| `esx_skin:setWeight` (server) | esx:playerLoaded | Backpack weight |
| `esx_skin:getPlayerSkin` (callback) | Multiple | Fetch from DB |

## Export API
```lua
-- Main entry point (callback receives appearance table or nil on cancel)
exports['uSkin']:startPlayerCustomization(callback, config)

-- Getters
exports['uSkin']:getPedModel(ped)
exports['uSkin']:getPedComponents(ped)
exports['uSkin']:getPedProps(ped)
exports['uSkin']:getPedHeadBlend(ped)
exports['uSkin']:getPedFaceFeatures(ped)
exports['uSkin']:getPedHeadOverlays(ped)
exports['uSkin']:getPedHair(ped)
exports['uSkin']:getPedTattoos()
exports['uSkin']:getPedAppearance(ped)

-- Setters
exports['uSkin']:setPlayerModel(model)
exports['uSkin']:setPedHeadBlend(ped, headBlend)
exports['uSkin']:setPedFaceFeatures(ped, faceFeatures)
exports['uSkin']:setPedHeadOverlays(ped, headOverlays)
exports['uSkin']:setPedHair(ped, hair)
exports['uSkin']:setPedEyeColor(ped, eyeColor)
exports['uSkin']:setPedComponent(ped, component)
exports['uSkin']:setPedComponents(ped, components)
exports['uSkin']:setPedProp(ped, prop)
exports['uSkin']:setPedProps(ped, props)
exports['uSkin']:setPedTattoos(ped, tattoos)
exports['uSkin']:setPlayerAppearance(appearance)
```

## Config Parameter
The `startPlayerCustomization` config table controls which sections are shown:
```lua
{
    ped = true,          -- Ped model selection
    headBlend = true,    -- Genetics (shape/skin parents + mix)
    faceFeatures = true, -- 20 face feature sliders
    headOverlays = true, -- Hair, overlays, eye color
    components = true,   -- Clothing (12 slots)
    props = true,        -- Accessories (5 slots)
    tattoos = true,      -- Tattoos by body zone
    allowExit = true,    -- Show exit button
}
```

## Key Data Structures
```lua
-- Appearance data (uSkin format)
{ model, headBlend, faceFeatures, headOverlays, components, props, hair, eyeColor, tattoos }

-- Component
{ component_id = 0..11, drawable = N, texture = N }

-- Prop
{ prop_id = 0|1|2|6|7, drawable = -1..N, texture = N }

-- Head overlay
{ style = N, opacity = 0.0..1.0, color = N }
```

## Format Conversion (config.lua)
```lua
Config.appearanceToFlat(appearance) -- uSkin -> skinchanger flat keys
Config.flatToAppearance(skin)       -- skinchanger flat keys -> uSkin (also reads _uSkin field)
```
