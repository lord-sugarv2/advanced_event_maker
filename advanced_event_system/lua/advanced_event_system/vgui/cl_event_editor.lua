local PANEL = {}
function PANEL:Init()
    self.margin = 3
    self.hookPanels = {}
    self.eventID = AEvent:GenerateID(10)

    self.NavBox = self:Add("Panel")
    self.NavBox:Dock(TOP)
    self.NavBox:DockMargin(self.margin, self.margin, self.margin, 0)

    self.EventButton = self.NavBox:Add("AEvent:Button")
    self.EventButton:Dock(LEFT)
    self.EventButton:SetWide(self.EventButton:GetTall())
    self.EventButton:SetText("+")
    self.EventButton.DoClick = function(s)
        local menu = DermaMenu()
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
    self.DeleteButton:SetColor(Color(255, 100, 100))
    self.DeleteButton:SetTextColor(color_white)
    self.DeleteButton.DoClick = function()
        Derma_Query(
            "Are you sure you want to delete this?",
            "Confirmation:",
            "Yes",
            function()
                net.Start("AEvent:RemoveEvent")
                net.WriteString(self.eventID)
                net.SendToServer()
                AEvent.Frame:Remove()
            end,
            "No",
            function() end
        )
    end

    self.BackButton = self.NavBox:Add("AEvent:Button")
    self.BackButton:Dock(RIGHT)
    self.BackButton:DockMargin(0, 0, self.margin, 0)
    self.BackButton:SetWide(80)
    self.BackButton:SetText("BACK")
    self.BackButton.DoClick = function(s)
        local parent = self:GetParent()
        self:Remove()

        local panel = parent:Add("AEvent:Main")
        panel:Dock(FILL)
    end

    self.SaveButton = self.NavBox:Add("AEvent:Button")
    self.SaveButton:Dock(LEFT)
    self.SaveButton:DockMargin(self.margin, 0, 0, 0)
    self.SaveButton:SetWide(80)
    self.SaveButton:SetText("Save")
    self.SaveButton:SetColor(Color(55, 157, 247))
    self.SaveButton.DoClick = function(s)
        local savedTbl = {}
        for _, v in ipairs(self.hookPanels) do
            table.Add(savedTbl, {{
                hookID = v.hookID,
                commands = v.panel.Table,
            }})
        end

        if #savedTbl >= 63 then notification.AddLegacy("You've hit the event hook limit", NOTIFY_ERROR, 3) return end

        net.Start("AEvent:SaveEvent")
        net.WriteString(self.eventID)
        net.WriteString(self.NameLabel:GetText())
        net.WriteUInt(#savedTbl, 6)
        for _, v in ipairs(savedTbl) do
            net.WriteString(v.hookID)
            net.WriteUInt(#v.commands, 12) -- if anyone hits this limit then ur doing something wrong lmao
            for _, commandDATA in ipairs(v.commands) do
                net.WriteString(commandDATA.commandID)
                net.WriteTable(commandDATA.data or {}) -- sorry but this cannot be optimised as people could want to network anything
                -- to combat this i do serverside checks obv
            end
        end
        net.SendToServer()
    end

    self.NameLabel = self:Add("DTextEntry")
    self.NameLabel:Dock(TOP)
    self.NameLabel:SetPlaceholderText("Event Name")
    self.NameLabel:DockMargin(self.margin, self.margin, self.margin, 0)
    self.NameLabel:SetText("")

    self.Scroll = self:Add("DScrollPanel")
    self.Scroll:Dock(FILL)
end

function PANEL:AddHook(hookID)
    local HookPanel = self.Scroll:Add("AEvent:HookPanel")
    HookPanel:Dock(TOP)
    HookPanel:DockMargin(self.margin, self.margin, self.margin, 0)
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
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(255, 255, 255, 20)
    surface.DrawRect(0, 0, w, h)
end
vgui.Register("AEvent:EventEditor", PANEL, "EditablePanel")