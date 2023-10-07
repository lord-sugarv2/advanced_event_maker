local MODULE = {}
MODULE.ID = "HOOK:OnJoinedEvent" -- THIS MUST BE UNIQUE
MODULE.Name = "When a player joins the event through popup" -- Nice text that gets displayed to represent the ID

hook.Add("HOOK:OnJoinedEvent", "HOOK:OnJoinedEvent", function(data, ply)
    for _, v in ipairs(data) do
        AEvent:RunCommandSet(v.commands, ply)
    end
end)

AEvent:CreateHook(MODULE)