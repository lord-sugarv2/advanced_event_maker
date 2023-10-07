--[[
AEvent:StringRequest("awd", {
	{
		text = "awd",
		Type = "String Input",
		data = {},
	},
	{
		text = "123",
		Type = "Int Input",
		data = {},
	},
	{
		text = "law",
		Type = "Combo Input",
		Options = {
			{text = "Hello", data = {Microphone = true}},
			{text = "Lemonade", data = {Microphone = false}},
		},
	},
}, function(tbl)

end)
]]--
function AEvent:StringRequest(strText, querys, onEnter)
	if IsValid(self.Query) then self.Query:Remove() return end
	local w, h = AEvent:Scale(350), AEvent:Scale(24) + 3 + 5
	self.Query = vgui.Create("AEvent:Frame")
	self.Query:SetTitle(strText)
	self.Query:SetDraggable(false)
	self.Query:SetBackgroundBlur(true)
	self.Query:SetDrawOnTop(true)
  --  self.Query:Blur()

	local values = {}
	for _, v in ipairs(querys) do
		if v.Type == "Combo Input" then
			local Combo = self.Query:Add("DComboBox")
			Combo:Dock(TOP)
			Combo:DockMargin(0, 3, 0, 0)
			Combo:SetTall(AEvent:Scale(22))
			for _, option in ipairs(v.Options or v.Options[1] or {}) do
				Combo:AddChoice(option.text, option.data, true)
			end
			Combo.OnMenuOpened = function(s, menu)
				menu:SetMaxHeight(h)
			end
			h = h + Combo:GetTall() + 3
			table.Add(values, {{Combo, "combo"}})
			continue
		end

		local TextBox = self.Query:Add("AEvent:TextEntry")
		TextBox:Dock(TOP)
		TextBox:DockMargin(0, 3, 0, 0)
		TextBox:SetPlaceholderText(v.text)
		TextBox:SetTall(AEvent:Scale(22))
		if v.Type == "Int Input" then
			TextBox:SetNumeric(true)
			table.Add(values, {{TextBox, "IntInput", v.data}})
		else
			table.Add(values, {{TextBox, "StringInput", v.data}})
		end
		h = h + TextBox:GetTall() + 3
	end

	local submit = self.Query:Add("AEvent:Button")
	submit:Dock(BOTTOM)
	submit:DockMargin(0, 3, 0, 0)
	submit:SetText(AEvent:GetPhrase("confirmation"))
	submit.DoClick = function(s)
		local tbl = {}
		for _, v in ipairs(values) do
			if v[2] == "combo" then
				local str, DATA = v[1]:GetSelected()
				if not DATA then continue end
				DATA.selected = str
				table.Add(tbl, {{
					data = DATA,
				}})
			else
				local data = v[3]
				if not data then continue end
				data.selected = v[1]:GetText()
				table.Add(tbl, {{
					data = data,
				}})
			end
		end
		onEnter(tbl)
		self.Query:Remove()
	end
	h = h + submit:GetTall() + 3

	self.Query:SetSize(w, h)
	self.Query:Center()
	self.Query:MakePopup()
	self.Query:DoModal()

	return self.Query
end
--AEvent:StringRequest()


AEvent:CreateFont("AEvent:20", 20)
function AEvent_Query(strText, strTitle, ...)
	local Window = vgui.Create("AEvent:Frame")
	Window:SetTitle(strTitle or "Message Title (First Parameter)")
	Window:SetDraggable(false)
	Window:ShowCloseButton(false)
	Window:SetBackgroundBlur(true)
	Window:SetDrawOnTop(true)
	Window:Blur()

	local InnerPanel = vgui.Create("DPanel", Window)
	InnerPanel:SetPaintBackground(false)

	local Text = vgui.Create("DLabel", InnerPanel)
	Text:SetText(strText or "Message text (Second Parameter)")
	Text:SetContentAlignment(5)
	Text:SetTextColor(color_white)
	Text:SetFont("AEvent:20", 20)
	Text:SizeToContents()

	local ButtonPanel = vgui.Create("DPanel", Window)
	ButtonPanel:SetTall(AEvent:Scale(30))
	ButtonPanel:SetPaintBackground(false)

	-- Loop through all the options and create buttons for them.
	local NumOptions = 0
	local x = 5

	for k=1, 8, 2 do

		local text = select(k, ...)
		if text == nil then break end

		local Func = select(k+1, ...) or function() end

		local Button = vgui.Create("AEvent:Button", ButtonPanel)
		Button:SetText(text)
		Button.DoClick = function() Window:Close() Func() end
		Button:SetPos(x, 5)

		x = x + Button:GetWide() + 5

		ButtonPanel:SetWide(x)
		NumOptions = NumOptions + 1

	end

	local w, h = Text:GetSize()

	w = math.max(w, ButtonPanel:GetWide())

	Window:SetSize(w + AEvent:Scale(20), h + AEvent:Scale(25) + AEvent:Scale(45) + AEvent:Scale(10))
	Window:Center()

	InnerPanel:StretchToParent(5, AEvent:Scale(25), 5, AEvent:Scale(45))

	Text:StretchToParent(5, 5, 5, 5)

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom(8)

	Window:MakePopup()
	Window:DoModal()

	if (NumOptions == 0) then

		Window:Close()
		Error("Derma_Query: Created Query with no Options!?")
		return nil

	end

	return Window
end


-- off of the gmod wiki
-- i made an effort to clean the code up
-- + make it sort the members
local PANEL = {}
function PANEL:PerformLayout(w, h)
	local w = self:GetMinimumWidth()
	for k, pnl in ipairs(self:GetCanvas():GetChildren()) do
		pnl:InvalidateLayout(true)
		w = math.max(w, pnl:GetWide())
	end

	self:SetWide(w)

	local y = 0 -- for padding
	local tbl = {}
	for k, pnl in ipairs(self:GetCanvas():GetChildren()) do
		table.Add(tbl, {{
			pnl = pnl,
			name = pnl:GetText(),
		}})
	end

	table.SortByMember(tbl, "name", self.flip)
	for k, v in ipairs(tbl) do
		local pnl = v.pnl
		pnl:SetWide(w)
		pnl:SetPos(0, y)
		pnl:InvalidateLayout(true)

		y = y + pnl:GetTall()
	end

	y = math.min(y, self:GetMaxHeight())
	self:SetTall(y)
	derma.SkinHook("Layout", "Menu", self)
	DScrollPanel.PerformLayout(self, w, h)
end
vgui.Register("AEvent:DMenu", PANEL, "DMenu")

function AEvent:DermaMenu(parentmenu, parent, flip)
	if (!parentmenu) then CloseDermaMenus() end

	local dmenu = vgui.Create("AEvent:DMenu", parent)
	dmenu.flip = flip
	return dmenu
end

local PANEL = {}
function PANEL:AddSubMenu()
	local SubMenu = AEvent:DermaMenu(true, self, true)
	SubMenu:SetVisible(false)
	SubMenu:SetParent(self)

	self:SetSubMenu(SubMenu)
	return SubMenu
end
vgui.Register("AEvent:DMenuOption", PANEL, "DMenuOption")