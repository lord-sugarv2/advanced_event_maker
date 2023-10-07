AEvent:CreateFont("AEvent:17:Bold", 17, true)
local localplayer = LocalPlayer

local PANEL = {}
local none = Color(0, 0, 0, 0)
local over = Color(0, 0, 0, 120)
local niceBlack = Color(60, 60, 60)
function PANEL:Init()
    self:SetText("")
    self:SetFont("AEvent:17:Bold")
    self:SetTall(AEvent:Scale(22))
    self.col = AEvent.Colors["white"]

    function self:SetText(str)
        if self.updateSize then
            surface.SetFont(self:GetFont())
            local w, h = surface.GetTextSize(str)
            self:SetWide(w + AEvent:Scale(20))
        end
        self.text = str
    end    
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:OnMousePressed(mousecode)
	if ( self:GetDisabled() ) then return end
    if mousecode == MOUSE_LEFT then
       surface.PlaySound("ui/buttonclick.wav") 
    end

	if ( mousecode == MOUSE_LEFT && !dragndrop.IsDragging() && self.m_bDoubleClicking ) then
		if ( self.LastClickTime && SysTime() - self.LastClickTime < 0.2 ) then
			self:DoDoubleClickInternal()
			self:DoDoubleClick()
			return
		end
		self.LastClickTime = SysTime()
	end

	local isPlyMoving = localplayer && IsValid( localplayer() ) && ( localplayer():KeyDown( IN_FORWARD ) || localplayer():KeyDown( IN_BACK ) || localplayer():KeyDown( IN_MOVELEFT ) || localplayer():KeyDown( IN_MOVERIGHT ) )
	if ( self:IsSelectable() && mousecode == MOUSE_LEFT && ( input.IsShiftDown() || input.IsControlDown() ) && !isPlyMoving ) then
		return self:StartBoxSelection()
	end

	self:MouseCapture(true)
	self.Depressed = true
	self:OnDepressed()
	self:InvalidateLayout(true)

	self:DragMousePress(mousecode)
end

function PANEL:OnCursorEntered()
    surface.PlaySound("ui/buttonrollover.wav")
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.col.r-55, self.col.g-55, self.col.b-55, self.col.a)
    surface.DrawRect(0, h-2, w, 2)

    surface.SetDrawColor(self.col.r, self.col.g, self.col.b, self.col.a)
    surface.DrawRect(0, self:IsDown() and 2 or 0, w, h-2)

    draw.SimpleText(self:GetText(), self:GetFont(), w/2, self:IsDown() and 2 + ((h-2)/2) or (h-2)/2, self:GetTextColor() or niceBlack, 1, 1)

    local col = self:IsHovered() and over or none 
    surface.SetDrawColor(col)
    surface.DrawRect(0, self:IsDown() and 2 or 0, w, self:IsDown() and h-2 or h)
end
vgui.Register("AEvent:Button", PANEL, "DButton")