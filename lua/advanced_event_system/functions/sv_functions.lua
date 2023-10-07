resource.AddSingleFile("resource/fonts/Inter-Bold.ttf")
resource.AddSingleFile("resource/fonts/Inter-Medium.ttf")

util.AddNetworkString("AEvent:Notify")
function AEvent:Notify(ply, msgType, seconds, msg)
    net.Start("AEvent:Notify")
    net.WriteUInt(msgType, 3)
    net.WriteUInt(seconds, 6)
    net.WriteString(msg)
    net.Send(ply)
end

function AEvent:RunCommandSet(commands, ply)
    local tbl = table.Copy(commands)
    for _, v in ipairs(commands) do
        local tempV = table.Copy(v)
        -- PrintTable(v) looks like so with 4 textbox inputs
        --[[
            commandID	=	Command:God
            data:
                    1:
                            data:
                                    selected	=	hehehehe
                    2:
                            data:
                                    selected	=	awd
                    3:
                            data:
                                    selected	=	123
                    4:
                            data:
                                    selected	=	te
                    targetType	=	target_name
        ]]--

        local command = AEvent:GetCommand(tempV.commandID)
        if not command then print("[ AEvent ] '"..tempV.commandID.."'"..AEvent:GetPhrase("broken_command")) continue end

        tempV.players = {}
        if ply and tempV.data.targetType == "target_trigger" then
            table.insert(tempV.players, ply)
        end
    
        -- aids ik but its neccassary to make the commands easier for you <3
        local targetType = tempV.data.targetType
        tempV.data.targetType = nil
        if targetType == "target_everyone" then
            for _, ply in ipairs(player.GetAll()) do
                table.insert(tempV.players, ply)
            end
        elseif targetType == "target_name" then
            for _, ply in ipairs(player.GetAll()) do
                local start, startEnd = string.find(string.lower(ply:Nick()), string.lower(tempV.data[1].data.selected))
                if start then
                    table.insert(tempV.players, ply)
                end
            end
            table.remove(tempV.data, 1)
        elseif targetType == "target_team" then
            for _, ply in ipairs(player.GetAll()) do
                if string.lower(team.GetName(ply:Team())) == string.lower(tempV.data[1].data.selected) then
                    table.insert(tempV.players, ply)
                end
            end
            table.remove(tempV.data, 1)
        elseif targetType == "target_everyone_event" then
            for _, ply in ipairs(player.GetAll()) do
                if AEvent:IsInEvent(ply) then
                    table.insert(tempV.players, ply)
                end 
            end
        elseif targetType == "target_name_event" then
            for _, ply in ipairs(player.GetAll()) do
                local start, startEnd = string.find(string.lower(ply:Nick()), string.lower(tempV.data[1].data.selected))
                if AEvent:IsInEvent(ply) and start then
                    table.insert(tempV.players, ply)
                end
            end
            table.remove(tempV.data, 1)
        elseif targetType == "target_team_event" then
            for _, ply in ipairs(player.GetAll()) do
                if AEvent:IsInEvent(ply) and string.lower(team.GetName(ply:Team())) == string.lower(tempV.data[1].data.selected) then
                    table.insert(tempV.players, ply)
                end
            end
            table.remove(tempV.data, 1)
        elseif targetType == "other" then
            -- target everyone
            for _, ply in ipairs(player.GetAll()) do
                table.insert(tempV.players, ply)
            end
        elseif targetType == "target_usergroup_event" then
            for _, ply in ipairs(player.GetAll()) do
                if AEvent:IsInEvent(ply) and ply:GetUserGroup() == tempV.data[1].data.selected then
                    table.insert(tempV.players, ply)
                end
            end
            table.remove(tempV.data, 1)
        elseif targetType == "target_usergroup" then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetUserGroup() == tempV.data[1].data.selected then
                    table.insert(tempV.players, ply)
                end
            end
            table.remove(tempV.data, 1)
        end

        if command.IsTimer then
            local temp = {data = {}}
            for _, v in ipairs(tempV.data) do
                table.Add(temp.data, {v.data})
            end
            temp.players = tempV.players

            command.RunCommand(temp, function()
                table.remove(tbl, 1)
                AEvent:RunCommandSet(tbl)
            end)
            break
        end
    
        table.remove(tbl, 1)

        // format the table nice for the commands
        local temp = {data = {}}
        for _, v in ipairs(tempV.data) do
            table.Add(temp.data, {v.data})
        end
        temp.players = tempV.players
        command.RunCommand(temp)
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

