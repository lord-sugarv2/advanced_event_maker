local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Death"
MODULE.Name = "Death"

MODULE:AddCommand({
    ID = "Command:Death:Kill",
    Name = "kill / slay",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:Kill()
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Death:Respawn",
    Name = "respawn",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:Spawn()
        end
    end,
})

AEvent:CreateCommand(MODULE)