-- ============================
-- uSkin - Client Core
-- Appearance get/set functions, model loading, exports, ESX integration
-- ============================

local ESX = exports['es_extended']:getSharedObject()
local playerLoaded = false

-- ============================
-- Data loaded from JSON files
-- ============================
local pedModels = json.decode(LoadResourceFile(GetCurrentResourceName(), 'peds.json')) or {}
local totalTattoos = json.decode(LoadResourceFile(GetCurrentResourceName(), 'tattoos.json')) or {}

local pedModelsByHash = {}
for _, model in ipairs(pedModels) do
    pedModelsByHash[GetHashKey(model)] = model
end

-- ============================
-- Shared State
-- ============================
local playerAppearance = nil
local pedTattoos = {}
local customizationCallback = nil
local customizationConfig = nil

-- ============================
-- Utility Functions
-- ============================
local function isPedMale(ped)
    return GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
end

local function isPedFreemodeModel(ped)
    local model = GetEntityModel(ped)
    return model == GetHashKey('mp_m_freemode_01') or model == GetHashKey('mp_f_freemode_01')
end

local function roundToDecimal(value, decimals)
    local mult = 10 ^ (decimals or 1)
    return math.floor(value * mult + 0.5) / mult
end

-- ============================
-- Appearance Getters
-- ============================
local function getPedModel(ped)
    return pedModelsByHash[GetEntityModel(ped)] or 'mp_m_freemode_01'
end

local function getPedComponents(ped)
    local components = {}
    for _, componentId in ipairs(Config.pedComponentIds) do
        components[#components + 1] = {
            component_id = componentId,
            drawable = GetPedDrawableVariation(ped, componentId),
            texture = GetPedTextureVariation(ped, componentId),
        }
    end
    return components
end

local function getPedProps(ped)
    local props = {}
    for _, propId in ipairs(Config.pedPropIds) do
        props[#props + 1] = {
            prop_id = propId,
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId),
        }
    end
    return props
end

local function getPedHeadBlend(ped)
    local ok, shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix, isParent = GetPedHeadBlendData(ped)
    return {
        shapeFirst = shapeFirst or 0,
        shapeSecond = shapeSecond or 0,
        skinFirst = skinFirst or 0,
        skinSecond = skinSecond or 0,
        shapeMix = roundToDecimal(shapeMix or 0.0, 1),
        skinMix = roundToDecimal(skinMix or 0.0, 1),
    }
end

local function getPedFaceFeatures(ped)
    local faceFeatures = {}
    for i, key in ipairs(Config.faceFeatures) do
        faceFeatures[key] = roundToDecimal(GetPedFaceFeature(ped, i - 1), 1)
    end
    return faceFeatures
end

local function getPedHeadOverlays(ped)
    local headOverlays = {}
    for i, key in ipairs(Config.headOverlays) do
        local index = i - 1
        local retval, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, index)
        local hasOverlay = overlayValue ~= 255
        headOverlays[key] = {
            style = hasOverlay and overlayValue or 0,
            opacity = hasOverlay and roundToDecimal(overlayOpacity, 1) or 0.0,
            color = firstColour or 0,
        }
    end
    return headOverlays
end

local function getPedHair(ped)
    return {
        style = GetPedDrawableVariation(ped, 2),
        color = GetPedHairColor(ped),
        highlight = GetPedHairHighlightColor(ped),
    }
end

local function getPedTattoosData()
    return pedTattoos
end

