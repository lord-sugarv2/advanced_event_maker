local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Props"
MODULE.Name = "Props"

local function FormatPresets()
    local tbl = {}
    for _, v in ipairs(AEvent.Presets) do
        if v.type ~= "Props" then continue end
        table.Add(tbl, {{
            Text = v.name,
            Data = {BoxID = v.id},
        }})
    end
    return tbl
end

AEvent.Props = AEvent.Props or {}

MODULE:AddCommand({
    ID = "Command:Props:EnableProps",
    Name = "spawn props from preset '...'",
    ExtraSelection = function()
        return FormatPresets()
    end,
    RunCommand = function(data)
        local preset = AEvent:GetPreset(data.BoxID)
        if not preset then print("[ AEvent ] PROP BOX "..data.name.." IS BROKEN PLEASE FIX THE COMMAND OR REMOVE") return end

        for _, ent in ipairs(AEvent.Props[preset.id] or {}) do
            if not IsValid(ent) then continue end
            ent:Remove()
        end

        AEvent.Props[preset.id] = {}
        for _, v in ipairs(preset.props) do
            local ent = ents.Create(v.class)
            ent:SetModel(v.model)
            ent:Spawn()
            ent:SetMaterial(v.Material)
            ent:SetPos(v.pos)
            ent:SetCollisionGroup(v.collisionGroup)
            ent:SetColor(v.col)
            ent:SetAngles(v.angle)
            ent:SetMoveType(MOVETYPE_NONE)

            table.insert(AEvent.Props[preset.id], ent)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Props:DisableProps",
    Name = "remove props from preset '...'",
    ExtraSelection = function()
        return FormatPresets()
    end,
    RunCommand = function(data)
        local preset = AEvent:GetPreset(data.BoxID)
        if not preset then print("[ AEvent ] PROP BOX "..data.name.." IS BROKEN PLEASE FIX THE COMMAND OR REMOVE") return end

        for _, ent in ipairs(AEvent.Props[preset.id] or {}) do
            if not IsValid(ent) then continue end
            ent:Remove()
        end
        AEvent.Props[preset.id] = {}
    end,
})

AEvent:CreateCommand(MODULE)