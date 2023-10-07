local function load()
    local MODULE = table.Copy(AEvent.BaseModule)
    MODULE.CategoryID = "Command:Voidcases"
    MODULE.Name = "Voidcases"

    MODULE:AddCommand({
        ID = "Command:Voidcases:AddKey",
        Name = "add x'...' item with id '...'",
        ExtraSelection = function()
            return {
                {
                    text = "item amount",
                    Type = "Int Input",
                    data = {},
                },
                {
                    text = "item id",
                    Type = "String Input",
                    data = {},
                },
            }
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do
                VoidCases.AddItem(ply:SteamID64(), data.data[2].selected, tonumber(data.data[1].selected))
            end
        end,
    })

    AEvent:CreateCommand(MODULE)
end

if VoidCases then
    load()
end