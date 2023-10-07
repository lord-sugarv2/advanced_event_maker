AEvent:CreateFont("AEvent:16", 16)

local PANEL = {}
function PANEL:Init()
    self:SetFont("AEvent:16")
    self.otherCol = Color(AEvent.Colors["white"].r - 100, AEvent.Colors["white"].g - 100, AEvent.Colors["white"].b - 100, AEvent.Colors["white"].a)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(AEvent.Colors["secondary"].r, AEvent.Colors["secondary"].g, AEvent.Colors["secondary"].b, AEvent.Colors["secondary"].a)
    surface.DrawRect(0, 0, w, h)

    draw.SimpleText(self:GetText() == "" and self:GetPlaceholderText() or "", "AEvent:16", 3, h/2, self.otherCol, 0, 1)
    self:DrawTextEntryText(AEvent.Colors["white"], AEvent.Colors["white"], AEvent.Colors["white"])
end
vgui.Register("AEvent:TextEntry", PANEL, "DTextEntry")