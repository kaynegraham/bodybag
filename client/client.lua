-- Variables -- 
local bodyBag = nil

-- Commands --
RegisterCommand("bodybag", function()
    TriggerEvent('bodybag:bagPlayer')
end)

RegisterCommand("deletebodybag", function()
    DeleteBodyBag()
end)

-- Events & Functions -- 
RegisterNetEvent('bodybag:bagPlayer')
AddEventHandler('bodybag:bagPlayer', function()
    local nearestEntity, nearestCoords, isPlayer = GetClosestEntity(2.5)

    if not nearestEntity then showAlert("There is no entity nearby", 3500) return end

    if IsEntityDead(nearestEntity) then
        BodyBagAnimation(PlayerPedId())
        
        if isPlayer then 
                TriggerServerEvent('bodybag:Bag', GetPlayerServerId(nearestPlayer))
        end 

        TriggerEvent('bodybag:spawnbag', nearestCoords)
    else 
        showAlert("There is no entity nearby that is dead", 3500)
    end
end)

RegisterNetEvent('bodybag:placeinBag')
AddEventHandler('bodybag:placeinBag', function()
    BodyBag()
end)

RegisterNetEvent('bodybag:spawnbag')
AddEventHandler('bodybag:spawnbag', function(coords)
    SpawnBagModel(coords)
end)


function GetClosestEntity(maxDistance)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped) 
    local closestEntity
    local closestDistance = maxDistance
    local isPlayer = false 

    for _v in ipairs(GetActivePlayers()) do 
        local targetPed = GetPlayerPed(player)
        if targetPed ~= ped and IsEntityDead(targetPed) then 
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)
            if distance < closestDistance then 
                closestDistance = distance
                closestEntity = targetPed
                isPlayer = true 
            end
        end
    end 

    for pedHandle in EnumeratePeds() do 
        if not IsPedAPlayer(pedHandle) and IsEntityDead(pedHandle) then 
            local pedCoords = GetEntityCoords(pedHandle)
            local distance = #(coords - pedCoords)
            if distance < closestDistance then
                closestDistance = distance 
                closestEntity = pedHandle
                isPlayer = false 
            end
        end
    end
    return closestEntity, GetEntityCoords(closestEntity), isPlayer
end

function EnumeratePeds() 
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        if not handle then return end 
        local success 
        repeat 
            coroutine.yield(ped)
            success, ped = FindNextPed(handle)
        until not success 
        EndFindPed(handle)
    end)
end 

function TeleportPed(ped, destination)
    if not DoesEntityExist(ped) then return end 

        ClearPedTasks(ped)
        DoScreenFadeOut(1000)
        SetEntityCoords(ped, destination.x, destination.y, destination.z, false, true, true, false)
        Wait(1000)
        DoScreenFadeIn(250)

        if IsPedAPlayer(ped) then 
        NetworkResurrectLocalPlayer(Config.hospitalCoords, true, true, false)
        SetEntityVisible(ped, true, true)
        SetEntityHealth(ped, 0)
        else 
         SetEntityHealth(ped, 0)
        SetPedDiesWhenInjured(ped, true)
    end
end

function BodyBagAnimation(ped)
    TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
    Wait(Config.animTime)
    ClearPedTasksImmediately(ped)
end

function SpawnBagModel(coords)
    hash = `xm_prop_body_bag`
    RequestModel(hash)
    while not HasModelLoaded(hash) do 
        Wait(1)
    end 
    bodyBag = CreateObject(hash, coords.x, coords.y, coords.z, true, true, true)
    PlaceObjectOnGroundProperly(bodyBag)
end 

function BodyBag()
    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, false, false)
    TeleportPed(playerPed, Config.hospitalCoords)
end 

function DeleteBodyBag()
    if bodyBag then 
        BodyBagAnimation(PlayerPedId())
        SetModelAsNoLongerNeeded(hash)
        DeleteObject(bodyBag)
    else
        showAlert("No bag to delete.", 3500)
    end
end

function showAlert(message, duration)
    AddTextEntry('bodybag:alert', message)
    BeginTextCommandDisplayHelp('bodybag:alert')
    EndTextCommandDisplayHelp(0, false, true, duration)
end

-- On Resource Stop -- 
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then 
        return 
    end 
    DeleteObject(bodyBag)
end)