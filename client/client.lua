local QBCore = exports['qb-core']:GetCoreObject()
local boosting = false
local targetCar = nil
local currentTier = nil
local carLocation = nil
local searchBlip = nil
local searchZoneBlip = nil
local spawnedCar = nil
local inTargetCar = false
local trackerActive = true
local dispatchSent = false
local dispatchBlip = nil
local currentMinigameIndex = 1
local minigames = {}

-- Load the model and spawn the ped
Citizen.CreateThread(function()
    local pedModel = GetHashKey(Config.PedModel)

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(1)
    end

    local ped = CreatePed(4, pedModel, Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z - 1.0, Config.PedLocation.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                action = function(entity)
                    TriggerEvent('qb-carboosting:client:startBoosting')
                end,
                icon = "fas fa-car",
                label = 'Vehicle Order',
                canInteract = function()
                    return not boosting
                end
            },
            {
                type = "client",
                action = function()
                    TriggerEvent('qb-carboosting:client:stopBoosting')
                end,
                icon = "fas fa-times",
                label = 'Cancel Order',
                canInteract = function()
                    return boosting
                end
            },
            {
                type = "client",
                action = function()
                    TriggerEvent('qb-carboosting:client:completeOrder')
                end,
                icon = "fas fa-check",
                label = 'Complete Order',
                canInteract = function()
                    return boosting and not inTargetCar and IsVehicleNearPed(Config.DropOffLocation, 10.0)
                end
            },
        },
        distance = 2.5,
    })

    -- Create a blip for the ped location
    local blip = AddBlipForCoord(Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z)
    SetBlipSprite(blip, Config.PedBlip.Sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.PedBlip.Scale)
    SetBlipColour(blip, Config.PedBlip.Color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.PedBlip.Text)
    EndTextCommandSetBlipName(blip)
end)

function IsVehicleNearPed(location, radius)
    local vehicle = GetClosestVehicle(location.x, location.y, location.z, radius, 0, 71)
    if vehicle ~= 0 then
        local vehicleCoords = GetEntityCoords(vehicle)
        return Vdist(location.x, location.y, location.z, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z) < radius
    end
    return false
end

-- Event to start boosting
RegisterNetEvent('qb-carboosting:client:startBoosting', function()
    if not boosting then
        local randomTier = math.random(1, 3)
        local carList = Config.CarTiers[randomTier]
        targetCar = carList[math.random(#carList)]
        currentTier = randomTier

        -- Define a random location for the target car
        carLocation = {
            x = Config.PedLocation.x + math.random(-Config.CarSearchRadius, Config.CarSearchRadius),
            y = Config.PedLocation.y + math.random(-Config.CarSearchRadius, Config.CarSearchRadius),
            z = Config.PedLocation.z
        }

        -- Add a search area blip
        searchZoneBlip = AddBlipForRadius(carLocation.x, carLocation.y, carLocation.z, Config.CarSearchRadius)
        SetBlipColour(searchZoneBlip, 1) -- Red
        SetBlipAlpha(searchZoneBlip, 128)
        
        if Config.Debug then
            -- Add an exact location blip for debugging
            searchBlip = AddBlipForCoord(carLocation.x, carLocation.y, carLocation.z)
            SetBlipSprite(searchBlip, 225) -- Car
            SetBlipColour(searchBlip, 1) -- Red
            SetBlipScale(searchBlip, 1.0)
            SetBlipAsShortRange(searchBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Target Car (Debug)")
            EndTextCommandSetBlipName(searchBlip)
        end

        -- Spawn the target car
        local vehicleHash = GetHashKey(targetCar)
        RequestModel(vehicleHash)
        while not HasModelLoaded(vehicleHash) do
            Citizen.Wait(1)
        end

        spawnedCar = CreateVehicle(vehicleHash, carLocation.x, carLocation.y, carLocation.z, 0.0, true, false)
        SetVehicleDoorsLocked(spawnedCar, 2) -- Locked

        boosting = true
        dispatchSent = false
        QBCore.Functions.Notify("Boost a " .. targetCar .. ". Search the area and deliver it to the drop-off point. Remove the tracker as soon as possible!")
        print("Boosting started with tier:", currentTier)
    else
        QBCore.Functions.Notify("You are already on a boosting mission.")
    end
end)

-- Event to stop boosting
RegisterNetEvent('qb-carboosting:client:stopBoosting', function()
    if boosting then
        boosting = false
        targetCar = nil
        currentTier = nil
        if searchBlip then RemoveBlip(searchBlip) end
        if searchZoneBlip then RemoveBlip(searchZoneBlip) end
        if spawnedCar then DeleteVehicle(spawnedCar) end
        if dispatchBlip then RemoveBlip(dispatchBlip) end
        inTargetCar = false
        trackerActive = false
        QBCore.Functions.Notify("Boosting mission canceled.")
    else
        QBCore.Functions.Notify("You are not on a boosting mission.")
    end
end)

-- Event to complete the order
RegisterNetEvent('qb-carboosting:client:completeOrder', function()
    if boosting and not inTargetCar and IsVehicleNearPed(Config.DropOffLocation, 10.0) then
        QBCore.Functions.Notify("Car delivered successfully!")
        print("Delivering car with tier:", currentTier)
        TriggerServerEvent('qb-carboosting:server:carDelivered', currentTier)
        boosting = false
        targetCar = nil
        currentTier = nil
        trackerActive = false
        if spawnedCar then DeleteVehicle(spawnedCar) end
        if dispatchBlip then RemoveBlip(dispatchBlip) end
    else
        QBCore.Functions.Notify("No car in the delivery zone or you are still in the car.", 'error')
    end
end)

-- Main loop to check boosting progress
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if boosting and targetCar then
            local playerPed = PlayerPedId()

            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) == targetCar then
                    if not inTargetCar then
                        QBCore.Functions.Notify("You have stolen the " .. targetCar .. "! Deliver it to the drop-off point. Remove the tracker as soon as possible!")
                        SetNewWaypoint(Config.DropOffLocation.x, Config.DropOffLocation.y)
                        inTargetCar = true

                        -- Trigger police dispatch once
                        if not dispatchSent then
                            exports['ps-dispatch']:CarBoosting(vehicle)
                            dispatchSent = true
                        end

                        if searchBlip then RemoveBlip(searchBlip) end
                        if searchZoneBlip then RemoveBlip(searchZoneBlip) end
                    end
                end
            else
                if inTargetCar then
                    inTargetCar = false
                    print("Player exited the target car")
                end
            end
        end

        if Config.Debug then
            DrawDebugInfo()
        end
    end
end)

function DrawDebugInfo()
    local debugText = string.format("Boosting: %s\nIn Target Car: %s\nTracker Active: %s\nCurrent Tier: %s", tostring(boosting), tostring(inTargetCar), tostring(trackerActive), tostring(currentTier))
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.5)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(1, 0, 0, 0, 205)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(debugText)
    DrawText(0.5, 0.0)
