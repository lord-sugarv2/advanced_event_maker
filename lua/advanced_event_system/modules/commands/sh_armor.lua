local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Armor"
MODULE.Name = "Armor"

MODULE:AddCommand({
    ID = "Command:Armor:AddArmor",
    Name = "add '...' armor",
    ExtraSelection = function()
        return {
            {
                text = "armor amount",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:SetArmor(ply:Armor() + data.data[1].selected)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Armor:SetArmor",
    Name = "set armor to '...'",
    ExtraSelection = function()
        return {
            {
                text = "armor amount",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:SetArmor(data.data[1].selected)
        end
    end,
})

AEvent:CreateCommand(MODULE)