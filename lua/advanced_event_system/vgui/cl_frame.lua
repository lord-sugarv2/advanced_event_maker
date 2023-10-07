AEvent:CreateFont("AEvent:18", 18, true)

local PANEL = {}
function PANEL:Init()
    self:DockPadding(5, AEvent:Scale(24) + 3, 5, 5)
    self.lblTitle:SetTextColor(color_white)
    self.lblTitle:SetFont("AEvent:18")

    self:ShowCloseButton(false)

    self.CloseButton = self:Add("AEvent:Button")
    self.CloseButton:SetColor(AEvent.Colors["red"])
    self.CloseButton:SetText("✕")
    self.CloseButton:SetTextColor(color_white)
    self.CloseButton.DoClick = function(s)
        self:Remove()
    end
end

function PANEL:Blur()
    self.blur = true
end

function PANEL:Paint(w, h)
    if self.blur then
        Derma_DrawBackgroundBlur(self, CurTime())
    end

    draw.RoundedBox(6, 0, 0, w, h, AEvent.Colors["background"])
end

function PANEL:PerformLayout()
	local titlePush = 0

    local thirtyOne = AEvent:Scale(31)
    local twentyFour = AEvent:Scale(20)
	if IsValid(self.CloseButton) then
        self.CloseButton:SetPos( self:GetWide() - thirtyOne - 4, 4 )
        self.CloseButton:SetSize( thirtyOne, twentyFour )
    end

	self.lblTitle:SetPos( 8 + titlePush, 2 )
	self.lblTitle:SetSize( self:GetWide() - AEvent:Scale(25) - titlePush, AEvent:Scale(20) )
end
vgui.Register("AEvent:Frame", PANEL, "DFrame")