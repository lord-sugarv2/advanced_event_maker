function AEvent:OpenMenu()
    if not LocalPlayer() then return end
    if IsValid(self.Frame) then self.Frame:Remove() end
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetTitle("Event System")
    self.Frame:SetSize(ScrW() * .2, ScrH() * .4)
    self.Frame:MakePopup()
    self.Frame:Center()
    self.Frame:SetX(10)
    self.Frame:DockPadding(5, 24 + 3, 5, 5)
    self.Frame.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(0, 0, 0)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end

    local panel = self.Frame:Add("AEvent:Main")
    panel:Dock(FILL)
end
AEvent:OpenMenu()

net.Receive("AEvent:SendEvents", function()
    local int, Events = net.ReadUInt(32), {}
    for i = 1, int do
        local name, id = net.ReadString(), net.ReadString()
        table.Add(Events, {{
            Name = name,
            ID = id,
        }})
    end
    hook.Run("AEvent:UpdateEvents", Events)
end)

net.Receive("AEvent:SendEventDATA", function()
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
    hook.Run("AEvent:ReceivedEvent", id, tbl)

    -- DATA Structure
    --[[
    name	=	hellomiamor
    eventID	=	XHTQ39r8hL
    hooks:
            1:
                    commands:
                            1:
                                    commandID	=	COMMAND:KILL:EVERYONEINEVENT
                                    data:
                            2:
                                    commandID	=	COMMAND:KILL:EVERYONE
                                    data:
                    hookID	=	HOOK:OnEventStarted
            2:
                    commands:
                            1:
                                    commandID	=	COMMAND:BRING:EVERYONEWITHEVENT
                                    data:
                                            Job	=	with prefix in name
                                            Location	=	Home
                                            Selection	=	Home
                    hookID	=	HOOK:OnEventStarted
    ]]--
end)