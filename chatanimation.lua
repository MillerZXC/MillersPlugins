local PLUGIN = PLUGIN

PLUGIN.name = "Chat Animation"
PLUGIN.description = "Sets the player animation when someone typing."
PLUGIN.author = "Miller&Акулка"

-----CONFIG-------
local anim = "f_texting" -- Sets the animation that plays when you open chat
local endanimenabled = false -- enable/disable animation when closing chat
local animend = "f_cry" --Closing animation
------------------

local function CustomTypingAnimation(ply)
    if IsValid(ply) and ply:IsPlayer() then
        ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_CUSTOM, ply:LookupSequence( anim ), 0, false )
    end
end

local function CustomTypingAnimationEnd(ply)
    if IsValid(ply) and ply:IsPlayer() then
        if endanimenabled then
            ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_CUSTOM, ply:LookupSequence( animend ), 0, true )
        else
            ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
        end
    end
end

hook.Add("StartChat", "CustomTypingAnimationStart", function(teamChat)
    local ply = LocalPlayer()
    CustomTypingAnimation(ply)
end)

hook.Add("FinishChat", "CustomTypingAnimationFinish", function()
	local ply = LocalPlayer()
	CustomTypingAnimationEnd(ply)
end)