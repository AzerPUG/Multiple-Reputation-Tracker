if AZP == nil then AZP = {} end
if AZP.MultipleReputationTracker == nil then AZP.MultipleReputationTracker = {} end

AZP.MultipleReputationTracker.RepBarsConfig =
{
    ["checkFactionIDs"] = {}
}



AZP.MultipleReputationTracker.StandardNames =
{
    [1] = { Name =      "Hated",},
    [2] = { Name =    "Hostile",},
    [3] = { Name = "Unfriendly",},
    [4] = { Name =    "Neutral",},
    [5] = { Name =   "Friendly",},
    [6] = { Name =    "Honored",},
    [7] = { Name =    "Revered",},
    [8] = { Name =    "Exalted",},
    [9] = { Name =    "Paragon",},
}

AZP.MultipleReputationTracker.ReputationTypes =
{
    [1] =
    {

        [1] = {Name =          "N/A", Reputation =  0,},
        [2] = {Name =          "N/A", Reputation =  0,},
        [3] = {Name =      "Dubious", Reputation =  1000,},
        [4] = {Name = "Apprehensive", Reputation =  6000,},
        [5] = {Name =    "Tentative", Reputation =  7000,},
        [6] = {Name =   "Ambivalent", Reputation =  7000,},
        [7] = {Name =      "Cordial", Reputation = 21000,},
        [8] = {Name = "Appreciative", Reputation =   nil,},
        [9] = {Name =    "Paragon",},
    },
    [2] =
    {
        [1] = {Name =    "N/A", Reputation =  0,},
        [2] = {Name =    "N/A", Reputation =  0,},
        [3] = {Name = "Tier 1", Reputation =  3000,},
        [4] = {Name = "Tier 2", Reputation =  4500,},
        [5] = {Name = "Tier 3", Reputation =  6500,},
        [6] = {Name = "Tier 4", Reputation = 11000,},
        [7] = {Name = "Tier 5", Reputation = 16000,},
        [8] = {Name = "Tier 6", Reputation =   nil,},
        [9] = {Name =    "Paragon",},
    },
    [3] =
    {
        [1] = {Name =              "N/A", Reputation =  0,},
        [2] = {Name =        "Whelpling", Reputation = 1000,},
        [3] = {Name = "Temporal Trainee", Reputation = 1500,},
        [4] = {Name =       "Timehopper", Reputation = 2000,},
        [5] = {Name =    "Chrono-Friend", Reputation = 2500,},
        [6] = {Name =      "Bronze Ally", Reputation = 3000,},
        [7] = {Name =     "Epoch-Mender", Reputation = 5000,},
        [8] = {Name =         "Timelord", Reputation =  nil,},
    }
}

AZP.MultipleReputationTracker.Factions =
{
    -- Guild
    [1168] = {Name =                 "Guild", Paragon = false, OffSet = 0,},

    -- Shadowlands
    [2407] = {Name =          "The Ascended", Paragon =  true, OffSet = 0,},
    [2472] = {Name = "The Archivists' Codex", Paragon =  true, OffSet = 2, Type = 2},
    [2470] = {Name =       "Death's Advance", Paragon =  true, OffSet = 0,},
    [2464] = {Name =        "Court of Night", Paragon = false, OffSet = 3,},
    [2413] = {Name =   "Court of Harvesters", Paragon =  true, OffSet = 0,},
    [2439] = {Name =            "The Avowed", Paragon = false, OffSet = 1,},
    [2410] = {Name =      "The Undying Army", Paragon =  true, OffSet = 0,},
    [2465] = {Name =         "The Wild Hunt", Paragon =  true, OffSet = 0,},
    [2432] = {Name =                "Venari", Paragon =  true, OffSet = 2, Type = 1},

    -- Battle for Azeroth
    [2159] = {Name =            "7th Legion", Paragon =  true, OffSet = 0,},
    [2164] = {Name =  "Champions of Azeroth", Paragon =  true, OffSet = 0,},
    [2395] = {Name =        "Honeyback Hive", Paragon = false, OffSet = 0,},
    [2161] = {Name =       "Order of Embers", Paragon =  true, OffSet = 0,},
    [2160] = {Name = "Proudmoore Admirality", Paragon =  true, OffSet = 0,},
    [2415] = {Name =                "Rajani", Paragon =  true, OffSet = 0,},
    [2391] = {Name =   "Rustbolt Resistance", Paragon =  true, OffSet = 0,},
    [2162] = {Name =          "Storm's Wake", Paragon =  true, OffSet = 0,},
    [2163] = {Name =     "Tortollan Seekers", Paragon =  true, OffSet = 0,},
    [2417] = {Name =          "Uldum Accord", Paragon =  true, OffSet = 0,},
    [1948] = {Name =      "Waveblade Ankoan", Paragon =  true, OffSet = 0,},

    -- Legion
    [2135] = {Name =               "Chromie", Paragon = false, OffSet = 0, Type = 3},
    [1900] = {Name =     "Court of Farondis", Paragon =  true, OffSet = 0,},
    [1883] = {Name =          "Dreamweavers", Paragon =  true, OffSet = 0,},
    [1828] = {Name =    "Highmountain Tribe", Paragon =  true, OffSet = 0,},
    [1894] = {Name =           "The Wardens", Paragon =  true, OffSet = 0,},
    [2400] = {Name =              "Valarjar", Paragon =  true, OffSet = 0,},

    -- Warlords of Draenor
    [0] = {Name =       "Council of Exarchs", Paragon = false, OffSet = 0,},
}
