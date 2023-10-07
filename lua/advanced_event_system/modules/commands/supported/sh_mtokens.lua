local function load()
    local MODULE = table.Copy(AEvent.BaseModule)
    MODULE.CategoryID = "Command:mTokens"
    MODULE.Name = "mTokens"

    MODULE:AddCommand({
        ID = "Command:mTokens:AddTokens",
        Name = "add '...' mTokens",
        ExtraSelection = function()
            return {
                {
                    text = "tokens amount",
                    Type = "Int Input",
                    data = {},
                },
            }
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do
                mTokens.AddPlayerTokens(ply, tonumber(data.data[1].selected))
            end
        end,
    })

    AEvent:CreateCommand(MODULE)
end

if mTokens then
    load()
end