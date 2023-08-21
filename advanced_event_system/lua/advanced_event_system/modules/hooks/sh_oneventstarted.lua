local MODULE = {}
MODULE.ID = "HOOK:OnEventStarted" -- THIS MUST BE UNIQUE
MODULE.Name = "when the event starts" -- Nice text that gets displayed to represent the ID

AEvent:CreateHook(MODULE)