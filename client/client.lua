local LocalBags = {}
local isBusy    = false

-- ─── Notify ───────────────────────────────────────────────────────────────────

local function Notify(message)
    AddTextEntry('kg_bodybag_notif', message)
    BeginTextCommandDisplayHelp('kg_bodybag_notif')
    EndTextCommandDisplayHelp(0, false, true, 3500)
end

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function GetClosestDeadPlayer(maxDist)
    local myPed    = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local closest, closestServerId, closestDist = nil, nil, maxDist

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            if IsEntityDead(targetPed) then
                local dist = #(myCoords - GetEntityCoords(targetPed))
                if dist < closestDist then
                    closest         = targetPed
                    closestServerId = GetPlayerServerId(playerId)
                    closestDist     = dist
                end
            end
        end
    end

    if closest then
        return closest, closestServerId, GetEntityCoords(closest)
    end
    return nil, nil, nil
end

local function GetClosestDeadNpc(maxDist)
    local myCoords = GetEntityCoords(PlayerPedId())
    local closest, closestCoords, closestDist = nil, nil, maxDist

    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and IsEntityDead(ped) then
            local pedCoords = GetEntityCoords(ped)
            local dist      = #(myCoords - pedCoords)
            if dist < closestDist then
                closest       = ped
                closestCoords = pedCoords
                closestDist   = dist
            end
        end
    end

    return closest, closestCoords
end

local function GetClosestBag(maxDist)
    local myCoords                 = GetEntityCoords(PlayerPedId())
    local closestId, closestDist   = nil, maxDist

    for bagId, handle in pairs(LocalBags) do
        if DoesEntityExist(handle) then
            local dist = #(myCoords - GetEntityCoords(handle))
            if dist < closestDist then
                closestId   = bagId
                closestDist = dist
            end
        end
    end

    return closestId
end

local function PlayBagAnimation()
    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
    Wait(Config.AnimTime)
    ClearPedTasksImmediately(ped)
end

-- ─── Commands ─────────────────────────────────────────────────────────────────

RegisterCommand('bodybag', function()
    if isBusy then return end

    local _, serverId = GetClosestDeadPlayer(Config.MaxDistance)
    if serverId then
        isBusy = true
        CreateThread(function()
            PlayBagAnimation()
            TriggerServerEvent('kg_bodybag:server:placeBag', serverId)
            isBusy = false
        end)
        return
    end

    local npcPed, npcCoords = GetClosestDeadNpc(Config.MaxDistance)
    if not npcPed then
        Notify(Config.Notifications.noDeadNearby)
        return
    end

    isBusy = true
    CreateThread(function()
        PlayBagAnimation()
        DeleteEntity(npcPed)
        TriggerServerEvent('kg_bodybag:server:placeBagNpc', npcCoords)
        isBusy = false
    end)
end, false)

RegisterCommand('removebag', function()
    if isBusy then return end

    local bagId = GetClosestBag(Config.MaxDistance)
    if not bagId then
        Notify(Config.Notifications.noBagNearby)
        return
    end

    isBusy = true
    CreateThread(function()
        PlayBagAnimation()
        TriggerServerEvent('kg_bodybag:server:removeBag', bagId)
        isBusy = false
    end)
end, false)

-- ─── Net events from server ───────────────────────────────────────────────────

RegisterNetEvent('kg_bodybag:client:spawnBag')
RegisterNetEvent('kg_bodybag:client:removeBag')
RegisterNetEvent('kg_bodybag:client:placeInBag')
RegisterNetEvent('kg_bodybag:client:notify')

-- Spawns a non-networked local prop. The server broadcasts this to every client
-- simultaneously, so Onesync must not also sync it — isNetwork = false prevents
-- duplicate props appearing when the networked copy would propagate on top.
AddEventHandler('kg_bodybag:client:spawnBag', function(data)
    CreateThread(function()
        local hash = GetHashKey(Config.BagModel)

        if not IsModelValid(hash) then
            print('^1[bodybag] Model not valid: ' .. Config.BagModel)
            return
        end

        while not HasModelLoaded(hash) do
            RequestModel(hash)
            Wait(100)
        end

        local c   = data.coords
        local obj = CreateObject(hash, c.x, c.y, c.z, false, false, false)
        PlaceObjectOnGroundProperly(obj)
        SetModelAsNoLongerNeeded(hash)

        LocalBags[data.bagId] = obj
    end)
end)

AddEventHandler('kg_bodybag:client:removeBag', function(data)
    local handle = LocalBags[data.bagId]
    if handle and DoesEntityExist(handle) then
        DeleteObject(handle)
    end
    LocalBags[data.bagId] = nil
end)

AddEventHandler('kg_bodybag:client:placeInBag', function()
    CreateThread(function()
        local ped = PlayerPedId()
        local c   = Config.HospitalCoords

        SetEntityVisible(ped, false, false)
        DoScreenFadeOut(1000)
        Wait(1200)

        NetworkResurrectLocalPlayer(c.x, c.y, c.z, 0.0, true, false)
        Wait(500)

        DoScreenFadeIn(1000)
        SetEntityVisible(ped, true, false)
    end)
end)

AddEventHandler('kg_bodybag:client:notify', function(message)
    Notify(message)
end)

-- ─── Cleanup on resource stop ─────────────────────────────────────────────────

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, handle in pairs(LocalBags) do
        if DoesEntityExist(handle) then
            DeleteObject(handle)
        end
    end
end)
