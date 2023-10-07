local function load()
    local MODULE = table.Copy(AEvent.BaseModule)
    MODULE.CategoryID = "Command:BricksUnbox"
    MODULE.Name = "Bricks Unbox"

    MODULE:AddCommand({
        ID = "Command:BricksUnbox:AddKey",
        Name = "add x'...' keys with id '...'",
        ExtraSelection = function()
            return {
                {
                    text = "keys amount",
                    Type = "Int Input",
                    data = {},
                },
                {
                    text = "key id",
                    Type = "String Input",
                    data = {},
                },
            }
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do
                ply:AddUnboxingInventoryItem("KEY_"..data.data[2].selected, tonumber(data.data[1].selected))
            end
        end,
    })

    MODULE:AddCommand({
        ID = "Command:BricksUnbox:AddCase",
        Name = "add x'...' cases with id '...'",
        ExtraSelection = function()
            return {
                {
                    text = "case amount",
                    Type = "Int Input",
                    data = {},
                },
                {
                    text = "case id",
                    Type = "String Input",
                    data = {},
                },
            }
        end,
        RunCommand = function(data)
            for _, ply in ipairs(data.players) do
                ply:AddUnboxingInventoryItem( "CASE_" .. data.data[2].selected, tonumber(data.data[1].selected) )
            end
        end,
    })

    AEvent:CreateCommand(MODULE)
end

if BRICKS_SERVER and BRICKS_SERVER.UNBOXING then
    load()
end