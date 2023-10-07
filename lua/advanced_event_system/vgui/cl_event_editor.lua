local PANEL = {}
function PANEL:Init()
    self.margin = 3
    self.hookPanels = {}
    self.eventID = AEvent:GenerateID(10)

    self.NavBox = self:Add("Panel")
    self.NavBox:Dock(TOP)
    self.NavBox:DockMargin(0, 0, 0, 0)
    self.NavBox:SetTall(AEvent:Scale(25))

    self.EventButton = self.NavBox:Add("AEvent:Button")
    self.EventButton:Dock(LEFT)
    self.EventButton:SetWide(self.EventButton:GetTall())
    self.EventButton:SetText("+")
    self.EventButton.DoClick = function(s)
        local menu = AEvent:DermaMenu()
        for hookID, hookDATA in pairs(AEvent:GetHooks()) do
            menu:AddOption(hookDATA.Name, function()
                self:AddHook(hookDATA.ID)
            end)
        end
        menu:Open()
    end

    self.DeleteButton = self.NavBox:Add("AEvent:Button")
    self.DeleteButton:Dock(RIGHT)
    self.DeleteButton:SetWide(self.DeleteButton:GetTall())
    self.DeleteButton:SetText("✕")
    self.DeleteButton:SetColor(AEvent.Colors["red"])
    self.DeleteButton:SetTextColor(color_white)
    self.DeleteButton.DoClick = function()
        AEvent_Query(
            AEvent:GetPhrase("delete_sure"),
            AEvent:GetPhrase("confirmation"),
            AEvent:GetPhrase("yes"),
            function()
                net.Start("AEvent:RemoveEvent")
                net.WriteString(self.eventID)
                net.SendToServer()

                local parent = self:GetParent()
                self:Remove()

                local Panel = parent:Add("AEvent:Main")
                Panel:Dock(FILL)
            end,
            AEvent:GetPhrase("no"),
            function() end
        )
    end

    self.BackButton = self.NavBox:Add("AEvent:Button")
    self.BackButton.updateSize = true
    self.BackButton:Dock(RIGHT)
    self.BackButton:DockMargin(0, 0, self.margin, 0)
    self.BackButton:SetText(AEvent:GetPhrase("back"))
    self.BackButton.DoClick = function(s)
        local parent = self:GetParent()
        self:Remove()

        local Panel = parent:Add("AEvent:Main")
        Panel:Dock(FILL)
    end

    self.SaveButton = self.NavBox:Add("AEvent:Button")
    self.SaveButton.updateSize = true
    self.SaveButton:Dock(LEFT)
    self.SaveButton:DockMargin(self.margin, 0, 0, 0)
    self.SaveButton:SetText(AEvent:GetPhrase("save"))
    self.SaveButton:SetColor(Color(55, 157, 24))

    self.SaveButton.DoClick = function(s)
        self.StartButton:Show()

        local savedTbl = {}
        for _, v in ipairs(self.hookPanels) do
            table.Add(savedTbl, {{
                hookID = v.hookID,
                commands = v.panel.table,
            }})
        end

        if #savedTbl >= 63 then notification.AddLegacy(AEvent:GetPhrase("hook_limit"), NOTIFY_ERROR, 3) return end

        net.Start("AEvent:SaveEvent")
        net.WriteString(self.eventID)
        net.WriteString(self.NameLabel:GetText())
        net.WriteUInt(#savedTbl, 6)
        for _, v in ipairs(savedTbl) do
            net.WriteString(v.hookID)
            net.WriteUInt(#v.commands, 12) -- if anyone hits this limit then ur doing something wrong lmao
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
        net.SendToServer()
    end

    self.StartButton = self.NavBox:Add("AEvent:Button")
    self.StartButton:Dock(RIGHT)
    self.StartButton.updateSize = true
    self.StartButton:DockMargin(0, 0, self.margin, 0)
    self.StartButton:SetWide(AEvent:Scale(80))
    self.StartButton:SetText("Start")
    self.StartButton:SetColor(AEvent.Colors["green"])
    self.StartButton.DoClick = function(s)
        AEvent_Query(
            AEvent:GetPhrase("sure_start"),
            AEvent:GetPhrase("confirmation"),
            AEvent:GetPhrase("yes"),
            function()
                net.Start("AEvent:StartEvent")
                net.WriteString(self.eventID)
                net.SendToServer()
            end,
            AEvent:GetPhrase("no"),
            function() end
        )
    end

    self.NameLabel = self:Add("AEvent:TextEntry")
    self.NameLabel:Dock(TOP)
    self.NameLabel:SetPlaceholderText(AEvent:GetPhrase("event_name"))
    self.NameLabel:DockMargin(0, self.margin, 0, 0)
    self.NameLabel:SetText("")
    self.NameLabel:SetTall(self.NavBox:GetTall())

    self.Scroll = self:Add("AEvent:ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(0, self.margin, 0, 0)
end

function PANEL:AddHook(hookID)
    local HookPanel = self.Scroll:Add("AEvent:HookPanel")
    HookPanel:Dock(TOP)
    HookPanel:DockMargin(0, 0, self.margin, self.margin)
    HookPanel:SetHookID(hookID)
    HookPanel.RandomID = math.random(1, 1000000)
    HookPanel.DeleteClicked = function(s)
        for int, DATA in ipairs(self.hookPanels) do
            if DATA.id ~= s.RandomID then continue end
            table.remove(self.hookPanels, int)
            break
        end
        s:Remove()
    end

    table.Add(self.hookPanels, {{panel = HookPanel, id = HookPanel.RandomID, hookID = hookID}})
    return HookPanel
end

function PANEL:SetEvent(eventID)
    net.Start("AEvent:RequestEventDATA")
    net.WriteString(eventID)
    net.SendToServer()

    hook.Add("AEvent:ReceivedEvent", "AEvent:ReceivedEvent:Editor", function(id, DATA)
        if not IsValid(self) or id ~= eventID then return end
        self.NameLabel:SetText(DATA.name)
        self.eventID = DATA.eventID
        for _, v in ipairs(DATA.hooks) do
            local panel = self:AddHook(v.hookID)
            for _, commandDATA in ipairs(v.commands) do
                panel:AddCommand(commandDATA)
            end
        end
    end)
end

function PANEL:CreateNew()
    self.CreateNew = true
    self.StartButton:Hide()
end

function PANEL:Paint(w, h)
end
vgui.Register("AEvent:EventEditor", PANEL, "EditablePanel")