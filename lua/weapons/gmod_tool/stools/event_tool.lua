TOOL.Category = "Event System"
TOOL.Name = "Event Tool"
TOOL.Command = nil
TOOL.ConfigName = nil

local function load()
	if CLIENT then
		language.Add("tool.event_tool.name", AEvent:GetPhrase("preset_maker"))
		language.Add("tool.event_tool.desc", AEvent:GetPhrase("left_click"))
		language.Add("tool.event_tool.0", AEvent:GetPhrase("right_click"))
	end
end

hook.Add("AEvent:Loaded", "AEvent:Loaded", function()
	load()
end)

if AEvent then
	load()
end

local localplayer = CLIENT and LocalPlayer or ""

local cornerOne = nil
function TOOL:LeftClick(trace)
	if SERVER then return true end

	if not AEvent:IsAdmin(localplayer(), true) then notification.AddLegacy(AEvent:GetPhrase("dont_have_rank"), NOTIFY_ERROR, 3) return end
	if not IsFirstTimePredicted() then return end
	if not cornerOne then
		-- We need to start the process
		cornerOne = localplayer():GetEyeTrace().HitPos
		return true
	end

	local frame = vgui.Create("AEvent:Frame")
    frame:SetTitle(AEvent:GetPhrase("addon_name"))
    frame:SetSize(AEvent:Scale(350), 0)
    frame:MakePopup()
    frame:Center()
 
	local textbox = frame:Add("AEvent:TextEntry")
	textbox:Dock(TOP)
	textbox:SetPlaceholderText(AEvent:GetPhrase("input_name"))
	textbox:SetTall(AEvent:Scale(22))

	local selectionType = frame:Add("DComboBox")
	selectionType:Dock(TOP)
	selectionType:DockMargin(0, 3, 0, 0)
	selectionType:AddChoice(AEvent:GetPhrase("kill_box"), "Kill Box", true)
	selectionType:AddChoice(AEvent:GetPhrase("props"), "Props")
	selectionType:AddChoice(AEvent:GetPhrase("box"), "Box")
	selectionType:SetTall(AEvent:Scale(22))

	local cOne, cornerTwo = cornerOne, localplayer():GetEyeTrace().HitPos
	local button = frame:Add("AEvent:Button")
	button:Dock(TOP)
	button:DockMargin(0, 3, 0, 0)
	button:SetText(AEvent:GetPhrase("create_preset"))
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

	frame:SetTall(AEvent:Scale(24) + 5 + textbox:GetTall() + 3 + selectionType:GetTall() + 3 + button:GetTall() + 3)

	-- end the process
	cornerOne = nil
	return true
end

function TOOL:RightClick(trace)
	if SERVER then return true end
	if not AEvent:IsAdmin(localplayer(), true) then notification.AddLegacy(AEvent:GetPhrase("dont_have_rank"), NOTIFY_ERROR, 3) return end

	AEvent:OpenPresetEditor()

	return true
end

function TOOL:Deploy() end
function TOOL:Holster() cornerOne = false end

local function Check()
	local wep = localplayer():GetActiveWeapon()
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

	local cornerTwo = localplayer():GetEyeTrace().HitPos
	AEvent:DrawBox(cornerOne, cornerTwo, color_green_two)
	AEvent:WireframeBox(cornerOne, cornerTwo, color_green)
end)

local color_red = Color(0, 0, 0)
hook.Add("PreDrawHalos", "AEvent:HaloProps", function()
	if not cornerOne then return end
	
	local shouldStop = Check()
	if shouldStop then return end

	local cornerTwo = localplayer():GetEyeTrace().HitPos

	local tbl = {}
	for k, v in ipairs(ents.FindInBox(cornerOne, cornerTwo)) do
		if v:GetClass() ~= "prop_physics" then continue end
		table.insert(tbl, v)
	end
	halo.Add(tbl, color_red, 1, 1, 1, false)
end)