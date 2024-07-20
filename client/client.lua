local QBCore = exports['qb-core']:GetCoreObject()
local boosting = false
local targetCar = nil
local currentTier = nil
local carLocation = nil
local dropOffLocation = nil
local searchBlip = nil
local searchZoneBlip = nil
local dropOffBlip = nil
local spawnedCar = nil
local inTargetCar = false
local trackerActive = false
local dispatchSent = false
local dispatchBlip = nil
local currentMinigameIndex = 1
local minigames = {}
local cooldown = false
local cooldownEndTime = 0
local dropOffPed = nil
local dropOffEmailSent = false
local notificationShown = false

CreateThread(function()
    local pedModel = GetHashKey(Config.PedModel)

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end

    local ped = CreatePed(4, pedModel, Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z - 1.0, Config.PedLocation.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    action = function(entity)
                        if cooldown then
                            TriggerEvent('qb-carboosting:client:suspiciousActivity')
                        else
                            TriggerEvent('qb-carboosting:client:startBoostingRequest')
                        end
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
                }
            },
            distance = 2.5,
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(ped, {
            {
                onSelect = function(entity)
                    if cooldown then
                        TriggerEvent('qb-carboosting:client:suspiciousActivity')
                    else
                        TriggerEvent('qb-carboosting:client:startBoostingRequest')
                    end
                end,
                distance = 2.5,
                icon = "fas fa-car",
                label = 'Vehicle Order',
                canInteract = function()
                    return not boosting
                end
            },
            {
                onSelect = function()
                    TriggerEvent('qb-carboosting:client:stopBoosting')
                end,
                distance = 2.5,
                icon = "fas fa-times",
                label = 'Cancel Order',
                canInteract = function()
                    return boosting
                end
            }
        })
    end

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

function JobEmail(msg, event)
    local phoneNr = 'Car Thief'
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = phoneNr,
        subject = "Details",
        message = msg,
        button = {
            enabled = true,
            buttonEvent = event
        }
    })
end

function LayLowEmail(msg)
    local phoneNr = 'Car Thief'
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = phoneNr,
        subject = "Lay Low",
        message = msg,
        button = {
            enabled = false
        }
    })
end

-- Event to request boosting
RegisterNetEvent('qb-carboosting:client:startBoostingRequest', function()
    if not boosting then
        QBCore.Functions.Notify("You have received a new vehicle order. Check your phone to accept or decline.")
        JobEmail('Yo,<br /><br />You have a new vehicle order. Please accept or decline the request on your phone.<br />', 'qb-carboosting:client:acceptBoostingMission')
    else
        QBCore.Functions.Notify("You are already on a boosting mission.")
    end
end)

-- Event to accept boosting mission
RegisterNetEvent('qb-carboosting:client:acceptBoostingMission', function()
    TriggerEvent('qb-carboosting:client:startBoosting')
end)

-- Event to decline boosting mission --TODO Still not being used
RegisterNetEvent('qb-carboosting:client:declineBoostingMission', function()
    QBCore.Functions.Notify("You have declined the vehicle order.")
end)

