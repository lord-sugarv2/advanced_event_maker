local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Playermodel"
MODULE.Name = "Playermodel"

MODULE:AddCommand({
    ID = "Command:Playermodel:SetModelScale",
    Name = "set scale to '...'",
    ExtraSelection = function()
        return {
            {
                text = "model scale",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:SetScale(data.data[1].selected)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Playermodel:SetModel",
    Name = "set model to '...'",
    ExtraSelection = function()
        return {
            {
                text = "model class",
                Type = "String Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:SetModel(data.data[1].selected)
        end
    end,
})

AEvent:CreateCommand(MODULE)