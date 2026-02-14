Config = {}

-- ============================
-- Debug Mode
-- ============================
local function debugPrint(...)
    local success, debugMode = pcall(function()
        return exports['uGen']:GetDebugMode()
    end)
    if success and debugMode then
        print('[uSkin]', ...)
    end
end

Config.debugPrint = debugPrint

-- ============================
-- Automatic Hair Fade
-- ============================
Config.automaticFade = true

-- ============================
-- Default Customization Config
-- ============================
Config.defaultCustomization = {
    ped = true,
    headBlend = true,
    faceFeatures = true,
    headOverlays = true,
    components = true,
    props = true,
    tattoos = true,
    allowExit = true,
    automaticFade = true,
}

-- ============================
-- Ped Component IDs (clothing slots 0-11)
-- ============================
Config.pedComponentIds = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }

-- ============================
-- Ped Prop IDs (accessory slots)
-- ============================
Config.pedPropIds = { 0, 1, 2, 6, 7 }

-- ============================
-- Face Features (20 individual features)
-- ============================
Config.faceFeatures = {
    'noseWidth',
    'nosePeakHigh',
    'nosePeakSize',
    'noseBoneHigh',
    'nosePeakLowering',
    'noseBoneTwist',
    'eyeBrownHigh',
    'eyeBrownForward',
    'cheeksBoneHigh',
    'cheeksBoneWidth',
    'cheeksWidth',
    'eyesOpening',
    'lipsThickness',
    'jawBoneWidth',
    'jawBoneBackSize',
    'chinBoneLowering',
    'chinBoneLenght',
    'chinBoneSize',
    'chinHole',
    'neckThickness',
}

-- ============================
-- Head Overlays
-- ============================
Config.headOverlays = {
    'blemishes',
    'beard',
    'eyebrows',
    'ageing',
    'makeUp',
    'blush',
    'complexion',
    'sunDamage',
    'lipstick',
    'moleAndFreckles',
    'chestHair',
    'bodyBlemishes',
}

-- ============================
-- Eye Color Names
-- ============================
Config.eyeColors = {
    'Green', 'Emerald', 'Light Blue', 'Ocean Blue', 'Light Brown',
    'Dark Brown', 'Hazel', 'Dark Gray', 'Light Gray', 'Pink',
    'Yellow', 'Purple', 'Blackout', 'Shades of Gray', 'Tequila Sunrise',
    'Atomic', 'Warp', 'ECola', 'Space Ranger', 'Ying Yang',
    'Bullseye', 'Lizard', 'Dragon', 'Extra Terrestrial', 'Goat',
    'Smiley', 'Possessed', 'Demon', 'Infected', 'Alien',
    'Undead', 'Zombie',
}

