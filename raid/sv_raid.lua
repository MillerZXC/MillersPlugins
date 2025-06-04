local PLUGIN = PLUGIN

-- Network strings
util.AddNetworkString("ixRaidStart")
util.AddNetworkString("ixRaidEnd")
util.AddNetworkString("ixRaidOpenMenu")
util.AddNetworkString("ixRaidAssist")

-- Variables
local activeRaid = nil
local assistingFactions = {}

-- Function to end raid
local function EndRaid()
    if activeRaid then
        -- Announce raid end
        ix.chat.Send(nil, "raid", "The raid has ended!")
        
        -- Send raid end to all clients
        net.Start("ixRaidEnd")
        net.Broadcast()
        
        -- Clear active raid and assisting factions
        activeRaid = nil
        assistingFactions = {}
        
        -- Remove the timer if it exists
        if timer.Exists("ixRaidTimer") then
            timer.Remove("ixRaidTimer")
        end
    end
end

-- Start raid
net.Receive("ixRaidStart", function(len, ply)
    if not IsValid(ply) then return end
    
    local targetfaction = net.ReadString()
    local planet = net.ReadString()
    local raidfaction = net.ReadString()
    
    local char = ply:GetCharacter()

    local faction = ix.faction.Get(char:GetFaction())
    if not PLUGIN.config.allowedFactions[faction.name] then
        ply:Notify("Your faction is not allowed to raid!")
        return
    end
    
    -- Check if there's already an active raid
    if activeRaid then
        ply:Notify("There is already an active raid!")
        return
    end

    for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(0, 0, 255), "[RAID] ", Color(255,255,255), "]]..raidfaction..[[ is raiding ]]..targetfaction..[[ on ]]..planet..[[")]])
	end
    
    -- Start the raid
    activeRaid = {
        faction = faction,
        planet = planet,
        startTime = CurTime(),
        endTime = CurTime() + PLUGIN.config.raidDuration
    }
    
    -- Send raid start to all clients
    net.Start("ixRaidStart")
        net.WriteString(faction.name)
        net.WriteString(planet)
    net.Broadcast()
    
    -- Set up raid end timer
    timer.Create("ixRaidTimer", PLUGIN.config.raidDuration, 1, function()
        EndRaid()
    end)
end)

-- Chat command
ix.command.Add("raid", {
    description = "Open the raid menu",
    OnRun = function(self, ply)
        if not IsValid(ply) then return end
        
        -- Check if player's faction is allowed to raid
        local char = ply:GetCharacter()
        if not char then return end
        
        local faction = ix.faction.Get(char:GetFaction())
        if not PLUGIN.config.allowedFactions[faction.name] then
            ply:Notify("Your faction is not allowed to raid!")
            return
        end
        
        -- Open raid menu
        net.Start("ixRaidOpenMenu")
        net.Send(ply)
    end
})

-- Stop raid command
ix.command.Add("stopraid", {
    description = "Stop the current raid (Superadmin only)",
    superAdminOnly = true,
    OnRun = function(self, ply)
        if not IsValid(ply) then return end
        
        if not activeRaid then
            ply:Notify("There is no active raid to stop!")
            return
        end
        
        EndRaid()
        ply:Notify("You have stopped the raid!")
    end
})

-- Raid assist command
ix.command.Add("assist", {
    description = "Join an ongoing raid as an assisting faction",
    OnRun = function(self, ply)
        if not IsValid(ply) then return end
        
        -- Check if player's faction is allowed to raid
        local char = ply:GetCharacter()
        if not char then return end
        
        local faction = ix.faction.Get(char:GetFaction())
        if not PLUGIN.config.allowedFactions[faction.name] then
            ply:Notify("Your faction is not allowed to assist in raids!")
            return
        end
        
        -- Check if there's an active raid
        if not activeRaid then
            ply:Notify("There is no active raid to assist!")
            return
        end
        
        -- Check if faction is already assisting
        if assistingFactions[faction.name] then
            ply:Notify("Your faction is already assisting in this raid!")
            return
        end
        
        -- Add faction to assisting factions
        assistingFactions[faction.name] = true
        
        -- Announce faction joining the raid
        for k,v in pairs(player.GetAll()) do
            v:SendLua([[chat.AddText(Color(0, 0, 255), "[RAID] ", Color(255,255,255), "]]..faction.name..[[ is assisting the raid!")]])
        end
    end
}) 