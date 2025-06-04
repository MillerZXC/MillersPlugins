local PLUGIN = PLUGIN

-- Variables
local raidTimer = 0
local isRaidActive = false

-- Create the raid menu
function PLUGIN:CreateRaidMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    frame:SetTitle("Raid Menu")
    frame:MakePopup()

    local factionList = vgui.Create("DComboBox", frame)
    factionList:SetPos(20, 40)
    factionList:SetSize(360, 30)
    factionList:SetValue("Select Faction")

    -- Add allowed factions to the list
    for faction, _ in pairs(PLUGIN.config.allowedFactions) do
        factionList:AddChoice(faction)
    end

    local planetList = vgui.Create("DComboBox", frame)
    planetList:SetPos(20, 80)
    planetList:SetSize(360, 30)
    planetList:SetValue("Select Planet")

    -- Add planets to the list
    for planetID, planetName in pairs(PLUGIN.config.planets) do
        planetList:AddChoice(planetName, planetID)
    end

    local confirmButton = vgui.Create("DButton", frame)
    confirmButton:SetPos(20, 120)
    confirmButton:SetSize(360, 30)
    confirmButton:SetText("Confirm Raid")
    confirmButton.DoClick = function()
        local selectedFaction = factionList:GetSelected()
        local selectedPlanet = planetList:GetSelected()
        local char = LocalPlayer():GetCharacter()
        local faction = ix.faction.Get(char:GetFaction())
        
        if selectedFaction and selectedPlanet then
            net.Start("ixRaidStart")
                net.WriteString(selectedFaction)
                net.WriteString(selectedPlanet)
                net.WriteString(faction.name)
            net.SendToServer()
            frame:Close()
        else
            LocalPlayer():Notify("Please select both a faction and a planet!")
        end
    end
end

-- HUD Paint for raid timer
hook.Add("HUDPaint", "ixRaidTimer", function()
    if isRaidActive then
        local timeLeft = math.max(0, raidTimer - CurTime())
        if timeLeft > 0 then
            draw.SimpleText(
                string.format("Raid Time Remaining: %02d:%02d", math.floor(timeLeft / 60), math.floor(timeLeft % 60)),
                "ixBigFont",
                ScrW() * 0.5,
                50,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end
    end
end)

-- Network receivers
net.Receive("ixRaidStart", function()
    local faction = net.ReadString()
    local planet = net.ReadString()
    raidTimer = CurTime() + PLUGIN.config.raidDuration
    isRaidActive = true
end)

net.Receive("ixRaidEnd", function()
    isRaidActive = false
end)

net.Receive("ixRaidOpenMenu", function()
    PLUGIN:CreateRaidMenu()
end)

-- Chat command
concommand.Add("raid", function()
    PLUGIN:CreateRaidMenu()
end) 