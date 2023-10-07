local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Freeze"
MODULE.Name = "Freeze"

MODULE:AddCommand({
    ID = "Command:Freeze:Freeze",
    Name = "freeze",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:Freeze(true)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Freeze:UnFreeze",
    Name = "unfreeze",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:Freeze(false)
        end
    end,
})

AEvent:CreateCommand(MODULE)