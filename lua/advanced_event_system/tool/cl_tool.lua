function AEvent:WireframeBox(cornerOne, cornerTwo, col, showThroughMap)
	local position = (cornerOne + cornerTwo) * 0.5
	local angle = Angle(0, 0, 0)
	local mins =  cornerOne - cornerTwo
	local maxs = cornerTwo - cornerOne
	
	render.DrawWireframeBox(position, angle, mins*.5, maxs*.5, col, false)
end

function AEvent:DrawBox(cornerOne, cornerTwo, col, showThroughMap)
	local mid = (cornerOne + cornerTwo) * 0.5
	local size = Vector(cornerOne.x - mid.x, cornerOne.y - mid.y, cornerOne.z - mid.z)
	render.SetColorMaterial()

    cam.IgnoreZ(showThroughMap)
        render.DrawBox(mid, angle_zero, size, -size, col or color_white)
        render.DrawBox(mid, angle_zero, -size, size, col or color_white)
    cam.IgnoreZ(false)
end

function AEvent:OpenPresetEditor()
	if IsValid(self.Frame) then self.Frame:Remove() end

	local width, height = AEvent:Scale(350), AEvent:Scale(350)
	self.Frame = vgui.Create("AEvent:Frame")
    self.Frame:SetTitle(AEvent:GetPhrase("preset_maker"))
    self.Frame:SetSize(width, height)
    self.Frame:MakePopup()
    self.Frame:Center()

    local Panel = self.Frame:Add("AEvent:PresetEditor")
    Panel:Dock(FILL)
end

hook.Add("InitPostEntity", "AEvent:Tool:InitPost", function()
	net.Start("AEvent:Tool:RequestPresets")
	net.SendToServer()
end)

AEvent.Presets = AEvent.Presets or {}
net.Receive("AEvent:Tool:NetworkID", function()
	local shouldDelete, tbl = net.ReadBool(), {}
	if shouldDelete then
		local id = net.ReadString()
		for int, v in ipairs(AEvent.Presets) do
			if v.id ~= id then continue end
			table.remove(AEvent.Presets, int)
			break
		end
		hook.Run("AEvent:PresetAdded", id, shouldDelete)
		return
	end

	local int = net.ReadUInt(12)
	for i = 1, int do
		local name, type, id = net.ReadString(), net.ReadString(), net.ReadString()
		table.Add(AEvent.Presets, {{id = id, name = name, type = type}})
		hook.Run("AEvent:PresetAdded", id, shouldDelete, name, type)
	end
end)

function AEvent:GetPreset(id)
    for _, v in ipairs(AEvent.Presets) do
        if v.id ~= id then continue end
        return v
    end
    return false
end