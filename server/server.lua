local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-carboosting:server:carDelivered', function(tier, trackerActive)
    local src = source
    print("Received car delivery event with tier:", tier, "trackerActive:", trackerActive)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local rewards = Config.Rewards[tier]
        if rewards then
            if tier == 3 then
                local rewardMoney = rewards.money[math.random(#rewards.money)]
                Player.Functions.AddMoney('cash', rewardMoney)
                print("Giving reward money for Tier 3:", rewardMoney)
                TriggerClientEvent('QBCore:Notify', src, "You received $" .. rewardMoney .. " for delivering the car!", 'success')
            elseif tier == 1 or tier == 2 then
                if not trackerActive then
                    local rewardMoney = rewards.full.money[math.random(#rewards.full.money)]
                    local rewardItem = rewards.full.items[math.random(#rewards.full.items)]
                    Player.Functions.AddMoney('cash', rewardMoney)
                    Player.Functions.AddItem(rewardItem, 1)
                    print("Giving full reward money for Tier", tier, ":", rewardMoney)
                    print("Giving reward item for Tier", tier, ":", rewardItem)
                    TriggerClientEvent('QBCore:Notify', src, "You received $" .. rewardMoney .. " and a " .. rewardItem .. " for delivering the car!", 'success')
                else
                    local penaltyMoney = rewards.penalty.money[math.random(#rewards.penalty.money)]
                    Player.Functions.AddMoney('cash', penaltyMoney)
                    print("Giving penalty reward money for Tier", tier, ":", penaltyMoney)
                    TriggerClientEvent('QBCore:Notify', src, "You received $" .. penaltyMoney .. " for delivering the car with the tracker!", 'warning')
                end
            end
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
