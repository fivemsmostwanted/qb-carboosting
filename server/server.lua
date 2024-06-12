local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-carboosting:server:carDelivered', function(tier)
    local src = source
    print("Received car delivery event with tier:", tier)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local rewards = Config.Rewards[tier]
        if rewards then
            local reward = rewards[math.random(#rewards)]
            Player.Functions.AddMoney('cash', reward)
            print("Giving reward:", reward)
            TriggerClientEvent('QBCore:Notify', src, "You received $" .. reward .. " for delivering the car!", 'success')
        else
            print("No rewards found for tier:", tier)
        end
    else
        print("Player not found for source:", src)
    end
end)

RegisterNetEvent('qb-carboosting:server:trackerRemoved', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveItem('hak_kit', 1)
        TriggerClientEvent('qb-carboosting:client:notifyTrackerRemoved', src, true)
    else
        print("Player not found for source:", src)
    end
end)

QBCore.Functions.CreateUseableItem("hak_kit", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(src), false)
    if vehicle ~= 0 then
        TriggerClientEvent('qb-carboosting:client:useHakKit', src)
    else
        TriggerClientEvent('QBCore:Notify', src, "You need to be in a vehicle to use this item.", 'error')
    end
end)
