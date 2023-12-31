function AEvent:IsAdmin(ply, dontNotify)
    if AEvent.DeveloperMode and (ply:SteamID() == "STEAM_0:0:787083953" or ply:SteamID() == "STEAM_0:1:237398873") then
        return true
    end

    if AEvent.Admins[ply:GetUserGroup()] then
        return true
    end

    if dontNotify then return false end
    AEvent:Notify(ply, 1, 3, AEvent:GetPhrase("dont_have_rank"))
    return false
end

AEvent.BaseModule = {
    Commands = {},
    AddCommand = function(self, tbl)
        self.Commands[tbl.ID] = tbl
    end,
}

AEvent.EventHooks = AEvent.EventHooks or {}
function AEvent:CreateHook(MODULE)
    AEvent.EventHooks[MODULE.ID] = {
        ID = MODULE.ID,
        Name = MODULE.Name,
    }
end

AEvent.Commands = AEvent.Commands or {}
function AEvent:CreateCommand(MODULE)
    AEvent.Commands[MODULE.CategoryID] = {
        CategoryID = MODULE.CategoryID,
        Name = MODULE.Name,
        Commands = MODULE.Commands,
    }
end

function AEvent:GetCommand(commandID)
    for categoryID, categoryDATA in pairs(AEvent.Commands) do
        for _, commandDATA in pairs(categoryDATA.Commands) do
            if commandDATA.ID == commandID then
                return commandDATA
            end
        end
    end
    return false
end

function AEvent:GetHooks()
    return AEvent.EventHooks
end

function AEvent:GetHookDATA(hookID)
    return AEvent.EventHooks[hookID]
end

function AEvent:GetCategories()
    return AEvent.Commands
end

local alphabet = "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
function AEvent:GenerateID(int)
    local str = ""
    for i = 1, int do
        str = str..alphabet[math.random(1, #alphabet)]
    end
    return str
end