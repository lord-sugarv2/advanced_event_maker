local MODULE = {}
MODULE.ID = "HOOK:OnEventEnded" -- THIS MUST BE UNIQUE
MODULE.Name = "when the event ends" -- Nice text that gets displayed to represent the ID

hook.Add("HOOK:OnEventEnded", "HOOK:OnEventEnded", function(data)
    for _, v in ipairs(data) do
        AEvent:RunCommands(v.commands)
    end
end)

AEvent:CreateHook(MODULE)