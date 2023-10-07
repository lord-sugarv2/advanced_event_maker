local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:God"
MODULE.Name = "God"

MODULE:AddCommand({
    ID = "Command:God:God",
    Name = "god",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:GodEnable()
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:God:Ungod",
    Name = "ungod",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:GodDisable()
        end
    end,
})

AEvent:CreateCommand(MODULE)