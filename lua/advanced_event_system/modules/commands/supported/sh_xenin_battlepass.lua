local function load()
    local MODULE = table.Copy(AEvent.BaseModule)
    MODULE.CategoryID = "Command:XeninBP"
    MODULE.Name = "Xenin BattlePass"

    MODULE:AddCommand({
        ID = "Command:XeninBP:AddBattlePass",
        Name = "give battlepass",
        ExtraSelection = function()
            return false
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do
                BATTLEPASS:SetOwned(ply, true)
            end
        end,
    })

    MODULE:AddCommand({
        ID = "Command:XeninBP:AddBattlePass",
        Name = "add '...' battlepass tiers",
        ExtraSelection = function()
            return {
                {
                    text = "tiers amount",
                    Type = "Int Input",
                    data = {},
                },
            }
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do
                BATTLEPASS:AddTier(ply, data.data[1].selected)
            end
        end,
    })

    AEvent:CreateCommand(MODULE)
end

if BATTLEPASS then
    load()
end