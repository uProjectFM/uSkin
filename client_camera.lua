-- ============================
-- uSkin - Camera System
-- Camera presets, interpolation, rotation, ped turn around, clothes toggle
-- Pattern based on esx_skin: CreateCam + SetCamCoord + PointCamAtCoord
-- ============================

local CAMERAS = {
    default = {
        coords = { x = 0.0, y = 2.2, z = 0.2 },
        point  = { x = 0.0, y = 0.0, z = -0.05 },
    },
    head = {
        coords = { x = 0.0, y = 0.9, z = 0.65 },
        point  = { x = 0.0, y = 0.0, z = 0.6 },
    },
    body = {
        coords = { x = 0.0, y = 1.2, z = 0.2 },
        point  = { x = 0.0, y = 0.0, z = 0.2 },
    },
    bottom = {
        coords = { x = 0.0, y = 0.98, z = -0.7 },
        point  = { x = 0.0, y = 0.0, z = -0.9 },
    },
}

local OFFSETS = {
    default = { x = 1.5, y = -1.0 },
    head    = { x = 0.7, y = -0.45 },
    body    = { x = 1.2, y = -0.45 },
    bottom  = { x = 0.7, y = -0.45 },
}

local cameraHandle = nil
local currentCamera = 'default'
local reverseCamera = false
local isCameraInterpolating = false
local playerCoords = nil
local playerHeading = nil

-- ============================
-- Helper: calculate world coords for a camera preset
-- ============================
local function getCamWorldCoords(playerPed, preset, reverseFactor, sideOffset)
    local cam = CAMERAS[preset]
    if not cam then return nil end

    local rf = reverseFactor or 1
    local ox = cam.coords.x * rf
    local oy = cam.coords.y * rf
    local oz = cam.coords.z

    if sideOffset then
        local offset = OFFSETS[preset]
        if offset then
            ox = (cam.coords.x + offset.x) * sideOffset * rf
            oy = (cam.coords.y + offset.y) * rf
        end
    end

    local camPos = GetOffsetFromEntityInWorldCoords(playerPed, ox, oy, oz)
    local pointPos = GetOffsetFromEntityInWorldCoords(playerPed, cam.point.x, cam.point.y, cam.point.z)

    Config.debugPrint(string.format(
        'Camera [%s]: offset(%.2f, %.2f, %.2f) -> world(%.2f, %.2f, %.2f) point(%.2f, %.2f, %.2f)',
        preset, ox, oy, oz, camPos.x, camPos.y, camPos.z, pointPos.x, pointPos.y, pointPos.z
    ))

    return camPos.x, camPos.y, camPos.z, pointPos.x, pointPos.y, pointPos.z
end

-- ============================
-- Helper: create a new cam at given world coords
-- Uses CreateCam + SetCamCoord (esx_skin pattern)
-- ============================
local function createCamAtCoords(cx, cy, cz, px, py, pz)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, cx, cy, cz)
    PointCamAtCoord(cam, px, py, pz)
    SetCamFov(cam, 50.0)
    return cam
end

-- ============================
-- Camera Functions
-- ============================
function StartCamera()
    local playerPed = PlayerPedId()
    playerCoords = GetEntityCoords(playerPed, true)
    playerHeading = GetEntityHeading(playerPed)
    reverseCamera = false
    isCameraInterpolating = false
    currentCamera = 'default'

    Config.debugPrint(string.format(
        'StartCamera: ped=%d coords=(%.2f, %.2f, %.2f) heading=%.2f',
        playerPed, playerCoords.x, playerCoords.y, playerCoords.z, playerHeading
    ))

    local cx, cy, cz, px, py, pz = getCamWorldCoords(playerPed, 'default', 1)
    if not cx then return end

    cameraHandle = createCamAtCoords(cx, cy, cz, px, py, pz)
    SetCamActive(cameraHandle, true)
    RenderScriptCams(true, false, 0, true, true)

    Config.debugPrint('StartCamera: cam=' .. tostring(cameraHandle) .. ' active=' .. tostring(IsCamActive(cameraHandle)))
end

function DestroyCamera()
    if cameraHandle then
        SetCamActive(cameraHandle, false)
        DestroyCam(cameraHandle, true)
        cameraHandle = nil
    end
    currentCamera = 'default'
    reverseCamera = false
    isCameraInterpolating = false
    playerCoords = nil
    playerHeading = nil
end

