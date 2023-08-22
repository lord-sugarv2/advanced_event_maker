function AEvent:RunCommands(commands, ply)
    local tbl = table.Copy(commands)
    for _, v in ipairs(commands) do
        local command = AEvent:GetCommand(v.commandID)
        if command.IsTimer then
            command.RunCommand(v.data, function()
                table.remove(tbl, 1)
                AEvent:RunCommands(tbl)
            end)
            break
        end

        table.remove(tbl, 1)
        v.data.playerSupplied = ply
        command.RunCommand(v.data)
    end
end

function AEvent:GetHooksFromDATA(hookID, data)
    local tbl = {}
    for _, v in ipairs(data.hooks or {}) do
        if v.hookID == hookID then
            table.Add(tbl, {v})
        end
    end
    return tbl
end

function AEvent:GetEvents(id)
    local data = file.Read("AEvent_Events.txt") and util.JSONToTable(file.Read("AEvent_Events.txt")) or {}
    for index, v in ipairs(data) do
        if v.eventID == id then
            return v
        end
    end
    return false
end

util.AddNetworkString("AEvent:SaveEvent")
net.Receive("AEvent:SaveEvent", function(len, ply)
    local id, name, int = net.ReadString(), net.ReadString(), net.ReadUInt(6)
    local tbl = {
        eventID = id,
        name = name,
        hooks = {},
    }

    for hookINT = 1, int do
        local hookID, commandsInt = net.ReadString(), net.ReadUInt(12)
        local tblINT = #tbl.hooks+1
        tbl.hooks[tblINT] = {
            hookID = hookID,
            commands = {},
        }

        for i = 1, commandsInt do
            local commandID, commandDATA = net.ReadString(), net.ReadTable()
            table.Add(tbl.hooks[tblINT].commands, {{
                commandID = commandID,
                data = commandDATA,
            }})
        end
    end

    local data = file.Read("AEvent_Events.txt") and util.JSONToTable(file.Read("AEvent_Events.txt")) or {}
    for index, v in ipairs(data) do
        if v.eventID == id then
            table.remove(data, index)
        end
    end
    table.Add(data, {tbl})

    file.Write("AEvent_Events.txt", util.TableToJSON(data, true))
end)

util.AddNetworkString("AEvent:RequestEvents")
util.AddNetworkString("AEvent:SendEvents")
net.Receive("AEvent:RequestEvents", function(len, ply)
    local data = file.Read("AEvent_Events.txt") and util.JSONToTable(file.Read("AEvent_Events.txt")) or {}
    net.Start("AEvent:SendEvents")
    net.WriteUInt(#data, 32)
    for _, v in ipairs(data) do
        net.WriteString(v.name)
        net.WriteString(v.eventID)
    end
    net.Send(ply)
end)

util.AddNetworkString("AEvent:RequestEventDATA")
util.AddNetworkString("AEvent:SendEventDATA")
net.Receive("AEvent:RequestEventDATA", function(len, ply)
    local id = net.ReadString()
    local DATA = AEvent:GetEvents(id)
    if not DATA then return end

    net.Start("AEvent:SendEventDATA")
    net.WriteString(DATA.eventID)
    net.WriteString(DATA.name)
    net.WriteUInt(#DATA.hooks, 6)
    for _, v in ipairs(DATA.hooks) do
        net.WriteString(v.hookID)
        net.WriteUInt(#v.commands, 12)
        for _, commandDATA in ipairs(v.commands) do
            net.WriteString(commandDATA.commandID)
            net.WriteTable(commandDATA.data or {})
        end
    end
    net.Send(ply)
end)

util.AddNetworkString("AEvent:RemoveEvent")
net.Receive("AEvent:RemoveEvent", function(len, ply)
    local id = net.ReadString()

    local data = file.Read("AEvent_Events.txt") and util.JSONToTable(file.Read("AEvent_Events.txt")) or {}
    for index, v in ipairs(data) do
        if v.eventID == id then
            table.remove(data, index)
        end
    end
    table.Add(data, {tbl})

    file.Write("AEvent_Events.txt", util.TableToJSON(data, true))
end)

util.AddNetworkString("AEvent:StartEvent")
net.Receive("AEvent:StartEvent", function(len, ply)
    local id = net.ReadString()
    AEvent:StartEvent(id)
end)