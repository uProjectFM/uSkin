-- ============================
-- uSkin - NUI Callbacks
-- All communication between NUI (JavaScript) and client Lua
-- ============================

-- ============================
-- Settings & Data
-- ============================
RegisterNUICallback('appearance_get_settings_and_data', function(data, cb)
    local config = GetCustomizationConfig()
    local appearanceData = GetCurrentAppearance()
    local appearanceSettings = GetAppearanceSettings()
    cb({ config = config, appearanceData = appearanceData, appearanceSettings = appearanceSettings })
end)

-- ============================
-- Camera Controls
-- ============================
RegisterNUICallback('appearance_set_camera', function(camera, cb)
    cb({})
    SetCameraPreset(camera)
end)

RegisterNUICallback('appearance_turn_around', function(_, cb)
    cb({})
    PedTurnAround()
end)

RegisterNUICallback('appearance_rotate_camera', function(direction, cb)
    cb({})
    RotateCamera(direction)
end)

-- ============================
-- Model Change
-- ============================
RegisterNUICallback('appearance_change_model', function(model, cb)
    SetPlayerModel_(model)

    local playerPed = PlayerPedId()
    local heading = GetPlayerHeading()
    if heading then
        SetEntityHeading(playerPed, heading)
    end
    SetEntityInvincible(playerPed, true)
    TaskStandStill(playerPed, -1)

    local appearanceData = GetPedAppearance(playerPed)
    local appearanceSettings = GetAppearanceSettings()

    cb({ appearanceSettings = appearanceSettings, appearanceData = appearanceData })
end)

-- ============================
-- Head Blend (Genetics)
-- ============================
RegisterNUICallback('appearance_change_head_blend', function(headBlend, cb)
    cb({})
    SetPedHeadBlend(PlayerPedId(), headBlend)
end)

-- ============================
-- Face Features
-- ============================
RegisterNUICallback('appearance_change_face_feature', function(faceFeatures, cb)
    cb({})
    SetPedFaceFeatures_(PlayerPedId(), faceFeatures)
end)

-- ============================
-- Head Overlays
-- ============================
RegisterNUICallback('appearance_change_head_overlay', function(headOverlays, cb)
    cb({})
    SetPedHeadOverlays_(PlayerPedId(), headOverlays)
end)

-- ============================
-- Hair
-- ============================
RegisterNUICallback('appearance_change_hair', function(hair, cb)
    cb({})
    SetPedHair_(PlayerPedId(), hair)
end)

-- ============================
-- Eye Color
-- ============================
RegisterNUICallback('appearance_change_eye_color', function(eyeColor, cb)
    cb({})
    SetPedEyeColor_(PlayerPedId(), eyeColor)
end)

-- ============================
-- Components (Clothing)
-- ============================
RegisterNUICallback('appearance_change_component', function(component, cb)
    local playerPed = PlayerPedId()
    SetPedComponent_(playerPed, component)
    cb(GetComponentSettings(playerPed, component.component_id))
end)

-- ============================
-- Props (Accessories)
-- ============================
RegisterNUICallback('appearance_change_prop', function(prop, cb)
    local playerPed = PlayerPedId()
    SetPedProp_(playerPed, prop)
    cb(GetPropSettings(playerPed, prop.prop_id))
end)

-- ============================
-- Tattoos
-- ============================
RegisterNUICallback('appearance_apply_tattoo', function(tattoos, cb)
    cb({})
    AddPedTattoo_(PlayerPedId(), tattoos)
end)

RegisterNUICallback('appearance_preview_tattoo', function(data, cb)
    cb({})
    PreviewPedTattoo_(PlayerPedId(), data.data, data.tattoo)
end)

RegisterNUICallback('appearance_delete_tattoo', function(tattoos, cb)
    cb({})
    AddPedTattoo_(PlayerPedId(), tattoos)
end)

-- ============================
-- Clothes Toggle
-- ============================
RegisterNUICallback('appearance_wear_clothes', function(data, cb)
    cb({})
    WearClothes(data.data, data.key)
end)

RegisterNUICallback('appearance_remove_clothes', function(clothes, cb)
    cb({})
    RemoveClothes(clothes)
end)

-- ============================
-- Save / Exit
-- ============================
RegisterNUICallback('appearance_save', function(appearance, cb)
    cb({})
    ExitPlayerCustomization(appearance)
end)

RegisterNUICallback('appearance_exit', function(_, cb)
    cb({})
    ExitPlayerCustomization(nil)
end)

-- ============================
-- uGen Confirm Modal Integration (Save/Exit)
-- ============================
local saveHandler = nil
local exitHandler = nil

RegisterNUICallback('appearance_request_save', function(appearanceData, cb)
    cb({})
    if saveHandler then
        RemoveEventHandler(saveHandler)
        saveHandler = nil
    end
    exports['uGen']:OpenConfirmModal(
        'Save Appearance',
        'Apply these changes to your character?',
        'uSkin:confirmSave'
    )
    saveHandler = AddEventHandler('uSkin:confirmSave', function(confirmed)
        if confirmed then
            ExitPlayerCustomization(appearanceData)
        end
        RemoveEventHandler(saveHandler)
        saveHandler = nil
    end)
end)

RegisterNUICallback('appearance_request_exit', function(_, cb)
    cb({})
    if exitHandler then
        RemoveEventHandler(exitHandler)
        exitHandler = nil
    end
    exports['uGen']:OpenConfirmModal(
        'Exit',
        'Discard all changes?',
        'uSkin:confirmExit'
    )
    exitHandler = AddEventHandler('uSkin:confirmExit', function(confirmed)
        if confirmed then
            ExitPlayerCustomization(nil)
        end
        RemoveEventHandler(exitHandler)
        exitHandler = nil
    end)
end)
