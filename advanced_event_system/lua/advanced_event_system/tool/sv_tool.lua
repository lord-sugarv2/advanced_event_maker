util.AddNetworkString("AEvent:Tool:CreatePreset")
util.AddNetworkString("AEvent:Tool:NetworkID")
net.Receive("AEvent:Tool:CreatePreset", function(len, ply)
    local name, selected = net.ReadString(), net.ReadString()
    local id = AEvent:GenerateID(20)
    if selected == "Props" then
        local int, props = net.ReadUInt(32), {}
        for i = 1, int do
            local ent = net.ReadEntity()
            if not IsValid(ent) then continue end

            table.Add(props, {{
                class = ent:GetClass(), -- future support
                model = ent:GetModel(),
                col = ent:GetColor(),
                collisionGroup = ent:GetCollisionGroup(),
                pos = ent:GetPos(),
                angle = ent:GetAngles(),
                material = ent:GetMaterial(),
            }})
        end

        local data = file.Read("aevent_presets.txt") and util.JSONToTable(file.Read("aevent_presets.txt")) or {}
        table.Add(data, {{
            name = name,
            type = selected,
            props = props,
            id = id
        }})
        file.Write("aevent_presets.txt", util.TableToJSON(data, true))
    elseif selected == "Kill Box" then
        local cornerOne, cornerTwo = net.ReadVector(), net.ReadVector()

        local data = file.Read("aevent_presets.txt") and util.JSONToTable(file.Read("aevent_presets.txt")) or {}
        table.Add(data, {{
            name = name,
            type = selected,
            cornerOne = cornerOne,
            cornerTwo = cornerTwo,
            id = id
        }})
        file.Write("aevent_presets.txt", util.TableToJSON(data, true))
    elseif selected == "Box" then
        local cornerOne, cornerTwo = net.ReadVector(), net.ReadVector()

        local data = file.Read("aevent_presets.txt") and util.JSONToTable(file.Read("aevent_presets.txt")) or {}
        table.Add(data, {{
            name = name,
            type = selected,
            cornerOne = cornerOne,
            cornerTwo = cornerTwo,
            id = id
        }})
        file.Write("aevent_presets.txt", util.TableToJSON(data, true))
    end

    net.Start("AEvent:Tool:NetworkID")
    net.WriteBool(false)
    net.WriteUInt(1, 12)
    net.WriteString(name)
    net.WriteString(selected)
    net.WriteString(id)
    net.Send(ply)
end)

util.AddNetworkString("AEvent:Tool:RequestPresets")
net.Receive("AEvent:Tool:RequestPresets", function(len, ply)
    if ply.AEventReceived then return end
    ply.AEventReceived = true

    local data = file.Read("aevent_presets.txt") and util.JSONToTable(file.Read("aevent_presets.txt")) or {}
    net.Start("AEvent:Tool:NetworkID")
    net.WriteBool(false)
    net.WriteUInt(#data, 12)
    for _, v in ipairs(data) do
        net.WriteString(v.name)
        net.WriteString(v.type)
        net.WriteString(v.id)
    end
    net.Send(ply)
end)

util.AddNetworkString("AEvent:PresetOption")
net.Receive("AEvent:PresetOption", function(len, ply)
    local isDelete = net.ReadBool()
    local id = net.ReadString()

    if isDelete then
        local data = file.Read("aevent_presets.txt") and util.JSONToTable(file.Read("aevent_presets.txt")) or {}
        for int, v in ipairs(data) do
            if v.id ~= id then continue end
            table.remove(data, int)
            break
        end
        file.Write("aevent_presets.txt", util.TableToJSON(data, true))

        net.Start("AEvent:Tool:NetworkID")
        net.WriteBool(true)
        net.WriteString(id)
        net.Send(ply)

        return
    end

    // rename instead
    local text = net.ReadString()

    local data = file.Read("aevent_presets.txt") and util.JSONToTable(file.Read("aevent_presets.txt")) or {}
    local yesInt = 0
    for int, v in ipairs(data) do
        if v.id ~= id then continue end
        data[int].name = text
        yesInt = int
        break
    end
    file.Write("aevent_presets.txt", util.TableToJSON(data, true))

    if yesInt == 0 then return end

    net.Start("AEvent:Tool:NetworkID")
    net.WriteBool(true)
    net.WriteString(id)
    net.Send(ply)

    net.Start("AEvent:Tool:NetworkID")
    net.WriteBool(false)
    net.WriteUInt(1, 12)
    net.WriteString(data[yesInt].name)
    net.WriteString(data[yesInt].type)
    net.WriteString(data[yesInt].id)
    net.Send(ply)
end)

function AEvent:GetPreset(id)
    local data = file.Read("aevent_presets.txt") and util.JSONToTable(file.Read("aevent_presets.txt")) or {}
    for _, v in ipairs(data) do
        if v.id ~= id then continue end
        return v
    end
    return false
end