Config = {}

Config.DropOffLocation = {x = 1119.01, y = -992.14, z = 46.01}

Config.CarTiers = {
    [1] = {"ENTITYXF", "T20", "OSIRIS"},
    [2] = {"FELTZER3", "SCHAFTER3", "F620"},
    [3] = {"ASEA", "DILETTANTE", "PRIMO"}
}

Config.Rewards = {
    [1] = {2000, 2500, 3000}, -- Possible rewards for Tier 1
    [2] = {1000, 1500, 2000}, -- Possible rewards for Tier 2
    [3] = {500, 750, 1000}    -- Possible rewards for Tier 3
}

Config.PoliceAlertChance = {
    [1] = 90, -- 90% chance of police alert for Tier 1
    [2] = 60, -- 60% chance of police alert for Tier 2
    [3] = 30  -- 30% chance of police alert for Tier 3
}

Config.PedLocation = {x = 1129.99, y = -989.16, z = 45.97, heading = 96.08}
Config.PedModel = 'a_m_m_bevhills_02'
Config.PedBlip = {
    Sprite = 280,
    Color = 1,
    Scale = 0.8,
    Text = "Car Boosting"
}

Config.Debug = true
Config.CarSearchRadius = 100.0
