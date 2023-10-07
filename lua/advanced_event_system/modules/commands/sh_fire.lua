local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Fire"
MODULE.Name = "Fire"

MODULE:AddCommand({
    ID = "Command:Fire:SetFire",
    Name = "set on fire for '...'s",
    ExtraSelection = function()
        return {
            {
                text = "seconds",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:Ignite(data.data[1].selected)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Fire:Extinguish",
    Name = "extinguish fire",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:Extinguish()
        end
    end,
})

AEvent:CreateCommand(MODULE)