-- Event to start boosting
RegisterNetEvent('qb-carboosting:client:startBoosting', function()
    if not boosting then
        local randomTier = math.random(1, 3)
        local carList = Config.CarTiers[randomTier]
        targetCar = carList[math.random(#carList)]
        currentTier = randomTier

        -- Select a random spawn location
        local spawnLocation = Config.SpawnLocations[math.random(#Config.SpawnLocations)]
        carLocation = {
            x = spawnLocation.x,
            y = spawnLocation.y,
            z = spawnLocation.z
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
            Wait(1)
        end

        spawnedCar = CreateVehicle(vehicleHash, carLocation.x, carLocation.y, carLocation.z, 0.0, true, false)
        SetVehicleDoorsLocked(spawnedCar, 2) -- Locked

        boosting = true
        trackerActive = true
        dispatchSent = false
        dropOffEmailSent = false
        notificationShown = false
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
        trackerActive = false
        if searchBlip then RemoveBlip(searchBlip) end
        if searchZoneBlip then RemoveBlip(searchZoneBlip) end
        if dropOffBlip then RemoveBlip(dropOffBlip) end
        if spawnedCar then DeleteVehicle(spawnedCar) end
        if dropOffPed then DeleteEntity(dropOffPed) end
        if dispatchBlip then RemoveBlip(dispatchBlip) end
        inTargetCar = false
        notificationShown = false
        QBCore.Functions.Notify("Boosting mission canceled.")
    else
        QBCore.Functions.Notify("You are not on a boosting mission.")
    end
end)

-- Event to accept drop-off location
RegisterNetEvent('qb-carboosting:client:acceptDropOff', function()
    SetNewWaypoint(dropOffLocation.x, dropOffLocation.y)
    dropOffBlip = AddBlipForCoord(dropOffLocation.x, dropOffLocation.y, dropOffLocation.z)
    SetBlipSprite(dropOffBlip, 225) -- Car
    SetBlipColour(dropOffBlip, 1) -- Red
    SetBlipScale(dropOffBlip, 1.0)
    SetBlipAsShortRange(dropOffBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drop-Off Location")
    EndTextCommandSetBlipName(dropOffBlip)

    local pedModel = GetHashKey(Config.PedModel)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end

    dropOffPed = CreatePed(4, pedModel, dropOffLocation.x, dropOffLocation.y, dropOffLocation.z - 1.0, dropOffLocation.heading, false, true)
    FreezeEntityPosition(dropOffPed, true)
    SetEntityInvincible(dropOffPed, true)
    SetBlockingOfNonTemporaryEvents(dropOffPed, true)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(dropOffPed, {
            options = {
                {
                    type = "client",
                    action = function()
                        TriggerEvent('qb-carboosting:client:completeOrder')
                    end,
                    icon = "fas fa-check",
                    label = 'Complete Delivery',
                    canInteract = function()
                        return boosting and not inTargetCar and IsVehicleNearPed(dropOffLocation, 10.0)
                    end
                },
            },
            distance = 2.5,
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(dropOffPed, {
            {
                onSelect = function()
                    TriggerEvent('qb-carboosting:client:completeOrder')
                end,
                icon = "fas fa-check",
                label = 'Complete Delivery',
                canInteract = function()
                    return boosting and not inTargetCar and IsVehicleNearPed(dropOffLocation, 10.0)
                end,
                distance = 2.0
            },
        })
    end
end)

-- Event to complete the order
RegisterNetEvent('qb-carboosting:client:completeOrder', function()
    if boosting and not inTargetCar and IsVehicleNearPed(dropOffLocation, 10.0) then
        if currentTier < 3 and trackerActive then
            QBCore.Functions.Notify("You trying to get the feds on me? Get the tracker off that thing and come back.", 'error')
            return
        end

        QBCore.Functions.Notify("Car delivered successfully!")
        print("Delivering car with tier:", currentTier)
        TriggerServerEvent('qb-carboosting:server:carDelivered', currentTier, trackerActive)
        boosting = false
        targetCar = nil
        currentTier = nil
        trackerActive = false
        if spawnedCar then DeleteVehicle(spawnedCar) end
        if dropOffBlip then RemoveBlip(dropOffBlip) end
        if dropOffPed then DeleteEntity(dropOffPed) end
        if dispatchBlip then RemoveBlip(dispatchBlip) end

        -- Start the cooldown
        cooldown = true
        cooldownEndTime = GetGameTimer() + (Config.Delay * 1000)
        LayLowEmail('The cops are still looking for you. Lay low for ' .. Config.Delay .. ' seconds.')
        SetTimeout(Config.Delay * 1000, function()
            cooldown = false
        end)
    else
        QBCore.Functions.Notify("No car in the delivery zone or you are still in the car.", 'error')
    end
end)

-- Main loop to check boosting progress
CreateThread(function()
    while true do
        Wait(0)
        if boosting and targetCar then
            local playerPed = PlayerPedId()

            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
                if vehicleModel == targetCar:lower() then
                    if not inTargetCar then
                        if not notificationShown then
                            QBCore.Functions.Notify("You have stolen the " .. targetCar .. "! Accept the drop-off location via your email.")
                            notificationShown = true
                        end
                        inTargetCar = true

                        -- Select a random drop-off location
                        if not dropOffEmailSent then
                            dropOffLocation = Config.DropOffLocations[math.random(#Config.DropOffLocations)]
                            JobEmail('Yo,<br /><br />Deliver the vehicle to the specified drop-off location. Accept the location on your phone.<br /><br />Location: ' .. dropOffLocation.label, 'qb-carboosting:client:acceptDropOff')
                            dropOffEmailSent = true
                        end

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
    local debugText = string.format("Boosting: %s\nIn Target Car: %s\nTracker Active: %s\nCurrent Tier: %s\nCooldown: %s", tostring(boosting), tostring(inTargetCar), tostring(trackerActive), tostring(currentTier), tostring(cooldown))
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
CreateThread(function()
    while true do
        Wait(30000) -- 30 seconds
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

RegisterNetEvent('qb-carboosting:client:suspiciousActivity', function()
    exports['ps-dispatch']:SuspiciousActivity()
    QBCore.Functions.Notify("Didn't I tell you not to come back?", 'error')
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
