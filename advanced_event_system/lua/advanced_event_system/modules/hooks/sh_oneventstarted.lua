local MODULE = {}
MODULE.ID = "HOOK:OnEventStarted" -- THIS MUST BE UNIQUE
MODULE.Name = "when the event starts" -- Nice text that gets displayed to represent the ID

hook.Add("HOOK:OnEventStarted", "HOOK:OnEventStarted", function(data)
    for _, v in ipairs(data) do
        AEvent:RunCommands(v.commands)
    end
end)

AEvent:CreateHook(MODULE)