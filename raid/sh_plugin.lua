PLUGIN.name = "Raid System"
PLUGIN.author = "Miller"
PLUGIN.desc = "A system for organizing faction raids"

-- Configuration
PLUGIN.config = PLUGIN.config or {}
PLUGIN.config.raidDuration = 1800 -- 30 minutes in seconds
PLUGIN.config.allowedFactions = {
    ["Гражданский союз рабочих"] = true,
    ["Hutt syndicate"] = true,
    ["Empire"] = true,
    ["Rebel Alliance"] = true,
    ["Jedi Order"] = true,
    ["Sith Empire"] = true,
    ["New Republic"] = true,
    ["Galactic Republic"] = true,    
}

-- Available planets for raiding
PLUGIN.config.planets = {
    ["tatooine"] = "Tatooine",
    ["naboo"] = "Naboo",
    ["dantooine"] = "Dantooine"
}

-- Shared functions
function PLUGIN:IsFactionAllowed(faction)
    return self.config.allowedFactions[faction] or false
end

function PLUGIN:GetPlanetName(planetID)
    return self.config.planets[planetID] or "Unknown"
end 

ix.util.Include("cl_raid.lua")
ix.util.Include("sv_raid.lua")