local function suitablePos(Pos)
    local Ents = ents.FindInBox(Pos + Vector( -16, -16, 0 ), Pos + Vector(16, 16, 72))

    local blockers = 0
    for _, v in ipairs(Ents) do
        if v:IsPlayer() and not v:Alive() then continue end
        blockers = blockers + 1
    end

    return blockers < 1 and true or false
end

local function RandomPointBetweenPoints(point1, point2)
    for i = 1, 100 do
        local randomX = math.random() * (point2.x - point1.x) + point1.x
        local randomY = math.random() * (point2.y - point1.y) + point1.y
        local randomZ = math.random() * (point2.z - point1.z) + point1.z
        local pos = Vector(randomX, randomY, randomZ)
        if suitablePos(pos) then
            return pos
        end
    end

    local randomX = math.random() * (point2.x - point1.x) + point1.x
    local randomY = math.random() * (point2.y - point1.y) + point1.y
    local randomZ = math.random() * (point2.z - point1.z) + point1.z
    local pos = Vector(randomX, randomY, randomZ)
    return pos
end

local function FormatPresets()
    local tbl = {}
    for _, v in ipairs(AEvent.Presets or {}) do
        if v.type ~= "Box" then continue end
        table.Add(tbl, {{
            text = v.name,
            data = {boxID = v.id},
        }})
    end
    return tbl
end

local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Bring"
MODULE.Name = "Bring"

MODULE:AddCommand({
    ID = "Command:Bring:BringToBox",
    Name = "bring to '...'",
    ExtraSelection = function()
        return {
            {
                text = "",
                Type = "Combo Input",
                Options = FormatPresets(),
                data = {},
            },
        }
    end,
    RunCommand = function(data, callback)
        local boxID = data.data[1].boxID
        local preset = AEvent:GetPreset(boxID)
        if not preset then print("[ AEvent ] 'PROP BOX "..data.name.."' "..AEvent:GetPhrase("broken_command")) return end

        for _, ply in ipairs(data.players) do
            local pos = RandomPointBetweenPoints(preset.cornerOne, preset.cornerTwo)
            ply:SetPos(pos)
        end
    end,
})

AEvent:CreateCommand(MODULE)