local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Bring"
MODULE.Name = "Bring"

local function FormatPresets()
    local tbl = {}
    for _, v in ipairs(AEvent.Presets) do
        if v.type ~= "Box" then continue end
        table.Add(tbl, {{
            Text = v.name,
            Data = {PresetID = v.id},
        }})
    end
    return tbl
end

local function RandomPointBetweenPoints(point1, point2)
    local randomX = math.random() * (point2.x - point1.x) + point1.x
    local randomY = math.random() * (point2.y - point1.y) + point1.y
    local randomZ = math.random() * (point2.z - point1.z) + point1.z
    return Vector(randomX, randomY, randomZ)
end

MODULE:AddCommand({
    ID = "Command:Bring:InEvent",
    Name = "everyone in the event to '...'",
    ExtraSelection = function()
        return FormatPresets()
    end,
    RunCommand = function(data)
        local preset = AEvent:GetPreset(data.PresetID)
        if not preset then print("[ AEvent ] TP BOX "..data.name.." IS BROKEN PLEASE FIX THE COMMAND OR REMOVE")return end
        for _, ply in ipairs(AEvent:GetPlayersInEvent()) do
            ply:SetPos(RandomPointBetweenPoints(preset.cornerOne, preset.cornerTwo))
            ply:DropToFloor()
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Bring:CausedTrigger",
    Name = "the person who caused this trigger to happen to '...'",
    ExtraSelection = function()
        return FormatPresets()
    end,
    RunCommand = function(data)
        if not IsValid(data.playerSupplied) then return end

        local preset = AEvent:GetPreset(data.PresetID)
        if not preset then print("[ AEvent ] TP BOX "..data.name.." IS BROKEN PLEASE FIX THE COMMAND OR REMOVE")return end
        data.playerSupplied:SetPos(RandomPointBetweenPoints(preset.cornerOne, preset.cornerTwo))
        data.playerSupplied:DropToFloor()
    end,
})

AEvent:CreateCommand(MODULE)