function SetCameraPreset(key)
    if isCameraInterpolating then return end
    if not cameraHandle then return end

    if key ~= 'current' then
        currentCamera = key
    end

    local playerPed = PlayerPedId()
    local rf = reverseCamera and -1 or 1
    local cx, cy, cz, px, py, pz = getCamWorldCoords(playerPed, currentCamera, rf)
    if not cx then return end

    -- Interpolate from current camera to new position
    local tmpCam = createCamAtCoords(cx, cy, cz, px, py, pz)
    SetCamActiveWithInterp(tmpCam, cameraHandle, 1000, 1, 1)

    isCameraInterpolating = true
    local oldCam = cameraHandle
    cameraHandle = tmpCam

    Citizen.CreateThread(function()
        while IsCamInterpolating(oldCam) or not IsCamActive(tmpCam) do
            Citizen.Wait(100)
        end
        DestroyCam(oldCam, false)
        isCameraInterpolating = false
    end)
end

function RotateCamera(direction)
    if isCameraInterpolating then return end
    if not cameraHandle then return end

    local playerPed = PlayerPedId()
    local rf = reverseCamera and -1 or 1
    local sideFactor = (direction == 'left') and 1 or -1

    local cx, cy, cz, px, py, pz = getCamWorldCoords(playerPed, currentCamera, rf, sideFactor)
    if not cx then return end

    local tmpCam = createCamAtCoords(cx, cy, cz, px, py, pz)
    SetCamActiveWithInterp(tmpCam, cameraHandle, 1000, 1, 1)

    isCameraInterpolating = true
    local oldCam = cameraHandle
    cameraHandle = tmpCam

    Citizen.CreateThread(function()
        while IsCamInterpolating(oldCam) or not IsCamActive(tmpCam) do
            Citizen.Wait(100)
        end
        DestroyCam(oldCam, false)
        isCameraInterpolating = false
    end)
end

function PedTurnAround()
    reverseCamera = not reverseCamera

    local playerPed = PlayerPedId()
    if not playerCoords then return end

    local seqId = OpenSequenceTask(0)
    if seqId then
        TaskGoStraightToCoord(
            0,
            playerCoords.x or playerCoords[1],
            playerCoords.y or playerCoords[2],
            playerCoords.z or playerCoords[3],
            8.0, -1,
            GetEntityHeading(playerPed) - 180.0,
            0.1
        )
        TaskStandStill(0, -1)
        CloseSequenceTask(seqId)

        ClearPedTasks(playerPed)
        TaskPerformSequence(playerPed, seqId)
        ClearSequenceTask(seqId)
    end

    -- Reposition camera for the reversed view
    SetCameraPreset('current')
end

-- ============================
-- Clothes Toggle
-- ============================
function WearClothes(appearanceData, typeClothes)
    local clothesConfig = Config.clothesData[typeClothes]
    if not clothesConfig then return end

    local anim = clothesConfig.animations.on
    local playerPed = PlayerPedId()
    local isMale = GetEntityModel(playerPed) == GetHashKey('mp_m_freemode_01')
    local propsList = isMale and clothesConfig.props.male or clothesConfig.props.female

    RequestAnimDict(anim.dict)
    while not HasAnimDictLoaded(anim.dict) do
        Citizen.Wait(0)
    end

    -- Restore the clothing components from appearance data
    for _, propPair in ipairs(propsList) do
        local componentId = propPair[1]
        for _, comp in ipairs(appearanceData.components) do
            if comp.component_id == componentId then
                SetPedComponentVariation(playerPed, componentId, comp.drawable, comp.texture, 2)
                break
            end
        end
    end

    TaskPlayAnim(playerPed, anim.dict, anim.anim, 3.0, 3.0, anim.duration, anim.move, 0, false, false, false)
end

function RemoveClothes(typeClothes)
    local clothesConfig = Config.clothesData[typeClothes]
    if not clothesConfig then return end

    local anim = clothesConfig.animations.off
    local playerPed = PlayerPedId()
    local isMale = GetEntityModel(playerPed) == GetHashKey('mp_m_freemode_01')
    local propsList = isMale and clothesConfig.props.male or clothesConfig.props.female

    RequestAnimDict(anim.dict)
    while not HasAnimDictLoaded(anim.dict) do
        Citizen.Wait(0)
    end

    for _, propPair in ipairs(propsList) do
        local componentId = propPair[1]
        local drawableId = propPair[2]
        SetPedComponentVariation(playerPed, componentId, drawableId, 0, 2)
    end

    TaskPlayAnim(playerPed, anim.dict, anim.anim, 3.0, 3.0, anim.duration, anim.move, 0, false, false, false)
end

function GetPlayerHeading()
    return playerHeading
end
