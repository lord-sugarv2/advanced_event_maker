local PANEL = {}
function PANEL:Init()
    self.margin = 3

    self.Scroll = self:Add("DScrollPanel")
    self.Scroll:Dock(FILL)

    self.CreateButton = self.Scroll:Add("AEvent:Button")
    self.CreateButton:Dock(TOP)
    self.CreateButton:SetTall(35)
    self.CreateButton:SetText("CREATE EVENT")
    self.CreateButton.DoClick = function()
        local parent = self:GetParent()
        self:Remove()

        local panel = parent:Add("AEvent:EventEditor")
        panel:Dock(FILL)
        panel:CreateNew()
    end

    net.Start("AEvent:RequestEvents")
    net.SendToServer()

    hook.Add("AEvent:UpdateEvents", "AEvent:UpdateEvents:Main", function(events)
        if not IsValid(self) then return end
        for _, v in ipairs(events) do
            self:AddEvent(v)
        end
    end)
end

function PANEL:AddEvent(DATA)
    local EventButton = self.Scroll:Add("AEvent:Button")
    EventButton:Dock(TOP)
    EventButton:DockMargin(0, self.margin, 0, 0)
    EventButton:SetText(DATA.Name)
    EventButton:SetTall(25)
    EventButton.DoClick = function()
        local parent = self:GetParent()
        self:Remove()

        local panel = parent:Add("AEvent:EventEditor")
        panel:Dock(FILL)
        panel:SetEvent(DATA.ID)
    end
    EventButton.ID = DATA.ID
end
vgui.Register("AEvent:Main", PANEL, "EditablePanel")