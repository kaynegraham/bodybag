local ActiveBags  = {}
local bagCounter  = 0

local function IsAuthorised(source)
    if #Config.AuthorisedJobs == 0 then return true end
    -- job integration placeholder
    return true
end

local function GenerateBagId(source)
    bagCounter = bagCounter + 1
    return tostring(source) .. '_' .. tostring(bagCounter)
end

local function NotifyClient(source, message)
    TriggerClientEvent('kg_bodybag:client:notify', source, message)
end

-- ─── Place Bag ────────────────────────────────────────────────────────────────

RegisterNetEvent('kg_bodybag:server:placeBag')
AddEventHandler('kg_bodybag:server:placeBag', function(deadPlayerSource)
    local source = source

    if GetPlayerPed(source) == 0 then return end

    deadPlayerSource = tonumber(deadPlayerSource)
    if not deadPlayerSource or GetPlayerPed(deadPlayerSource) == 0 then
        NotifyClient(source, Config.Notifications.noDeadNearby)
        return
    end

    if not IsEntityDead(GetPlayerPed(deadPlayerSource)) then
        NotifyClient(source, Config.Notifications.noDeadNearby)
        return
    end

    if not IsAuthorised(source) then
        NotifyClient(source, Config.Notifications.notAuthorised)
        return
    end

    local coords   = GetEntityCoords(GetPlayerPed(deadPlayerSource))
    local bagId    = GenerateBagId(source)

    ActiveBags[bagId] = {
        ownerSource      = source,
        deadPlayerSource = deadPlayerSource,
        coords           = coords,
    }

    TriggerClientEvent('kg_bodybag:client:spawnBag', -1, { bagId = bagId, coords = coords })
    TriggerClientEvent('kg_bodybag:client:placeInBag', deadPlayerSource)
    NotifyClient(source, Config.Notifications.bagged)
end)

-- ─── Place Bag (NPC) ──────────────────────────────────────────────────────────

RegisterNetEvent('kg_bodybag:server:placeBagNpc')
AddEventHandler('kg_bodybag:server:placeBagNpc', function(coords)
    local source = source

    if GetPlayerPed(source) == 0 then return end

    if not IsAuthorised(source) then
        NotifyClient(source, Config.Notifications.notAuthorised)
        return
    end

    local bagId = GenerateBagId(source)

    ActiveBags[bagId] = {
        ownerSource = source,
        coords      = coords,
    }

    TriggerClientEvent('kg_bodybag:client:spawnBag', -1, { bagId = bagId, coords = coords })
    NotifyClient(source, Config.Notifications.bagged)
end)

-- ─── Remove Bag ───────────────────────────────────────────────────────────────

RegisterNetEvent('kg_bodybag:server:removeBag')
AddEventHandler('kg_bodybag:server:removeBag', function(bagId)
    local source = source

    if GetPlayerPed(source) == 0 then return end

    local bag = ActiveBags[bagId]
    if not bag then return end

    if bag.ownerSource ~= source and not IsAuthorised(source) then
        NotifyClient(source, Config.Notifications.notAuthorised)
        return
    end

    TriggerClientEvent('kg_bodybag:client:removeBag', -1, { bagId = bagId })
    NotifyClient(source, Config.Notifications.removed)
    ActiveBags[bagId] = nil
end)

-- ─── Cleanup on player drop ───────────────────────────────────────────────────

AddEventHandler('playerDropped', function()
    local source = source
    for bagId, bag in pairs(ActiveBags) do
        if bag.ownerSource == source or bag.deadPlayerSource == source then
            TriggerClientEvent('kg_bodybag:client:removeBag', -1, { bagId = bagId })
            ActiveBags[bagId] = nil
        end
    end
end)

-- ─── Cleanup on resource stop ─────────────────────────────────────────────────

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for bagId in pairs(ActiveBags) do
        TriggerClientEvent('kg_bodybag:client:removeBag', -1, { bagId = bagId })
    end
    ActiveBags = {}
end)
