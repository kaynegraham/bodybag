RegisterNetEvent('bodybag:Bag')
AddEventHandler('bodybag:Bag', function(deadPed)
    if not deadPed or coords then return end
    TriggerClientEvent('bodybag:placeinBag', deadPed)
end)