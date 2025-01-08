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
    local nearestPlayer, nearestCoords = GetClosestPlayer(2.5)

    if not nearestPlayer then showAlert("There is no player nearby", 3500) return end

    if IsPlayerDead(nearestPlayer) then 
        BodyBagAnimation(PlayerPedId())
    TriggerServerEvent('bodybag:Bag', GetPlayerServerId(nearestPlayer))
    TriggerEvent('bodybag:spawnbag', nearestCoords)
    else
        showAlert("There is no player nearby that is dead", 3500)
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

function GetClosestPlayer(maxDistance)
    local players = GetActivePlayers() 
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped) 
    local closestPlayer 
   
    for i,v in ipairs(players) do 
       local target = GetPlayerPed(v) 
   
       if target ~= ped then 
        targetCoords = GetEntityCoords(target) 
       local distance = Vdist(targetCoords.x, targetCoords.y, targetCoords.z, coords.x, coords.y, coords.z)
   
       if distance < maxDistance then
           closestPlayer = v
               end
            end
       end
       return closestPlayer, targetCoords
   end

function TeleportPed(ped, destination)
        ClearPedTasks(ped)
        DoScreenFadeOut(1000)
        SetEntityCoords(ped, destination.x, destination.y, destination.z, false, true, true, false)
        Wait(1000)
        DoScreenFadeIn(250)
        NetworkResurrectLocalPlayer(Config.hospitalCoords, true, true, false)
        SetEntityVisible(ped, true, true)
        SetEntityHealth(ped, 0)
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