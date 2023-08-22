local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:KillBox"
MODULE.Name = "Kill Box"

local function FormatPresets()
    local tbl = {}
    for _, v in ipairs(AEvent.Presets) do
        if v.type ~= "Kill Box" then continue end
        table.Add(tbl, {{
            Text = v.name,
            Data = {BoxID = v.id},
        }})
    end
    return tbl
end

MODULE:AddCommand({
    ID = "Command:KillBox:EnableKillBox",
    Name = "enable kill box '...'",
    ExtraSelection = function()
        return FormatPresets()
    end,
    RunCommand = function(data)
        local preset = AEvent:GetPreset(data.BoxID)
        if not preset then print("[ AEvent ] KILL BOX "..data.name.." IS BROKEN PLEASE FIX THE COMMAND OR REMOVE")return end

        AEvent:OnEnterArea(preset.cornerOne, preset.cornerTwo, function(ply)
            ply:Kill()
        end, "KillBox:"..data.BoxID)

        net.Start("AEvent:ViewKillBox")
        net.WriteBool(true)
        net.WriteString(data.BoxID)
        net.WriteVector(preset.cornerOne)
        net.WriteVector(preset.cornerTwo)
        net.Send(AEvent:GetPlayersInEvent())
    end,
})

MODULE:AddCommand({
    ID = "Command:KillBox:DisableKillBox",
    Name = "disable kill box '...'",
    ExtraSelection = function()
        return FormatPresets()
    end,
    RunCommand = function(data)
        AEvent:RemoveArea("KillBox:"..data.BoxID)

        net.Start("AEvent:ViewKillBox")
        net.WriteBool(false)
        net.WriteString(data.BoxID)
        net.WriteVector(preset.cornerOne)
        net.WriteVector(preset.cornerTwo)
        net.Send(AEvent:GetPlayersInEvent())
    end,
})

AEvent:CreateCommand(MODULE)

if SERVER then
    util.AddNetworkString("AEvent:ViewKillBox")
else
    AEvent.KillBoxes = AEvent.KillBoxes or {}
    net.Receive("AEvent:ViewKillBox", function()
        local view = net.ReadBool()
        local id = net.ReadString()

        if view then
            local cornerOne, cornerTwo = net.ReadVector(), net.ReadVector()
            table.Add(AEvent.KillBoxes, {{id = id, cornerOne = cornerOne, cornerTwo = cornerTwo}})
            return
        end
    
        for int, v in ipairs(AEvent.KillBoxes) do
            table.remove(AEvent.KillBoxes, int)
        end
    end)

    local color_red = Color(255, 100, 100)
    local color_red_two = Color(255, 100, 100, 20)
    hook.Add("PostDrawTranslucentRenderables", "AEvent:DrawKillBoxes", function()
        if #AEvent.KillBoxes < 1 then return end
        for _, v in ipairs(AEvent.KillBoxes) do
            AEvent:DrawBox(v.cornerOne, v.cornerTwo, color_red_two)
            AEvent:WireframeBox(v.cornerOne, v.cornerTwo, color_red)
        end
    end)
end