util.AddNetworkString("AEvent:SaveEvent")
net.Receive("AEvent:SaveEvent", function(len, ply)
    if not AEvent:IsAdmin(ply) then return end
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
            local commandID = net.ReadString()
            local temp = {
                targetType = net.ReadString(),
            }

            local dataInt = net.ReadUInt(12)
            for i = 1, dataInt do
                local index = net.ReadUInt(12)
                temp[index] = temp[index] or {data = {}}

                local valueInt = net.ReadUInt(12)
                for i = 1, valueInt do
                    local id = net.ReadString()
                    local dataType = net.ReadUInt(3)
                    if dataType == 1 then
                        temp[index].data[id] = net.ReadUInt(32)
                    elseif dataType == 2 then
                        temp[index].data[id] = net.ReadString()
                    elseif dataType == 3 then
                        temp[index].data[id] = net.ReadVector()
                    elseif dataType == 4 then
                        temp[index].data[id] = net.ReadBool()
                    end
                end
            end

            table.Add(tbl.hooks[tblINT].commands, {{
                commandID = commandID,
                data = temp,
            }})
        end
    end

    AEvent:SaveEvent(id, tbl)
    AEvent:Notify(ply, 0, 3, AEvent:GetPhrase("success"))
end)

util.AddNetworkString("AEvent:RequestEvents")
util.AddNetworkString("AEvent:SendEvents")
net.Receive("AEvent:RequestEvents", function(len, ply)
    if not AEvent:IsAdmin(ply) then return end

    local data = AEvent:GetAllEvents()
    net.Start("AEvent:SendEvents")
    net.WriteBool(AEvent.currentEvent and AEvent.currentEvent.isActive or false)
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
    if not AEvent:IsAdmin(ply) then return end

    local id = net.ReadString()
    local DATA = AEvent:GetEvent(id)
    if not DATA then return end

    net.Start("AEvent:SendEventDATA")
    net.WriteString(DATA.eventID)
    net.WriteString(DATA.name)
    net.WriteUInt(#DATA.hooks, 6)
    for _, v in ipairs(DATA.hooks) do
        net.WriteString(v.hookID)
        net.WriteUInt(#v.commands, 12)
        for _, commandDATA in ipairs(v.commands) do
            local commandCopy = table.Copy(commandDATA) -- some weird gmod behaviour changing the origional table
            net.WriteString(commandCopy.commandID)
            net.WriteString(commandCopy.data.targetType)
            commandCopy.data.targetType = nil

            net.WriteUInt(#commandCopy.data, 12)
            for index, data in ipairs(commandCopy.data) do
                net.WriteUInt(index, 12)
                net.WriteUInt(table.Count(data.data), 12)
                for dataId, dataValue in pairs(data.data) do
                    local valueType = type(dataValue)
                    valueType = valueType == "number" and 1 or valueType
                    valueType = valueType == "string" and 2 or valueType
                    valueType = valueType == "Vector" and 3 or valueType
                    valueType = valueType == "boolean" and 4 or valueType

                    net.WriteString(dataId)
                    net.WriteUInt(valueType, 3)
                    if valueType == 1 then
                        net.WriteUInt(dataValue, 32)
                    elseif valueType == 2 then
                        net.WriteString(dataValue)
                    elseif valueType == 3 then
                        net.WriteVector(dataValue)
                    elseif valueType == 4 then
                        net.WriteBool(dataValue)
                    end
                end
            end
        end
    end
    net.Send(ply)
end)

util.AddNetworkString("AEvent:RemoveEvent")
net.Receive("AEvent:RemoveEvent", function(len, ply)
    if not AEvent:IsAdmin(ply) then return end

    local id = net.ReadString()
    AEvent:RemoveEvent(id)

    AEvent:Notify(ply, 0, 3, AEvent:GetPhrase("success"))
end)

util.AddNetworkString("AEvent:StartEvent")
net.Receive("AEvent:StartEvent", function(len, ply)
    if not AEvent:IsAdmin(ply) then return end

    local id = net.ReadString()
    AEvent:StartEvent(id)

    AEvent:Notify(ply, 0, 3, AEvent:GetPhrase("success"))
end)

-- timers
util.AddNetworkString("AEvent:ScreenCountdown")
util.AddNetworkString("AEvent:EventStopped")
hook.Add("AEvent:EventStopped", "AEvent:EventStopped", function()
    for _, v in ipairs(AEvent.Timers) do
        timer.Remove(v)
    end

    AEvent.Timers = {}

    net.Start("AEvent:EventStopped")
    net.Broadcast()
end)

-- killbox
util.AddNetworkString("AEvent:ViewKillBox")

-- popups
util.AddNetworkString("AEvent:JoinPopup")
util.AddNetworkString("AEvent:JoinEvent")
net.Receive("AEvent:JoinEvent", function(len, ply)
    if not ply.AEventCanJoin then return end

    local bool = net.ReadBool()
    ply.AEventCanJoin = false

    if bool then
        AEvent:AddPlayerToEvent(ply)
        hook.Run("HOOK:OnJoinedEvent", AEvent:GetHooksFromDATA("HOOK:OnJoinedEvent", AEvent.currentEvent), ply)
    end
end)