Config = {}

-- Bools
Config.Debug = false -- Debug this will increase the resource ms.

Config.Target = 'ox' -- can be 'ox' = ox_target / 'qb' = qb-target
Config.PhoneScript = 'qb-phone' -- Options: qb-phone, gksphone

Config.PedModel = 'a_m_m_bevhills_02' -- ped to interact with
Config.CarSearchRadius = 100.0 -- Radius on map
Config.Delay = 600 -- Delay in seconds

Config.CarTiers = {
    [1] = {'adder', 'zentorno', 't20'},
    [2] = {'dominator', 'gauntlet', 'f620'},
    [3] = {'panto', 'blista', 'dilettante'}
}

-- Rewards
Config.Rewards = {
    [1] = {
        full = {
            money = {2000, 2500, 3000},
            items = {'weapon_combatpistol', 'pistol_ammo'}
        },
        penalty = {
            money = {1000, 1250, 1500}
        }
    },
    [2] = {
        full = {
            money = {1000, 1500, 2000},
            items = {'pistol_ammo', 'hak_kit'}
        },
        penalty = {
            money = {500, 750, 950}
        }
    },
    [3] = {
        money = {500, 750, 1000}
    }
}

-- Locations
Config.PedLocation = {x = 1129.99, y = -989.16, z = 45.97, heading = 96.08}

Config.SpawnLocations = {
    vector3(-2480.9, -212.0, 17.4),
    vector3(-2723.4, 13.2, 15.1),
    vector3(-3169.6, 976.2, 15.0),
    vector3(-3139.8, 1078.7, 20.2),
    vector3(-1656.9, -246.2, 54.5),
    vector3(-1586.7, -647.6, 29.4),
    vector3(-1036.1, -491.1, 36.2),
    vector3(-1029.2, -475.5, 36.4),
    vector3(75.2, 164.9, 104.7),
    vector3(-534.6, -756.7, 31.6),
    vector3(487.2, -30.8, 88.9),
    vector3(-772.2, -1281.8, 4.6),
    vector3(-663.8, -1207.0, 10.2),
    vector3(719.1, -767.8, 24.9),
    vector3(-971.0, -2410.4, 13.3),
    vector3(-1067.5, -2571.4, 13.2),
    vector3(-619.2, -2207.3, 5.6),
    vector3(1192.1, -1336.9, 35.1),
    vector3(-432.8, -2166.1, 9.9),
    vector3(-451.8, -2269.3, 7.2),
    vector3(939.3, -2197.5, 30.5),
    vector3(-556.1, -1794.7, 22.0),
    vector3(591.7, -2628.2, 5.6),
    vector3(1654.5, -2535.8, 74.5),
    vector3(1642.6, -2413.3, 93.1),
    vector3(1371.3, -2549.5, 47.6),
    vector3(383.8, -1652.9, 37.3),
    vector3(27.2, -1030.9, 29.4),
    vector3(229.3, -365.9, 43.8),
    vector3(-85.8, -51.7, 61.1),
    vector3(-4.6, -670.3, 31.9),
    vector3(-111.9, 92.0, 71.1),
    vector3(-314.3, -698.2, 32.5),
    vector3(-366.9, 115.5, 65.6),
    vector3(-592.1, 138.2, 60.1),
    vector3(-1613.9, 18.8, 61.8),
    vector3(-1709.8, 55.1, 65.7),
    vector3(-521.9, -266.8, 34.9),
    vector3(-451.1, -333.5, 34.0),
    vector3(322.4, -1900.5, 25.8)
}

Config.DropOffLocations = {
    {x= 56.82, y = 160.78, z = 104.73, heading = 250.3, label = "Location"}
}

Config.PedBlip = {
    Sprite = 280,
    Color = 1,
    Scale = 0.8,
    Text = "Car Boosting"
}

Config.PoliceAlertChance = {
    [1] = 90, -- 90% chance of police alert for Tier 1
    [2] = 60, -- 60% chance of police alert for Tier 2
    [3] = 30  -- 30% chance of police alert for Tier 3
}