-- ============================
-- Hair Decorations (fades)
-- ============================
Config.hairDecorations = {
    male = {
        { id = 0,  collection = 'mpbeach_overlays',       overlay = 'FM_Hair_Fuzz' },
        { id = 1,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_001' },
        { id = 2,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_002' },
        { id = 3,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_003' },
        { id = 4,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_004' },
        { id = 5,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_005' },
        { id = 6,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_006' },
        { id = 7,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_007' },
        { id = 8,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_008' },
        { id = 9,  collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_009' },
        { id = 10, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_013' },
        { id = 11, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_002' },
        { id = 12, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_011' },
        { id = 13, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_012' },
        { id = 14, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_014' },
        { id = 15, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_015' },
        { id = 16, collection = 'multiplayer_overlays',   overlay = 'NGBea_M_Hair_000' },
        { id = 17, collection = 'multiplayer_overlays',   overlay = 'NGBea_M_Hair_001' },
        { id = 18, collection = 'multiplayer_overlays',   overlay = 'NGBus_M_Hair_000' },
        { id = 19, collection = 'multiplayer_overlays',   overlay = 'NGBus_M_Hair_001' },
        { id = 20, collection = 'multiplayer_overlays',   overlay = 'NGHip_M_Hair_000' },
        { id = 21, collection = 'multiplayer_overlays',   overlay = 'NGHip_M_Hair_001' },
        { id = 22, collection = 'multiplayer_overlays',   overlay = 'NGInd_M_Hair_000' },
        { id = 24, collection = 'mplowrider_overlays',   overlay = 'LR_M_Hair_000' },
        { id = 25, collection = 'mplowrider_overlays',   overlay = 'LR_M_Hair_001' },
        { id = 26, collection = 'mplowrider_overlays',   overlay = 'LR_M_Hair_002' },
        { id = 27, collection = 'mplowrider_overlays',   overlay = 'LR_M_Hair_003' },
        { id = 28, collection = 'mplowrider2_overlays',  overlay = 'LR_M_Hair_004' },
        { id = 29, collection = 'mplowrider2_overlays',  overlay = 'LR_M_Hair_005' },
        { id = 30, collection = 'mplowrider2_overlays',  overlay = 'LR_M_Hair_006' },
        { id = 31, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_000_M' },
        { id = 32, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_001_M' },
        { id = 33, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_002_M' },
        { id = 34, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_003_M' },
        { id = 35, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_004_M' },
        { id = 36, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_005_M' },
        { id = 72, collection = 'mpgunrunning_overlays',  overlay = 'MP_Gunrunning_Hair_M_000_M' },
        { id = 73, collection = 'mpgunrunning_overlays',  overlay = 'MP_Gunrunning_Hair_M_001_M' },
        { id = 74, collection = 'mpVinewood_overlays',    overlay = 'MP_Vinewood_Hair_M_000_M' },
    },
    female = {
        { id = 0,  collection = 'mpbeach_overlays',       overlay = 'FM_Hair_Fuzz' },
        { id = 1,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_001' },
        { id = 2,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_002' },
        { id = 3,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_003' },
        { id = 4,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_004' },
        { id = 5,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_005' },
        { id = 6,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_006' },
        { id = 7,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_007' },
        { id = 8,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_008' },
        { id = 9,  collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_009' },
        { id = 10, collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_010' },
        { id = 11, collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_011' },
        { id = 12, collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_012' },
        { id = 13, collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_013' },
        { id = 14, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_014' },
        { id = 15, collection = 'multiplayer_overlays',   overlay = 'NG_M_Hair_015' },
        { id = 16, collection = 'multiplayer_overlays',   overlay = 'NGBea_F_Hair_000' },
        { id = 17, collection = 'multiplayer_overlays',   overlay = 'NGBea_F_Hair_001' },
        { id = 18, collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_007' },
        { id = 19, collection = 'multiplayer_overlays',   overlay = 'NGBus_F_Hair_000' },
        { id = 20, collection = 'multiplayer_overlays',   overlay = 'NGBus_F_Hair_001' },
        { id = 21, collection = 'multiplayer_overlays',   overlay = 'NGBea_F_Hair_001' },
        { id = 22, collection = 'multiplayer_overlays',   overlay = 'NGHip_F_Hair_000' },
        { id = 23, collection = 'multiplayer_overlays',   overlay = 'NGInd_F_Hair_000' },
        { id = 25, collection = 'mplowrider_overlays',   overlay = 'LR_F_Hair_000' },
        { id = 26, collection = 'mplowrider_overlays',   overlay = 'LR_F_Hair_001' },
        { id = 27, collection = 'mplowrider_overlays',   overlay = 'LR_F_Hair_002' },
        { id = 28, collection = 'mplowrider2_overlays',  overlay = 'LR_F_Hair_003' },
        { id = 29, collection = 'mplowrider2_overlays',  overlay = 'LR_F_Hair_003' },
        { id = 30, collection = 'mplowrider2_overlays',  overlay = 'LR_F_Hair_004' },
        { id = 31, collection = 'mplowrider2_overlays',  overlay = 'LR_F_Hair_006' },
        { id = 32, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_000_F' },
        { id = 33, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_001_F' },
        { id = 34, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_002_F' },
        { id = 35, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_003_F' },
        { id = 36, collection = 'multiplayer_overlays',   overlay = 'NG_F_Hair_003' },
        { id = 37, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_006_F' },
        { id = 38, collection = 'mpbiker_overlays',       overlay = 'MP_Biker_Hair_004_F' },
        { id = 76, collection = 'mpgunrunning_overlays',  overlay = 'MP_Gunrunning_Hair_F_000_F' },
        { id = 77, collection = 'mpgunrunning_overlays',  overlay = 'MP_Gunrunning_Hair_F_001_F' },
        { id = 78, collection = 'mpVinewood_overlays',    overlay = 'MP_Vinewood_Hair_F_000_F' },
    },
}

-- ============================
-- Backpack Weight Modifiers (from esx_skin)
-- ============================
Config.BackpackWeight = {
    [40] = 16,
    [41] = 20,
    [44] = 25,
    [45] = 23,
}

-- ============================
-- Format Conversion: uSkin <-> skinchanger (legacy)
-- Dual format stored in DB: flat skinchanger keys + _uSkin embedded data
-- ============================

-- Mapping tables
local componentToFlat = {
    [0]  = { 'face', nil },
    [1]  = { 'mask_1', 'mask_2' },
    [2]  = { 'hair_1', 'hair_2' },
    [3]  = { 'arms', 'arms_2' },
    [4]  = { 'pants_1', 'pants_2' },
    [5]  = { 'bags_1', 'bags_2' },
    [6]  = { 'shoes_1', 'shoes_2' },
    [7]  = { 'chain_1', 'chain_2' },
    [8]  = { 'tshirt_1', 'tshirt_2' },
    [9]  = { 'bproof_1', 'bproof_2' },
    [10] = { 'decals_1', 'decals_2' },
    [11] = { 'torso_1', 'torso_2' },
}

local propToFlat = {
    [0] = { 'helmet_1', 'helmet_2' },
    [1] = { 'glasses_1', 'glasses_2' },
    [2] = { 'ears_1', 'ears_2' },
    [6] = { 'watches_1', 'watches_2' },
    [7] = { 'bracelets_1', 'bracelets_2' },
}

local faceFeatureFlat = {
    'nose_1', 'nose_2', 'nose_3', 'nose_4', 'nose_5', 'nose_6',
    'eyebrows_5', 'eyebrows_6',
    'cheeks_1', 'cheeks_2', 'cheeks_3',
    'eye_squint', 'lip_thickness',
    'jaw_1', 'jaw_2',
    'chin_1', 'chin_2', 'chin_3', 'chin_4',
    'neck_thickness',
}

local overlayToFlat = {
    blemishes       = { 'blemishes_1', 'blemishes_2', nil, nil },
    beard           = { 'beard_1', 'beard_2', 'beard_3', 'beard_4' },
    eyebrows        = { 'eyebrows_1', 'eyebrows_2', 'eyebrows_3', 'eyebrows_4' },
    ageing          = { 'age_1', 'age_2', nil, nil },
    makeUp          = { 'makeup_1', 'makeup_2', 'makeup_3', 'makeup_4' },
    blush           = { 'blush_1', 'blush_2', 'blush_3', nil },
    complexion      = { 'complexion_1', 'complexion_2', nil, nil },
    sunDamage       = { 'sun_1', 'sun_2', nil, nil },
    lipstick        = { 'lipstick_1', 'lipstick_2', 'lipstick_3', 'lipstick_4' },
    moleAndFreckles = { 'moles_1', 'moles_2', nil, nil },
    chestHair       = { 'chest_1', 'chest_2', 'chest_3', nil },
    bodyBlemishes   = { 'bodyb_1', 'bodyb_2', nil, nil },
}

--- Convert uSkin appearance to skinchanger flat format
function Config.appearanceToFlat(appearance)
    if not appearance then return {} end

    local flat = {}
    flat.sex = appearance.model == 'mp_f_freemode_01' and 1 or 0

    if appearance.components then
        for _, comp in ipairs(appearance.components) do
            local keys = componentToFlat[comp.component_id]
            if keys then
                flat[keys[1]] = comp.drawable
                if keys[2] then flat[keys[2]] = comp.texture end
            end
        end
    end

    if appearance.props then
        for _, prop in ipairs(appearance.props) do
            local keys = propToFlat[prop.prop_id]
            if keys then
                flat[keys[1]] = prop.drawable
                flat[keys[2]] = prop.texture
            end
        end
    end

    if appearance.headBlend then
        flat.mom = appearance.headBlend.shapeFirst or 0
        flat.dad = appearance.headBlend.shapeSecond or 0
        flat.face_md_weight = math.floor((appearance.headBlend.shapeMix or 0) * 100)
        flat.skin_md_weight = math.floor((appearance.headBlend.skinMix or 0) * 100)
    end

    if appearance.faceFeatures then
        for i, key in ipairs(Config.faceFeatures) do
            local flatKey = faceFeatureFlat[i]
            if flatKey then
                flat[flatKey] = math.floor((appearance.faceFeatures[key] or 0) * 10)
            end
        end
    end

    if appearance.headOverlays then
        for name, overlay in pairs(appearance.headOverlays) do
            local keys = overlayToFlat[name]
            if keys then
                flat[keys[1]] = overlay.style or 0
                flat[keys[2]] = math.floor((overlay.opacity or 0) * 10)
                if keys[3] then flat[keys[3]] = overlay.color or 0 end
                if keys[4] then flat[keys[4]] = 0 end
            end
        end
    end

    if appearance.hair then
        flat.hair_1 = appearance.hair.style or 0
        flat.hair_color_1 = appearance.hair.color or 0
        flat.hair_color_2 = appearance.hair.highlight or 0
    end

    flat.eye_color = appearance.eyeColor or 0

    return flat
end

--- Convert skinchanger flat format to uSkin appearance
function Config.flatToAppearance(skin)
    if not skin then return nil end
    if skin._uSkin then return skin._uSkin end
    if skin.model then return skin end

    local model = (skin.sex == 1) and 'mp_f_freemode_01' or 'mp_m_freemode_01'

    local components = {}
    for compId, keys in pairs(componentToFlat) do
        components[#components + 1] = {
            component_id = compId,
            drawable = skin[keys[1]] or 0,
            texture = keys[2] and (skin[keys[2]] or 0) or 0,
        }
    end

    local props = {}
    for propId, keys in pairs(propToFlat) do
        props[#props + 1] = {
            prop_id = propId,
            drawable = skin[keys[1]] or -1,
            texture = skin[keys[2]] or 0,
        }
    end

    local headBlend = {
        shapeFirst = skin.mom or 0,
        shapeSecond = skin.dad or 0,
        skinFirst = skin.mom or 0,
        skinSecond = skin.dad or 0,
        shapeMix = (skin.face_md_weight or 0) / 100.0,
        skinMix = (skin.skin_md_weight or 0) / 100.0,
    }

    local faceFeatures = {}
    for i, key in ipairs(Config.faceFeatures) do
        local flatKey = faceFeatureFlat[i]
        faceFeatures[key] = flatKey and (skin[flatKey] or 0) / 10.0 or 0.0
    end

    local headOverlays = {}
    for name, keys in pairs(overlayToFlat) do
        headOverlays[name] = {
            style = skin[keys[1]] or 0,
            opacity = (skin[keys[2]] or 0) / 10.0,
            color = keys[3] and (skin[keys[3]] or 0) or 0,
        }
    end

    local hair = {
        style = skin.hair_1 or 0,
        color = skin.hair_color_1 or 0,
        highlight = skin.hair_color_2 or 0,
    }

    return {
        model = model,
        headBlend = headBlend,
        faceFeatures = faceFeatures,
        headOverlays = headOverlays,
        components = components,
        props = props,
        hair = hair,
        eyeColor = skin.eye_color or 0,
        tattoos = {},
    }
end

-- ============================
-- Clothes Data (toggle animations)
-- ============================
Config.clothesData = {
    head = {
        animations = {
            on  = { dict = 'mp_masks@standard_car@ds@', anim = 'put_on_mask', move = 51, duration = 600 },
            off = { dict = 'missheist_agency2ahelmet', anim = 'take_off_helmet_stand', move = 51, duration = 1200 },
        },
        props = {
            male   = { { 1, 0 } },
            female = { { 1, 0 } },
        },
    },
    body = {
        animations = {
            on  = { dict = 'clothingtie', anim = 'try_tie_negative_a', move = 51, duration = 1200 },
            off = { dict = 'clothingtie', anim = 'try_tie_negative_a', move = 51, duration = 1200 },
        },
        props = {
            male   = { { 11, 252 }, { 3, 15 }, { 8, 15 }, { 10, 0 }, { 5, 0 } },
            female = { { 11, 15 }, { 8, 14 }, { 3, 15 }, { 10, 0 }, { 5, 0 } },
        },
    },
    bottom = {
        animations = {
            on  = { dict = 're@construction', anim = 'out_of_breath', move = 51, duration = 1300 },
            off = { dict = 're@construction', anim = 'out_of_breath', move = 51, duration = 1300 },
        },
        props = {
            male   = { { 4, 61 }, { 6, 34 } },
            female = { { 4, 15 }, { 6, 35 } },
        },
    },
}
