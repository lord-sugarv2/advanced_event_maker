function AEvent:WireframeBox(cornerOne, cornerTwo, col, showThroughMap)
    showThroughMap = not showThroughMap
	col = col or color_white
	local otherZ = cornerTwo.z - cornerOne.z
	local a = cornerOne + Vector(0, 0, otherZ)
	local b = cornerOne + Vector(0, cornerTwo.y - cornerOne.y, otherZ)
	local c = Vector(cornerOne.x, cornerTwo.y, cornerOne.z)
	local d = Vector(cornerTwo.x, cornerTwo.y, cornerOne.z)
	local e = Vector(cornerTwo.x, cornerOne.y, cornerOne.z)
	local f = cornerTwo.x - cornerOne.x
	render.DrawLine(cornerOne, a, col, showThroughMap)
	render.DrawLine(a, b, col, showThroughMap)
	render.DrawLine(b, c, col, showThroughMap)
	render.DrawLine(cornerOne, c, col, showThroughMap)

	render.DrawLine(cornerOne, cornerOne + Vector(f, 0, 0), col, showThroughMap)
	render.DrawLine(a, cornerOne + Vector(f, 0, otherZ), col, showThroughMap)
	render.DrawLine(c, d, col, showThroughMap)
	render.DrawLine(d, e, col, showThroughMap)

	render.DrawLine(d, Vector(cornerTwo.x, cornerTwo.y, cornerTwo.z), col, showThroughMap)
	render.DrawLine(e, Vector(cornerTwo.x, cornerOne.y, cornerTwo.z), col, showThroughMap)
	render.DrawLine(Vector(cornerTwo.x, cornerOne.y, cornerTwo.z), Vector(cornerTwo.x, cornerTwo.y, cornerTwo.z), col, showThroughMap)
	render.DrawLine(Vector(cornerTwo.x, cornerTwo.y, cornerTwo.z), Vector(cornerOne.x, cornerTwo.y, cornerTwo.z), col, showThroughMap)
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
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetTitle("Event Preset Maker")
    self.Frame:SetSize(ScrW() * .2, ScrH() * .4)
    self.Frame:MakePopup()
    self.Frame:Center()
    self.Frame:DockPadding(5, 24 + 3, 5, 5)
    self.Frame.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(0, 0, 0)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end

    local panel = self.Frame:Add("AEvent:PresetEditor")
    panel:Dock(FILL)
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