end

-- Update police about car location every 30 seconds if tracker is active
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000) -- 30 seconds
        if boosting and inTargetCar and trackerActive then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if dispatchBlip then RemoveBlip(dispatchBlip) end
            dispatchBlip = exports['ps-dispatch']:CarBoosting(vehicle)
        end
    end
end)

-- Minigame functions
function PlayScrambler()
    print("Playing Scrambler Minigame")
    exports['ps-ui']:Scrambler(function(success)
        print("Scrambler Minigame Result:", success)
        MinigameResult(success)
    end, "alphabet", 30, 0)
end

function PlayThermite()
    print("Playing Thermite Minigame")
    exports['ps-ui']:Thermite(function(success)
        print("Thermite Minigame Result:", success)
        MinigameResult(success)
    end, 10, 5, 3)
end

function PlayMaze()
    print("Playing Maze Minigame")
    exports['ps-ui']:Maze(function(success)
        print("Maze Minigame Result:", success)
        MinigameResult(success)
    end, 20)
end

function MinigameResult(success)
    if success then
        currentMinigameIndex = currentMinigameIndex + 1
        if currentMinigameIndex > #minigames then
            print("All minigames completed successfully")
            TriggerServerEvent('qb-carboosting:server:trackerRemoved')
        else
            PlayNextMinigame()
        end
    else
        print("Minigame failed")
        TriggerEvent('qb-carboosting:client:notifyTrackerRemoved', false)
    end
end

function PlayNextMinigame()
    local minigame = minigames[currentMinigameIndex]
    print("Playing next minigame:", minigame)
    if minigame == "Scrambler" then
        PlayScrambler()
    elseif minigame == "Thermite" then
        PlayThermite()
    elseif minigame == "Maze" then
        PlayMaze()
    end
end

-- Trigger minigames based on tier
RegisterNetEvent('qb-carboosting:client:removeTrackerMiniGame', function(tier)
    print("Starting minigames for tier:", tier)
    currentMinigameIndex = 1
    if tier == 1 then
        minigames = {"Scrambler", "Thermite", "Maze"}
    elseif tier == 2 then
        minigames = {"Scrambler", "Thermite"}
    elseif tier == 3 then
        minigames = {"Scrambler"}
    end
    PlayNextMinigame()
end)

RegisterNetEvent('qb-carboosting:client:notifyTrackerRemoved', function(success)
    if success then
        QBCore.Functions.Notify("Tracker removed successfully!")
        trackerActive = false
    else
        QBCore.Functions.Notify("Failed to remove tracker!")
    end
end)

RegisterNetEvent('qb-carboosting:client:useHakKit', function()
    if currentTier then
        print("hak_kit used, starting minigames for tier:", currentTier)
        TriggerEvent('qb-carboosting:client:removeTrackerMiniGame', currentTier)
    else
        print("currentTier is nil, cannot start minigames")
        QBCore.Functions.Notify("Unable to start minigame, current tier is not set.", 'error')
    end
end)
