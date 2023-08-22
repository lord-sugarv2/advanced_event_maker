TOOL.Category = "Event System"
TOOL.Name = "Event Tool"
TOOL.Command = nil
TOOL.ConfigName = nil

if CLIENT then
	language.Add("tool.event_tool.name", "Preset Maker")
	language.Add("tool.event_tool.desc", "left click to start the proccess; left click again to finish")
	language.Add("tool.event_tool.0", "right click to open the editor")
end

local cornerOne = nil
function TOOL:LeftClick(trace)
	if SERVER then return true end
	if not cornerOne then
		-- We need to start the process
		cornerOne = LocalPlayer():GetEyeTrace().HitPos
		return true
	end

	local frame = vgui.Create("DFrame")
    frame:SetTitle("Add Preset")
    frame:SetSize(ScrW() * .15, ScrH() * .15)
    frame:MakePopup()
    frame:Center()
    frame:DockPadding(5, 24 + 3, 5, 5)
    frame.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(0, 0, 0)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end

	local textbox = frame:Add("DTextEntry")
	textbox:Dock(TOP)
	textbox:SetPlaceholderText("Preset Name")

	local selectionType = frame:Add("DComboBox")
	selectionType:Dock(TOP)
	selectionType:DockMargin(0, 3, 0, 0)
	selectionType:AddChoice("Kill Box", "Kill Box", true)
	selectionType:AddChoice("Props", "Props")
	selectionType:AddChoice("Box (can tp people here)", "Box")

	local cOne, cornerTwo = cornerOne, LocalPlayer():GetEyeTrace().HitPos
	local button = frame:Add("AEvent:Button")
	button:Dock(TOP)
	button:DockMargin(0, 3, 0, 0)
	button:SetText("CREATE PRESET")
	button.DoClick = function()
		local selected = selectionType:GetOptionData(selectionType:GetSelectedID())
		net.Start("AEvent:Tool:CreatePreset")
		net.WriteString(textbox:GetText())
		net.WriteString(selected)
		if selected == "Props" then
			local props = {}
			for _, ent in ipairs(ents.FindInBox(cOne, cornerTwo)) do
				if ent:GetClass() ~= "prop_physics" then continue end
				table.insert(props, ent)
			end

			net.WriteUInt(#props, 32)
			for _, ent in ipairs(props) do
				net.WriteEntity(ent)
			end
		elseif selected == "Kill Box" or selected == "Box" then
			net.WriteVector(cOne)
			net.WriteVector(cornerTwo)
		end
		net.SendToServer()

		frame:Remove()
	end

	frame:SetTall(24 + 5 + textbox:GetTall() + 3 + selectionType:GetTall() + 3 + button:GetTall() + 3)

	-- end the process
	cornerOne = nil
	return true
end

function TOOL:RightClick(trace)
	if SERVER then return true end

	AEvent:OpenPresetEditor()

	return true
end

function TOOL:Deploy() end
function TOOL:Holster() cornerOne = false end

local function Check()
	local wep = LocalPlayer():GetActiveWeapon()
	if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
	if wep:GetMode() == "event_tool" then return end
	cornerOne = false
	return true
end

local color_green = Color(71, 255, 65)
local color_green_two = Color(71, 255, 65, 20)

hook.Add("PostDrawTranslucentRenderables", "AEvent:PropSelector", function()
	if not cornerOne then return end
	
	local shouldStop = Check()
	if shouldStop then return end

	local cornerTwo = LocalPlayer():GetEyeTrace().HitPos
	AEvent:DrawBox(cornerOne, cornerTwo, two)
	AEvent:WireframeBox(cornerOne, cornerTwo, color_green_two)
end)

local color_red = Color(0, 0, 0)
hook.Add("PreDrawHalos", "AEvent:HaloProps", function()
	if not cornerOne then return end
	
	local shouldStop = Check()
	if shouldStop then return end

	local cornerTwo = LocalPlayer():GetEyeTrace().HitPos

	local tbl = {}
	for k, v in ipairs(ents.FindInBox(cornerOne, cornerTwo)) do
		if v:GetClass() ~= "prop_physics" then continue end
		table.insert(tbl, v)
	end
	halo.Add(tbl, color_red, 1, 1, 1, false)
end)