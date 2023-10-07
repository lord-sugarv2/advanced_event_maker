local function load()
    local MODULE = table.Copy(AEvent.BaseModule)
    MODULE.CategoryID = "Command:BricksCredits"
    MODULE.Name = "Bricks Credit Store"

    MODULE:AddCommand({
        ID = "Command:BricksCredits:AddCredits",
        Name = "add '...' bricks credits",
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
                ply:AddBRCS_Credits(tonumber(data.data[1].selected))
            end
        end,
    })

    AEvent:CreateCommand(MODULE)
end

if BRICKSCREDITSTORE then
    load()
end