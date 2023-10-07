local function load()
    local MODULE = table.Copy(AEvent.BaseModule)
    MODULE.CategoryID = "Command:DarkRP"
    MODULE.Name = "DarkRP"

    MODULE:AddCommand({
        ID = "Command:DarkRP:AddMoney",
        Name = "add $'...' money",
        ExtraSelection = function()
            return {
                {
                    text = "money amount",
                    Type = "Int Input",
                    data = {},
                },
            }
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do                
                ply:addMoney(data.data[1].selected)
            end
        end,
    })

    AEvent:CreateCommand(MODULE)
end

hook.Add("DarkRPFinishedLoading", "AEvent:DarkRPFinishedLoading", function()
    load()
end)

if DarkRP then
    load()
end