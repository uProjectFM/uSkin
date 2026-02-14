-- ============================
-- uSkin - Camera System
-- Orbital camera: single cam handle, instant updates, full 360 rotation
-- ============================

local CAMERAS = {
    default = { distance = 2.2,  height = 0.2,  pointHeight = -0.05 },
    head    = { distance = 0.9,  height = 0.65, pointHeight = 0.6 },
    body    = { distance = 1.2,  height = 0.2,  pointHeight = 0.2 },
    bottom  = { distance = 0.98, height = -0.7, pointHeight = -0.9 },
}

local ANGLE_STEP = 30.0 -- degrees per rotation click

local cameraHandle = nil
local currentCamera = 'default'
local cameraAngle = 0.0 -- degrees, 0 = directly in front
local isTurnedAround = false
local playerCoords = nil
local playerHeading = nil

-- ============================
-- Core: update camera position instantly on the existing handle
-- ============================
local function updateCamera()
    if not cameraHandle then return end

    local preset = CAMERAS[currentCamera]
    if not preset then return end

    local playerPed = PlayerPedId()
    local angleRad = math.rad(cameraAngle)

    local ox = preset.distance * math.sin(angleRad)
    local oy = preset.distance * math.cos(angleRad)
    local oz = preset.height

    local camPos = GetOffsetFromEntityInWorldCoords(playerPed, ox, oy, oz)
    local pointPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, preset.pointHeight)

    SetCamCoord(cameraHandle, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(cameraHandle, pointPos.x, pointPos.y, pointPos.z)

    Config.debugPrint(string.format(
        'Camera [%s] angle=%.0f: world(%.2f, %.2f, %.2f) point(%.2f, %.2f, %.2f)',
        currentCamera, cameraAngle, camPos.x, camPos.y, camPos.z, pointPos.x, pointPos.y, pointPos.z
    ))
end

-- ============================
-- Camera Functions
-- ============================
function StartCamera()
    local playerPed = PlayerPedId()
    playerCoords = GetEntityCoords(playerPed, true)
    playerHeading = GetEntityHeading(playerPed)
    isTurnedAround = false
    cameraAngle = 0.0
    currentCamera = 'default'

    Config.debugPrint(string.format(
        'StartCamera: ped=%d coords=(%.2f, %.2f, %.2f) heading=%.2f',
        playerPed, playerCoords.x, playerCoords.y, playerCoords.z, playerHeading
    ))

    cameraHandle = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamFov(cameraHandle, 50.0)
    SetCamActive(cameraHandle, true)
    RenderScriptCams(true, false, 0, true, true)

    updateCamera()

    Config.debugPrint('StartCamera: cam=' .. tostring(cameraHandle) .. ' active=' .. tostring(IsCamActive(cameraHandle)))
end

function DestroyCamera()
    if cameraHandle then
        SetCamActive(cameraHandle, false)
        DestroyCam(cameraHandle, true)
        RenderScriptCams(false, false, 0, true, true)
        cameraHandle = nil
    end
    currentCamera = 'default'
    cameraAngle = 0.0
    isTurnedAround = false
    playerCoords = nil
    playerHeading = nil
end

function SetCameraPreset(key)
    if not cameraHandle then return end
    if key ~= 'current' then
        currentCamera = key
    end
    updateCamera()
end

function RotateCamera(direction)
    if not cameraHandle then return end
    if direction == 'left' then
        cameraAngle = cameraAngle - ANGLE_STEP
    else
        cameraAngle = cameraAngle + ANGLE_STEP
    end
    updateCamera()
end

function PedTurnAround()
    if not cameraHandle then return end
    cameraAngle = cameraAngle + 180.0
    updateCamera()
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
