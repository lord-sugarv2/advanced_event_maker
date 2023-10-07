local function FormatPresets()
    local tbl = {}
    for _, v in ipairs(AEvent.Presets or {}) do
        if v.type ~= "Kill Box" then continue end
        table.Add(tbl, {{
            text = v.name,
            data = {boxID = v.id},
        }})
    end
    return tbl
end

AEvent.Timers = AEvent.Timers or {}

local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:KillBox"
MODULE.Name = "Kill Box"

MODULE:AddCommand({
    ID = "Command:KillBox:Enable",
    Name = "enable killbox with name: '...'",
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
        local boxID = data.data[1].boxID
        local preset = AEvent:GetPreset(boxID)
        if not preset then print("[ AEvent ] 'KILL BOX "..data.name.."' "..AEvent:GetPhrase("broken_command"))return end

        AEvent:OnEnterArea(preset.cornerOne, preset.cornerTwo, function(ply)
            ply:Kill()
        end, "KillBox:"..boxID)

        net.Start("AEvent:ViewKillBox")
        net.WriteBool(true)
        net.WriteString(boxID)
        net.WriteVector(preset.cornerOne)
        net.WriteVector(preset.cornerTwo)
        net.Send(data.players)
    end,
})

MODULE:AddCommand({
    ID = "Command:KillBox:Disable",
    Name = "disable killbox with name: '...'",
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
        local boxID = data.data[1].boxID
        AEvent:RemoveArea("KillBox:"..boxID)

        net.Start("AEvent:ViewKillBox")
        net.WriteBool(false)
        net.WriteString(boxID)
        net.Send(data.players)
    end,
})

AEvent:CreateCommand(MODULE)