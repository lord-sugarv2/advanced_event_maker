local MODULE = {}
MODULE.ID = "HOOK:OnEventEnded" -- THIS MUST BE UNIQUE
MODULE.Name = "When the event ends" -- Nice text that gets displayed to represent the ID

hook.Add("HOOK:OnEventEnded", "HOOK:OnEventEnded", function(data)
    for _, v in ipairs(data) do
        AEvent:RunCommandSet(v.commands)
    end

    for id, v in pairs(AEvent.Props) do
		for _, ent in ipairs(v) do
			if not IsValid(ent) then continue end
			ent:Remove()
		end
	end

	for _, ply in ipairs(AEvent:GetPlayersInEvent()) do
		if not ply or not IsValid(ply) then continue end
		AEvent:RemovePlayerFromEvent(ply)
	end

    AEvent.currentEvent = {}
	AEvent.currentEvent.players = {}

	AEvent.Props = {}
	AEvent:ClearAllAreas()
end)

AEvent:CreateHook(MODULE)