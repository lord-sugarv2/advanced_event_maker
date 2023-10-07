local function FormatPresets()
    local tbl = {}
    for _, v in ipairs(AEvent.Presets or {}) do
        if v.type ~= "Props" then continue end
        table.Add(tbl, {{
            text = v.name,
            data = {props = v.id},
        }})
    end
    return tbl
end

local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Props"
MODULE.Name = "Kill Box"

MODULE:AddCommand({
    ID = "Command:Props:Enable",
    Name = "spawn props with name: '...'",
    IsOther = true,
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
        local boxID = data.data[1].props
        local preset = AEvent:GetPreset(boxID)
        if not preset then print("[ AEvent ] 'PROP BOX "..data.name.."' "..AEvent:GetPhrase("broken_command")) return end

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
    ID = "Command:Props:Disable",
    Name = "delete props with name: '...'",
    IsOther = true,
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
        local boxID = data.data[1].props
        local preset = AEvent:GetPreset(boxID)
        if not preset then print("[ AEvent ] 'PROP BOX "..data.name.."' "..AEvent:GetPhrase("broken_command")) return end

        for _, ent in ipairs(AEvent.Props[preset.id] or {}) do
            if not IsValid(ent) then continue end
            ent:Remove()
        end
        AEvent.Props[preset.id] = {}
    end,
})

AEvent:CreateCommand(MODULE)