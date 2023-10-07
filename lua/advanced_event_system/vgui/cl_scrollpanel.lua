local PANEL = {}
function PANEL:Init()
    self.VBar:SetWide(AEvent:Scale(12))
    self.VBar:SetHideButtons(true)

    self.VBar.Paint = function(pnl, w, h)
        surface.SetDrawColor(AEvent.Colors["secondary"].r, AEvent.Colors["secondary"].g, AEvent.Colors["secondary"].b, AEvent.Colors["secondary"].a)
        surface.DrawRect(0, 0, w, h)
    end

    self.VBar.btnGrip.Paint = function(pnl, w, h)
        surface.SetDrawColor(AEvent.Colors["secondary"].r + 100, AEvent.Colors["secondary"].g + 100, AEvent.Colors["secondary"].b + 100, 255)
        surface.DrawRect(0, 0, w, h)
    end
end
vgui.Register("AEvent:ScrollPanel", PANEL, "DScrollPanel")