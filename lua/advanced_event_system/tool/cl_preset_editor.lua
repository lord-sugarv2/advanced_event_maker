local PANEL = {}
function PANEL:Init()
    self.margin = 3
    self.Panels = {}
    self.Scroll = self:Add("AEvent:ScrollPanel")
    self.Scroll:Dock(FILL)

    for _, v in ipairs(AEvent.Presets) do
        self:AddPreset(v)
    end

    hook.Add("AEvent:PresetAdded", "AEvent:PresetAdded:RemovePanel", function(id, isDelete, name, type)
        if not IsValid(self) then return end
        if isDelete then
            if not IsValid(self.Panels[id]) then return end
            self.Panels[id]:Remove()
            self.Panels[id] = nil
            return
        end

        self:AddPreset({id = id, name = name, type = type})
    end)
end

function PANEL:AddPreset(data)
    local PresetButton = self.Scroll:Add("AEvent:Button")
    PresetButton:Dock(TOP)
    PresetButton:DockMargin(0, self.margin, 0, 0)
    PresetButton:SetText(data.type..": "..data.name)
    PresetButton:SetTall(AEvent:Scale(25))
    PresetButton.DoRightClick = function()
        local menu = AEvent:DermaMenu(nil, nil, true)
        menu:AddOption(AEvent:GetPhrase("delete"), function()
            net.Start("AEvent:PresetOption")
            net.WriteBool(true) -- isDelete
            net.WriteString(data.id)
            net.SendToServer()
        end)
        menu:AddOption(AEvent:GetPhrase("rename"), function()
            AEvent:StringRequest(AEvent:GetPhrase("addon_name"), {
                {
                    text = AEvent:GetPhrase("input_name"),
                    Type = "String Input",
                    data = {},
                },
            }, function(tbl)
                net.Start("AEvent:PresetOption")
                net.WriteBool(false) -- isDelete
                net.WriteString(data.id)
                net.WriteString(tbl[1].data.selected)
                net.SendToServer()
            end)
        end)
        menu:Open()
    end
    self.Panels[data.id] = PresetButton
end
vgui.Register("AEvent:PresetEditor", PANEL, "EditablePanel")