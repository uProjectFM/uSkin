-- ============================
-- uSkin - Server
-- ESX database integration: save/load appearance from users.skin column
-- Dual format: flat skinchanger keys + _uSkin embedded data for full compatibility
-- Uses same event names as esx_skin for es_extended/esx_identity compatibility
-- ============================

local ESX = exports['es_extended']:getSharedObject()

-- ============================
-- Helper: build dual-format skin for DB storage
-- ============================
local function buildDualFormat(skin)
    if not skin or type(skin) ~= 'table' then return nil end

    -- Already flat skinchanger format (legacy caller like esx_barbershop)
    if skin.sex ~= nil and not skin.model then
        return skin
    end

    -- uSkin format: convert to flat + embed original
    local flat = Config.appearanceToFlat(skin)
    flat._uSkin = skin
    return flat
end

-- ============================
-- Helper: update player max weight from backpack
-- ============================
local function updateBackpackWeight(xPlayer, skin)
    if not skin or ESX.GetConfig().CustomInventory then return end

    local bags = skin.bags_1
    if not bags and skin.components then
        for _, comp in ipairs(skin.components) do
            if comp.component_id == 5 then
                bags = comp.drawable
                break
            end
        end
    end

    local defaultMaxWeight = ESX.GetConfig().MaxWeight
    local modifier = bags and Config.BackpackWeight[bags]

    if modifier then
        xPlayer.setMaxWeight(defaultMaxWeight + modifier)
    else
        xPlayer.setMaxWeight(defaultMaxWeight)
    end
end

-- ============================
-- Save appearance to DB (dual format)
-- ============================
RegisterNetEvent('esx_skin:save', function(skin)
    if not skin or type(skin) ~= 'table' then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local dualSkin = buildDualFormat(skin)
    if not dualSkin then return end

    updateBackpackWeight(xPlayer, dualSkin)

    MySQL.update('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
        ['@skin'] = json.encode(dualSkin),
        ['@identifier'] = xPlayer.getIdentifier(),
    })
end)

-- ============================
-- Set weight on player load (backpack modifier)
-- ============================
RegisterNetEvent('esx_skin:setWeight', function(skin)
    if not skin or type(skin) ~= 'table' then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    updateBackpackWeight(xPlayer, skin)
end)

-- ============================
-- Get saved appearance from DB
-- ============================
ESX.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end

    MySQL.query('SELECT skin FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.getIdentifier(),
    }, function(result)
        if result and result[1] and result[1].skin then
            cb(json.decode(result[1].skin))
        else
            cb(nil)
        end
    end)
end)

-- ============================
-- Admin Command: /skin [playerId]
-- ============================
ESX.RegisterCommand('skin', 'admin', function(xPlayer, args)
    local target = args.playerId or xPlayer
    target.triggerEvent('esx_skin:openSaveableMenu')
end, false, {
    help = 'Open skin customization',
    validate = false,
    arguments = {
        { name = 'playerId', help = 'Target player (default: self)', type = 'player' },
    },
})
