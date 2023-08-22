-- DATA Structure
--[[
eventID	=	tVhCgUQ8W1
hooks:
		1:
				commands:
						1:
								commandID	=	Command:Timers:SilentCountdown
								data:
										Selection	=	10
						2:
								commandID	=	Command:Player:KillAll
								data:
						3:
								commandID	=	Command:Timers:ScreenCount
								data:
										Selection	=	2
				hookID	=	HOOK:OnEventStarted
name	=	awdwad
]]--

AEvent.CurrentEvent = AEvent.CurrentEvent or {}
function AEvent:StartEvent(id)
    AEvent:StopEvent(true)

    local data = file.Read("AEvent_Events.txt") and util.JSONToTable(file.Read("AEvent_Events.txt")) or {}
    data = AEvent:GetEvents(id)
    if not data then print("[ AEVENT ] ID: "..id.." dosnt exist!") return "BAD ID" end

    AEvent.CurrentEvent = data
	AEvent.CurrentEvent.IsActive = true
    hook.Run("HOOK:OnEventStarted", AEvent:GetHooksFromDATA("HOOK:OnEventStarted", data))
	return "Successfully started!"
end

function AEvent:StopEvent(safe)
    hook.Run("AEvent:EventStopped")

	for id, v in pairs(AEvent.Props) do
		for _, ent in ipairs(v) do
			if not IsValid(ent) then continue end
			ent:Remove()
		end
	end

	AEvent.CurrentEvent = {}
	AEvent.Props = {}
	AEvent:ClearAll()

    if safe then return end
    hook.Run("HOOK:OnEventEnded", AEvent:GetHooksFromDATA("HOOK:OnEventEnded", AEvent.CurrentEvent))
end

function AEvent:AddPlayerToEvent(ply)
end

function AEvent:RemovePlayerFromEvent(ply)
end

function AEvent:GetPlayersInEvent()
    local players = player.GetAll()
    return players
end

function AEvent:IsInEvent()
	return true
end