function GetPedAppearance(ped)
    local eyeColor = GetPedEyeColor(ped)
    return {
        model = getPedModel(ped),
        headBlend = getPedHeadBlend(ped),
        faceFeatures = getPedFaceFeatures(ped),
        headOverlays = getPedHeadOverlays(ped),
        components = getPedComponents(ped),
        props = getPedProps(ped),
        hair = getPedHair(ped),
        eyeColor = (eyeColor < #Config.eyeColors) and eyeColor or 0,
        tattoos = getPedTattoosData(),
    }
end

-- ============================
-- Appearance Setters
-- ============================
function SetPlayerModel_(model)
    if not model then return end
    if not IsModelInCdimage(model) then return end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    local health = GetEntityHealth(PlayerPedId())
    local armour = GetPedArmour(PlayerPedId())

    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    local playerPed = PlayerPedId()
    if isPedFreemodeModel(playerPed) then
        SetPedDefaultComponentVariation(playerPed)
        SetPedHeadBlendData(playerPed, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, false)
    end

    SetEntityHealth(playerPed, health)
    SetPedArmour(playerPed, armour)
end

function SetPedHeadBlend(ped, headBlend)
    if not headBlend then return end
    if not isPedFreemodeModel(ped) then return end

    SetPedHeadBlendData(
        ped,
        headBlend.shapeFirst, headBlend.shapeSecond, 0,
        headBlend.skinFirst, headBlend.skinSecond, 0,
        headBlend.shapeMix, headBlend.skinMix, 0.0,
        false
    )
end

function SetPedFaceFeatures_(ped, faceFeatures)
    if not faceFeatures then return end
    for i, key in ipairs(Config.faceFeatures) do
        SetPedFaceFeature(ped, i - 1, faceFeatures[key] or 0.0)
    end
end

function SetPedHeadOverlays_(ped, headOverlays)
    if not headOverlays then return end

    local makeupColorOverlays = { makeUp = true, blush = true, lipstick = true }

    for i, key in ipairs(Config.headOverlays) do
        local index = i - 1
        local overlay = headOverlays[key]
        if overlay then
            SetPedHeadOverlay(ped, index, overlay.style, overlay.opacity)
            if overlay.color or overlay.color == 0 then
                local colorType = makeupColorOverlays[key] and 2 or 1
                SetPedHeadOverlayColor(ped, index, colorType, overlay.color, overlay.secondColor or 0)
            end
        end
    end
end

function SetPedHair_(ped, hair)
    if not hair then return end

    SetPedComponentVariation(ped, 2, hair.style, 0, 0)
    SetPedHairColor(ped, hair.color, hair.highlight)

    if Config.automaticFade then
        local decorationType = isPedMale(ped) and 'male' or 'female'
        local decorations = Config.hairDecorations[decorationType]
        if decorations then
            ClearPedDecorations(ped)
            for _, deco in ipairs(decorations) do
                if deco.id == hair.style then
                    AddPedDecorationFromHashes(ped, GetHashKey(deco.collection), GetHashKey(deco.overlay))
                    break
                end
            end
        end
    end
end

function SetPedEyeColor_(ped, eyeColor)
    if not eyeColor then return end
    SetPedEyeColor(ped, eyeColor)
end

function SetPedComponent_(ped, component)
    if not component then return end

    local excludedFromFreemode = { [0] = true, [2] = true }
    if excludedFromFreemode[component.component_id] and isPedFreemodeModel(ped) then
        return
    end

    SetPedComponentVariation(ped, component.component_id, component.drawable, component.texture, 0)
end

function SetPedComponents_(ped, components)
    if not components then return end
    for _, component in ipairs(components) do
        SetPedComponent_(ped, component)
    end
end

function SetPedProp_(ped, prop)
    if not prop then return end
    if prop.drawable == -1 then
        ClearPedProp(ped, prop.prop_id)
    else
        SetPedPropIndex(ped, prop.prop_id, prop.drawable, prop.texture, false)
    end
end

function SetPedProps_(ped, props)
    if not props then return end
    for _, prop in ipairs(props) do
        SetPedProp_(ped, prop)
    end
end

function SetPedTattoos_(ped, tattoos)
    pedTattoos = tattoos or {}
    local isMale = isPedMale(ped)
    ClearPedDecorations(ped)
    for zone, tattooList in pairs(pedTattoos) do
        for _, tattoo in ipairs(tattooList) do
            local hash = isMale and tattoo.hashMale or tattoo.hashFemale
            AddPedDecorationFromHashes(ped, GetHashKey(tattoo.collection), GetHashKey(hash))
        end
    end
end

function AddPedTattoo_(ped, tattoos)
    local isMale = isPedMale(ped)
    ClearPedDecorations(ped)
    for zone, tattooList in pairs(tattoos) do
        for _, tattoo in ipairs(tattooList) do
            local hash = isMale and tattoo.hashMale or tattoo.hashFemale
            AddPedDecorationFromHashes(ped, GetHashKey(tattoo.collection), GetHashKey(hash))
        end
    end
end

function PreviewPedTattoo_(ped, currentTattoos, tattoo)
    local isMale = isPedMale(ped)
    ClearPedDecorations(ped)
    -- Apply the preview tattoo first
    local previewHash = isMale and tattoo.hashMale or tattoo.hashFemale
    AddPedDecorationFromHashes(ped, GetHashKey(tattoo.collection), GetHashKey(previewHash))
    -- Then apply existing tattoos (except duplicates)
    for zone, tattooList in pairs(currentTattoos) do
        for _, t in ipairs(tattooList) do
            if t.name ~= tattoo.name then
                local hash = isMale and t.hashMale or t.hashFemale
                AddPedDecorationFromHashes(ped, GetHashKey(t.collection), GetHashKey(hash))
            end
        end
    end
end

function SetPlayerAppearance(appearance)
    if not appearance then return end

    SetPlayerModel_(appearance.model)

    local playerPed = PlayerPedId()

    SetPedComponents_(playerPed, appearance.components)
    SetPedProps_(playerPed, appearance.props)

    if appearance.headBlend then
        SetPedHeadBlend(playerPed, appearance.headBlend)
    end
    if appearance.faceFeatures then
        SetPedFaceFeatures_(playerPed, appearance.faceFeatures)
    end
    if appearance.headOverlays then
        SetPedHeadOverlays_(playerPed, appearance.headOverlays)
    end
    if appearance.hair then
        SetPedHair_(playerPed, appearance.hair)
    end
    if appearance.eyeColor then
        SetPedEyeColor_(playerPed, appearance.eyeColor)
    end
    if appearance.tattoos then
        SetPedTattoos_(playerPed, appearance.tattoos)
    end
end

-- ============================
-- Appearance Settings (min/max ranges for NUI controls)
-- ============================
function GetComponentSettings(ped, componentId)
    local drawableId = GetPedDrawableVariation(ped, componentId)
    return {
        component_id = componentId,
        drawable = { min = 0, max = GetNumberOfPedDrawableVariations(ped, componentId) - 1 },
        texture = { min = 0, max = GetNumberOfPedTextureVariations(ped, componentId, drawableId) - 1 },
    }
end

function GetPropSettings(ped, propId)
    local drawableId = GetPedPropIndex(ped, propId)
    return {
        prop_id = propId,
        drawable = { min = -1, max = GetNumberOfPedPropDrawableVariations(ped, propId) - 1 },
        texture = { min = -1, max = GetNumberOfPedPropTextureVariations(ped, propId, drawableId) - 1 },
    }
end

function GetRgbColors()
    local colors = { hair = {}, makeUp = {} }
    for i = 0, GetNumHairColors() - 1 do
        local r, g, b = GetPedHairRgbColor(i)
        colors.hair[#colors.hair + 1] = { r, g, b }
    end
    for i = 0, GetNumMakeupColors() - 1 do
        local r, g, b = GetMakeupRgbColor(i)
        colors.makeUp[#colors.makeUp + 1] = { r, g, b }
    end
    return colors
end

function GetAppearanceSettings()
    local playerPed = PlayerPedId()
    local colors = GetRgbColors()

    local hasPedPriv = ESX.PlayerData and ESX.PlayerData.perms and ESX.PlayerData.perms.pedpriv
    local pedItems
    if hasPedPriv then
        pedItems = pedModels
    else
        pedItems = {
            { label = 'Body Type 0', value = 'mp_m_freemode_01' },
            { label = 'Body Type 1', value = 'mp_f_freemode_01' },
        }
    end
    local ped = { model = { items = pedItems } }
    local tattoos = { items = totalTattoos }

    local components = {}
    for _, componentId in ipairs(Config.pedComponentIds) do
        components[#components + 1] = GetComponentSettings(playerPed, componentId)
    end

    local props = {}
    for _, propId in ipairs(Config.pedPropIds) do
        props[#props + 1] = GetPropSettings(playerPed, propId)
    end

    local headBlend = {
        shapeFirst  = { min = 0, max = 45 },
        shapeSecond = { min = 0, max = 45 },
        skinFirst   = { min = 0, max = 45 },
        skinSecond  = { min = 0, max = 45 },
        shapeMix    = { min = 0, max = 1, factor = 0.1 },
        skinMix     = { min = 0, max = 1, factor = 0.1 },
    }

    local faceFeatures = {}
    for _, key in ipairs(Config.faceFeatures) do
        faceFeatures[key] = { min = -1, max = 1, factor = 0.1 }
    end

    local colorMap = {
        beard = colors.hair,
        eyebrows = colors.hair,
        chestHair = colors.hair,
        makeUp = colors.makeUp,
        blush = colors.makeUp,
        lipstick = colors.makeUp,
    }

    local headOverlays = {}
    for i, key in ipairs(Config.headOverlays) do
        local settings = {
            style = { min = 0, max = GetPedHeadOverlayNum(i - 1) - 1 },
            opacity = { min = 0, max = 1, factor = 0.1 },
        }
        if colorMap[key] then
            settings.color = { items = colorMap[key] }
        end
        headOverlays[key] = settings
    end

    local hair = {
        style = { min = 0, max = GetNumberOfPedDrawableVariations(playerPed, 2) - 1 },
        color = { items = colors.hair },
        highlight = { items = colors.hair },
    }

    local eyeColor = { min = 0, max = 30 }

    return {
        ped = ped,
        components = components,
        props = props,
        headBlend = headBlend,
        faceFeatures = faceFeatures,
        headOverlays = headOverlays,
        hair = hair,
        eyeColor = eyeColor,
        tattoos = tattoos,
    }
end

-- ============================
-- Customization Session Management
-- ============================
function GetCurrentAppearance()
    if not playerAppearance then
        playerAppearance = GetPedAppearance(PlayerPedId())
    end
    return playerAppearance
end

function GetCustomizationConfig()
    return customizationConfig
end

function StartPlayerCustomization(cb, config)
    config = config or Config.defaultCustomization
    config.automaticFade = Config.automaticFade

    local playerPed = PlayerPedId()
    playerAppearance = GetPedAppearance(playerPed)
    customizationCallback = cb
    customizationConfig = config

    -- Run in a thread so Citizen.Wait works (export caller may not be threaded)
    Citizen.CreateThread(function()
        -- Freeze ped and make invincible before camera setup
        SetEntityInvincible(playerPed, true)
        FreezeEntityPosition(playerPed, true)
        TaskStandStill(playerPed, -1)

        -- Let the ped position stabilize for one frame
        Citizen.Wait(150)

        -- Create and activate camera (RenderScriptCams is called inside SetCameraPreset on first creation)
        StartCamera()

        DisplayRadar(false)
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)

        pcall(function() exports['uGen']:HideHud() end)
        pcall(function() exports['uTimer']:StopTimer() end)
        TriggerEvent('uTalk:hideUI')

        SendNUIMessage({ type = 'appearance_display' })

        Config.debugPrint('Customization started')
    end)
end

function ExitPlayerCustomization(appearance)
    RenderScriptCams(false, false, 0, true, true)
    DestroyCamera()
    DisplayRadar(true)
    SetNuiFocus(false, false)

    pcall(function() exports['uGen']:ShowHud() end)
    TriggerEvent('uTalk:showUI')

    local playerPed = PlayerPedId()
    ClearPedTasksImmediately(playerPed)
    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)

    SendNUIMessage({ type = 'appearance_hide' })

    if not appearance then
        -- Cancelled: revert to original appearance
        SetPlayerAppearance(GetCurrentAppearance())
    else
        -- Saved: apply tattoos and persist to DB
        if appearance.tattoos then
            SetPedTattoos_(playerPed, appearance.tattoos)
        end
        TriggerServerEvent('esx_skin:save', appearance)
        Config.debugPrint('Appearance saved to DB')
    end

    if customizationCallback then
        customizationCallback(appearance)
    end

    customizationCallback = nil
    customizationConfig = nil
    playerAppearance = nil

    Config.debugPrint('Customization ended')
end

-- ============================
-- ESX Integration: load skin on spawn, save to DB on exit
-- ============================
local lastSkin = nil

RegisterNetEvent('esx:playerLoaded', function(_, _, skin)
    playerLoaded = true
    if skin then
        TriggerServerEvent('esx_skin:setWeight', skin)
    end
end)

-- Triggered by uChar after character selection
AddEventHandler('esx_skin:playerRegistered', function()
    Citizen.CreateThread(function()
        while not playerLoaded do
            Citizen.Wait(100)
        end

        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            if not skin then
                -- No saved skin: open full customization for new character
                StartPlayerCustomization(function(appearance)
                    if appearance then
                        TriggerServerEvent('esx_skin:save', appearance)
                        Config.debugPrint('First-time appearance saved to DB')
                    end
                end, Config.defaultCustomization)
                return
            end

            -- Extract uSkin data from dual format, or convert legacy
            local appearance = Config.flatToAppearance(skin)
            if appearance then
                SetPlayerAppearance(appearance)
                lastSkin = appearance
                Config.debugPrint('Loaded saved appearance from DB')
            end
        end)
    end)
end)

-- Reset first spawn flag (used by uChar on logout/relog)
AddEventHandler('esx_skin:resetFirstSpawn', function()
    playerLoaded = false
    lastSkin = nil
end)

-- ============================
-- esx_skin Compatibility Events (menu open/close)
-- ============================

-- Open saveable menu (used by uChar character creation, /skin command)
RegisterNetEvent('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
    StartPlayerCustomization(function(appearance)
        if appearance then
            -- Sync skinchanger state so exports["skinchanger"]:GetSkin() is correct
            local flat = Config.appearanceToFlat(appearance)
            pcall(function() exports['skinchanger']:LoadSkin(flat) end)
            lastSkin = appearance

            if submitCb then submitCb() end
        else
            if cancelCb then cancelCb() end
        end
    end, Config.defaultCustomization)
end)

-- Open menu without saving (generic)
RegisterNetEvent('esx_skin:openMenu', function(submitCb, cancelCb)
    local config = {}
    for k, v in pairs(Config.defaultCustomization) do config[k] = v end
    config.allowExit = true

    StartPlayerCustomization(function(appearance)
        if appearance then
            lastSkin = appearance
            if submitCb then submitCb() end
        else
            if cancelCb then cancelCb() end
        end
    end, config)
end)

-- Open restricted menu (used by esx_barbershop - hair/beard/makeup only)
RegisterNetEvent('esx_skin:openRestrictedMenu', function(submitCb, cancelCb, restrict)
    local config = {
        ped = false, headBlend = false, faceFeatures = false,
        headOverlays = true, components = false, props = false,
        tattoos = false, allowExit = true,
    }

    StartPlayerCustomization(function(appearance)
        if appearance then
            lastSkin = appearance
            if submitCb then submitCb() end
        else
            if cancelCb then cancelCb() end
        end
    end, config)
end)

-- Open restricted + saveable menu
RegisterNetEvent('esx_skin:openSaveableRestrictedMenu', function(submitCb, cancelCb, restrict)
    local config = {
        ped = false, headBlend = false, faceFeatures = false,
        headOverlays = true, components = false, props = false,
        tattoos = false, allowExit = true,
    }

    StartPlayerCustomization(function(appearance)
        if appearance then
            local flat = Config.appearanceToFlat(appearance)
            pcall(function() exports['skinchanger']:LoadSkin(flat) end)
            lastSkin = appearance
            if submitCb then submitCb() end
        else
            if cancelCb then cancelCb() end
        end
    end, config)
end)

-- Last skin cache (used by esx_property)
AddEventHandler('esx_skin:getLastSkin', function(cb)
    if cb then cb(lastSkin) end
end)

AddEventHandler('esx_skin:setLastSkin', function(skin)
    if skin then
        lastSkin = Config.flatToAppearance(skin) or skin
    end
end)

-- ============================
-- Resource Cleanup
-- ============================
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    RenderScriptCams(false, false, 0, true, true)
    DestroyCamera()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)
    ClearPedTasksImmediately(playerPed)
end)

-- ============================
-- Exports
-- ============================
exports('startPlayerCustomization', StartPlayerCustomization)
exports('getPedModel', getPedModel)
exports('getPedComponents', getPedComponents)
exports('getPedProps', getPedProps)
exports('getPedHeadBlend', getPedHeadBlend)
exports('getPedFaceFeatures', getPedFaceFeatures)
exports('getPedHeadOverlays', getPedHeadOverlays)
exports('getPedHair', getPedHair)
exports('getPedTattoos', getPedTattoosData)
exports('getPedAppearance', GetPedAppearance)

exports('setPlayerModel', SetPlayerModel_)
exports('setPedHeadBlend', SetPedHeadBlend)
exports('setPedFaceFeatures', SetPedFaceFeatures_)
exports('setPedHeadOverlays', SetPedHeadOverlays_)
exports('setPedHair', SetPedHair_)
exports('setPedEyeColor', SetPedEyeColor_)
exports('setPedComponent', SetPedComponent_)
exports('setPedComponents', SetPedComponents_)
exports('setPedProp', SetPedProp_)
exports('setPedProps', SetPedProps_)
exports('setPedTattoos', SetPedTattoos_)
exports('setPlayerAppearance', SetPlayerAppearance)
