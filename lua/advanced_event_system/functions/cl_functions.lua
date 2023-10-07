local scrW = ScrW
local scrH = ScrH
local localplayer = LocalPlayer
local max = math.max
function AEvent:Scale(value)
    return max(value * (scrH() / 1080), 1)
end

function AEvent:FormatCommandPath(targettype, commandID)
    for categoryID, categoryDATA in pairs(AEvent.Commands) do
        for _, commandDATA in pairs(categoryDATA.Commands) do
            if commandDATA.ID == commandID then
                return targettype..": "..commandDATA.Name
            end
        end
    end
    return false
end

AEvent.Fonts = AEvent.Fonts or {}
function AEvent:CreateFont(name, size, bold)
	surface.CreateFont(name, {
        font = bold and "Inter" or "Inter Medium",
		size = AEvent:Scale(size),
		weight = 500,
		extended = false,
    })
    AEvent.Fonts[name] = {size, bold}
end

hook.Add("OnScreenSizeChanged", "AEvent:UpdateFonts", function()
    for fontName, v in pairs(AEvent.Fonts) do
        surface.CreateFont(fontName, {
            font = v[2] and "Inter" or "Inter Medium",
            size = AEvent:Scale(v[1]),
            weight = 500,
            extended = false,
        })
    end
end)

function AEvent:OpenMenu()
    if not localplayer() then return end
    if not AEvent:IsAdmin(localplayer(), true) then notification.AddLegacy(AEvent:GetPhrase("dont_have_rank"), NOTIFY_ERROR, 3) return end
    if IsValid(self.Frame) then self.Frame:Remove() end

    local width, height = AEvent:Scale(500), AEvent:Scale(450)
    self.Frame = vgui.Create("AEvent:Frame")
    self.Frame:SetTitle(AEvent:GetPhrase("addon_name"))
    self.Frame:SetSize(width, height)
    self.Frame:MakePopup()
    self.Frame:Center()

    local Panel = self.Frame:Add("AEvent:Main")
    Panel:Dock(FILL)
end

list.Set(
    "DesktopWindows", 
    "AdvancedEvents",
    {
        title = AEvent:GetPhrase("addon_name"),
        icon = "icon16/plugin.png",
        width = 300,
        height = 170,
        onewindow = false,
        init = function(icn, pnl)
            pnl:Remove()
            AEvent:OpenMenu()
        end
    }
)

concommand.Add("aevent", function()
    -- rank is checked in the OpenMenu
    AEvent:OpenMenu()
end)

net.Receive("AEvent:SendEvents", function()
    local isActive = net.ReadBool()
    local int, Events = net.ReadUInt(32), {}
    for i = 1, int do
        local name, id = net.ReadString(), net.ReadString()
        table.Add(Events, {{
            Name = name,
            ID = id,
        }})
    end
    hook.Run("AEvent:SaveEvents", isActive, Events)
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

net.Receive("AEvent:Notify", function()
    local msgType, seconds, msg = net.ReadUInt(3), net.ReadUInt(6), net.ReadString()
    notification.AddLegacy(msg, msgType, seconds)
end)

concommand.Add("print_aevent", function()
    print("{{ script_id }}; {{ user_id }}")
end)

AEvent:CreateFont("AEvent:MegaLarge", 67)

net.Receive("AEvent:ScreenCountdown", function()
    local time = net.ReadUInt(32)
    table.Add(AEvent.Timers, {{
        time = time + CurTime(),
    }})
end)

net.Receive("AEvent:EventStopped", function()
    AEvent.Timers = {}
    AEvent.KillBoxes = {}
end)

hook.Add("HUDPaint", "AEvent:DrawHud", function()
    local seventy = AEvent:Scale(70)
    local screenWidth, screenHeight = scrW(), scrH()
    local y = screenHeight*.1
    local currentTime = CurTime()
    for int, v in ipairs(AEvent.Timers) do
        local time = v.time-currentTime
        if time < 0 then table.remove(AEvent.Timers, int) continue end
        local niceTime = math.max(math.Round(v.time-currentTime), 0).."s"
        draw.SimpleText(niceTime, "AEvent:MegaLarge", screenWidth/2 + 2, y + 2, color_black, 1, 0)
        draw.SimpleText(niceTime, "AEvent:MegaLarge", screenWidth/2, y, color_white, 1, 0)
        y = y + seventy
    end
end)

-- killbox
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

local color_red = AEvent.Colors["red"]
local color_red_two = Color(AEvent.Colors["red"].r, AEvent.Colors["red"].g, AEvent.Colors["red"].b, 20)
hook.Add("PostDrawTranslucentRenderables", "AEvent:DrawKillBoxes", function()
    if #AEvent.KillBoxes < 1 then return end
    for _, v in ipairs(AEvent.KillBoxes) do
        AEvent:DrawBox(v.cornerOne, v.cornerTwo, color_red_two)
        AEvent:WireframeBox(v.cornerOne, v.cornerTwo, color_red)
    end
end)

-- popups
net.Receive("AEvent:JoinPopup", function()
    if IsValid(AEvent.JoinPopup) then AEvent.JoinPopup:Remove() end

    local enable = net.ReadBool()
    if not enable then return end

    local w, h = AEvent:Scale(350), AEvent:Scale(100)
    AEvent.JoinPopup = vgui.Create("AEvent:Frame")
    AEvent.JoinPopup:SetSize(w, h)
    AEvent.JoinPopup:SetPos((ScrW()/2) - (w/2), AEvent:Scale(20))
    AEvent.JoinPopup:SetTitle("")
    AEvent.JoinPopup.CloseButton:Remove()

    local old = AEvent.JoinPopup.PerformLayout
    local h2 = AEvent:Scale(25)
    AEvent.JoinPopup.PerformLayout = function(s, w, h)
        old(s, w, h)

        local margin = AEvent:Scale(10)
        local w2 = w*.35
        AEvent.JoinPopup.Yes:SetPos((w/2)-(w2)-(margin/2), h/2)
        AEvent.JoinPopup.Yes:SetSize(w2, h2)

        AEvent.JoinPopup.No:SetPos((w/2)+margin, h/2)
        AEvent.JoinPopup.No:SetSize(w2, h2)

        AEvent.JoinPopup.Label:SetPos((w/2) - (AEvent.JoinPopup.Label:GetWide()/2), margin)
    end

    AEvent.JoinPopup.Label = AEvent.JoinPopup:Add("DLabel")
    AEvent.JoinPopup.Label:SetText("Would u like to join the event?")
    AEvent.JoinPopup.Label:SetFont("AEvent:18")
    AEvent.JoinPopup.Label:SizeToContents()

    AEvent.JoinPopup.Yes = AEvent.JoinPopup:Add("AEvent:Button")
    AEvent.JoinPopup.Yes:SetText(AEvent:GetPhrase("yes"))
    AEvent.JoinPopup.Yes.DoClick = function()
        net.Start("AEvent:JoinEvent")
        net.WriteBool(true)
        net.SendToServer()

        AEvent.JoinPopup:Remove()
    end

    AEvent.JoinPopup.No = AEvent.JoinPopup:Add("AEvent:Button")
    AEvent.JoinPopup.No:SetText(AEvent:GetPhrase("no"))
    AEvent.JoinPopup.No.DoClick = function()
        net.Start("AEvent:JoinEvent")
        net.WriteBool(false)
        net.SendToServer()
    
        AEvent.JoinPopup:Remove()
    end
end)