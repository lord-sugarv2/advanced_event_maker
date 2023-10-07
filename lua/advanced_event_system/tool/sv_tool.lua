util.AddNetworkString("AEvent:Tool:CreatePreset")
util.AddNetworkString("AEvent:Tool:NetworkID")
net.Receive("AEvent:Tool:CreatePreset", function(len, ply)
    if not AEvent:IsAdmin(ply) then return end
    AEvent:Notify(ply, 0, 3, AEvent:GetPhrase("success"))

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

        local tbl = {
            name = name,
            type = selected,
            props = props,
            id = id,
        }
        AEvent:SavePreset(id, tbl)
    elseif selected == "Kill Box" then
        local cornerOne, cornerTwo = net.ReadVector(), net.ReadVector()

        local tbl = {
            name = name,
            type = selected,
            cornerOne = cornerOne,
            cornerTwo = cornerTwo,
            id = id
        }
        AEvent:SavePreset(id, tbl)
    elseif selected == "Box" then
        local cornerOne, cornerTwo = net.ReadVector(), net.ReadVector()

        local tbl = {
            name = name,
            type = selected,
            cornerOne = cornerOne,
            cornerTwo = cornerTwo,
            id = id
        }
        AEvent:SavePreset(id, tbl)
    end

    net.Start("AEvent:Tool:NetworkID")
    net.WriteBool(false)
    net.WriteUInt(1, 12)
    net.WriteString(name)
    net.WriteString(selected)
    net.WriteString(id)
    net.Broadcast()
end)

util.AddNetworkString("AEvent:Tool:RequestPresets")
net.Receive("AEvent:Tool:RequestPresets", function(len, ply)
    if ply.AEventReceived then return end
    ply.AEventReceived = true

    local data = AEvent:GetAllPresets(id)
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
    if not AEvent:IsAdmin(ply) then return end
    AEvent:Notify(ply, 0, 3, AEvent:GetPhrase("success"))

    local isDelete = net.ReadBool()
    local id = net.ReadString()

    if isDelete then
        AEvent:DeletePreset(id)

        net.Start("AEvent:Tool:NetworkID")
        net.WriteBool(true)
        net.WriteString(id)
        net.Broadcast()

        return
    end

    // rename instead
    local text = net.ReadString()
    AEvent:RenamePreset(id, text)

    net.Start("AEvent:Tool:NetworkID")
    net.WriteBool(true)
    net.WriteString(id)
    net.Broadcast()

    local data = AEvent:GetPreset(id)
    net.Start("AEvent:Tool:NetworkID")
    net.WriteBool(false)
    net.WriteUInt(1, 12)
    net.WriteString(data.name)
    net.WriteString(data.type)
    net.WriteString(data.id)
    net.Broadcast()
end)