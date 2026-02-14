# uSkin - Character Customization

## Overview
uSkin is a comprehensive character customization resource for FiveM, part of the u* ecosystem. Fork of fivem-appearance, rewritten from React/TypeScript to vanilla JS/Lua with uGen integration.

## Architecture
- **Frontend**: Vanilla HTML/CSS/JS (no build step)
- **Client**: Lua 5.4 (no TypeScript)
- **Dependencies**: uGen (hard dependency - notifications, confirm modals, debug mode)
- **Design System**: uGen Overwatch/Marvel Rivals aesthetic (Teko, Archivo, Oxanium fonts)

## Files
| File | Purpose |
|---|---|
| `fxmanifest.lua` | Resource manifest |
| `config.lua` | Constants: face features, overlays, eye colors, hair decorations, clothes data |
| `client.lua` | Core: appearance get/set, model loading, settings calculation, exports |
| `client_camera.lua` | Camera system: presets, interpolation, rotation, ped turn around, clothes toggle |
| `client_nui.lua` | All NUI callbacks (20+) between JS and Lua |
| `html/index.html` | NUI shell with Google Fonts imports |
| `html/style.css` | uGen design system styling |
| `html/script.js` | All UI logic: section builders, component builders, state management |
| `peds.json` | Ped model list (loaded at runtime) |
| `tattoos.json` | Tattoo definitions by body zone (loaded at runtime) |

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

## NUI Communication Pattern
- Lua -> JS: `SendNUIMessage({ type = 'appearance_display' })`
- JS -> Lua: `fetch('https://uSkin/callback_name', { body: JSON.stringify(data) })`
- JS receives response via `RegisterNUICallback` cb parameter

## uGen Integration
- Save confirmation: `exports['uGen']:OpenConfirmModal(...)`
- Exit confirmation: `exports['uGen']:OpenConfirmModal(...)`
- Debug prints: `pcall(exports['uGen']:GetDebugMode)`

## Feature Sections (JS)
Freemode peds only: Genetics, Face Features, Hair, Head Overlays, Eye Color, Tattoos
All peds: Ped Model, Clothing, Props

## Key Data Structures
```lua
-- Appearance data
{ model, headBlend, faceFeatures, headOverlays, components, props, hair, eyeColor, tattoos }

-- Component
{ component_id = 0..11, drawable = N, texture = N }

-- Prop
{ prop_id = 0|1|2|6|7, drawable = -1..N, texture = N }

-- Head overlay
{ style = N, opacity = 0.0..1.0, color = N }
```
