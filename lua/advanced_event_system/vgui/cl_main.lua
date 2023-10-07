AEvent:CreateFont("AEvent:22:Bold", 22, true)

local PANEL = {}
function PANEL:Init()
    self.margin = 3

    self.Scroll = self:Add("AEvent:ScrollPanel")
    self.Scroll:Dock(FILL)

    self.EndEvent = self.Scroll:Add("AEvent:Button")
    self.EndEvent:Dock(TOP)
    self.EndEvent:SetTall(AEvent:Scale(25))
    self.EndEvent:SetText(AEvent:GetPhrase("end_event"))
    self.EndEvent:SetColor(AEvent.Colors["red"])
    self.EndEvent:SetTextColor(color_white)
    self.EndEvent.DoClick = function()
        self.EndEvent:SetTall(0)

        net.Start("AEvent:StopEvent")
        net.SendToServer()
    end
    self.EndEvent:SetTall(0)

    self.CreateButton = self.Scroll:Add("AEvent:Button")
    self.CreateButton:Dock(TOP)
    self.CreateButton:DockMargin(0, self.margin, 0, 0)
    self.CreateButton:SetTall(AEvent:Scale(35))
    self.CreateButton:SetText(AEvent:GetPhrase("create_event"))
    self.CreateButton:SetFont("AEvent:22:Bold")
    self.CreateButton.DoClick = function()
        local parent = self:GetParent()
        self:Remove()

        local Panel = parent:Add("AEvent:EventEditor")
        Panel:Dock(FILL)
        Panel:CreateNew()
    end

    net.Start("AEvent:RequestEvents")
    net.SendToServer()

    hook.Add("AEvent:SaveEvents", "AEvent:SaveEvents:Main", function(active, events)
        if not IsValid(self) then return end
        for _, v in ipairs(events) do
            self:AddEvent(v)
        end
        self.EndEvent:SetTall(active and AEvent:Scale(25) or 0)
    end)
end

function PANEL:AddEvent(DATA)
    local EventButton = self.Scroll:Add("AEvent:Button")
    EventButton:Dock(TOP)
    EventButton:DockMargin(0, self.margin, 0, 0)
    EventButton:SetText(DATA.Name)
    EventButton:SetTall(AEvent:Scale(25))
    EventButton.DoClick = function()
        local parent = self:GetParent()
        self:Remove()

        local Panel = parent:Add("AEvent:EventEditor")
        Panel:Dock(FILL)
        Panel:SetEvent(DATA.ID)
    end
    EventButton.ID = DATA.ID
end
vgui.Register("AEvent:Main", PANEL, "EditablePanel")