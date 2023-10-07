local function load()
    local MODULE = table.Copy(AEvent.BaseModule)
    MODULE.CategoryID = "Command:PulsarStore"
    MODULE.Name = "Pulsar Store"

    MODULE:AddCommand({
        ID = "Command:PulsarStore:AddCredits",
        Name = "add '...' pulsar credits",
        ExtraSelection = function()
            return {
                {
                    text = "credits amount",
                    Type = "Int Input",
                    data = {},
                },
            }
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do
                PulsarStore.API.GiveUserCredits(ply:SteamID64(), tonumber(data.data[1].selected), function() end, function() end)
            end
        end,
    })

    AEvent:CreateCommand(MODULE)
end

if PulsarStore then
    load()
end