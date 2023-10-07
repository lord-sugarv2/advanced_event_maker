AEvent.currentEvent = AEvent.currentEvent or {}
AEvent.currentEvent.players = AEvent.currentEvent.players or {}
function AEvent:StartEvent(id)
    AEvent:StopEvent(true)

	local data = AEvent:GetEvent(id)
    data = AEvent:GetEvent(id)
    if not data then print("[ AEVENT ] "..string.format(AEvent:GetPhrase("id_dosnt_exist"), id)) return AEvent:GetPhrase("bad_id") end

    AEvent.currentEvent = data
	AEvent.currentEvent.players = AEvent.currentEvent.players or {}
	AEvent.currentEvent.isActive = true

    hook.Run("HOOK:OnEventStarted", AEvent:GetHooksFromDATA("HOOK:OnEventStarted", data))
	return AEvent:GetPhrase("successfully_started")
end

function AEvent:StopEvent(safe)
    hook.Run("AEvent:EventStopped")

	if not safe then
	    hook.Run("HOOK:OnEventEnded", AEvent:GetHooksFromDATA("HOOK:OnEventEnded", AEvent.currentEvent))
	else
		for id, v in pairs(AEvent.Props or {}) do
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
	end

	for _, ply in ipairs(player.GetAll()) do
		ply.AEventCanJoin = false

		print("ENDED")
		net.Start("AEvent:JoinPopup")
        net.WriteBool(false) -- enable it: false removes it
        net.Send(ply)
	end
end

function AEvent:AddPlayerToEvent(ply)
	ply.AEventCanJoin = false
	
	net.Start("AEvent:JoinPopup")
	net.WriteBool(false) -- enable it: false removes it
	net.Send(ply)

	AEvent.currentEvent.players[ply] = true
end

function AEvent:RemovePlayerFromEvent(ply)
	AEvent.currentEvent.players[ply] = nil
end

function AEvent:GetPlayersInEvent()
	local players = {}
	for ply, bool in pairs(AEvent.currentEvent.players) do
		if not IsValid(ply) or not bool then continue end
		table.insert(players, ply)
	end
    return players
end

function AEvent:IsInEvent(ply)
	return AEvent.currentEvent.players[ply]
end

util.AddNetworkString("AEvent:StopEvent")
net.Receive("AEvent:StopEvent", function(len, ply)
	if not AEvent:IsAdmin(ply) then return end

	AEvent:StopEvent()
	AEvent:Notify(ply, 0, 3, AEvent:GetPhrase("success"))
end)