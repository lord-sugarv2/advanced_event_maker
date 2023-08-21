local PANEL = {}
local none = Color(0, 0, 0, 0)
local over = Color(0, 0, 0, 120)
local niceBlack = Color(60, 60, 60)
function PANEL:Init()
    self:SetText("")
    self.col = Color(255, 255, 255, 255)
    function self:SetText(str)
        self.text = str
    end    
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.col.r-55, self.col.g-55, self.col.b-55, self.col.a)
    surface.DrawRect(0, h-2, w, 2)

    surface.SetDrawColor(self.col.r, self.col.g, self.col.b, self.col.a)
    surface.DrawRect(0, self:IsDown() and 2 or 0, w, h-2)

    draw.SimpleText(self:GetText(), "TabLarge", w/2, self:IsDown() and 2 + ((h-2)/2) or h/2, self:GetTextColor() or niceBlack, 1, 1)

    local col = self:IsHovered() and over or none 
    surface.SetDrawColor(col)
    surface.DrawRect(0, self:IsDown() and 2 or 0, w, self:IsDown() and h-2 or h)
end
vgui.Register("AEvent:Button", PANEL, "DButton")