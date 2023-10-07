local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Health"
MODULE.Name = "Health"

MODULE:AddCommand({
    ID = "Command:Health:AddHealth",
    Name = "add '...' health",
    ExtraSelection = function()
        return {
            {
                text = "health amount",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:SetHealth(ply:Health() + data.data[1].selected)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Health:SetHealth",
    Name = "set health to '...'",
    ExtraSelection = function()
        return {
            {
                text = "health amount",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:SetHealth(data.data[1].selected)
        end
    end,
})

AEvent:CreateCommand(MODULE)