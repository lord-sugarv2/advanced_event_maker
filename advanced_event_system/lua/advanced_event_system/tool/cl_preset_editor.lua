local PANEL = {}
function PANEL:Init()
    self.margin = 3
    self.Panels = {}
    self.Scroll = self:Add("DScrollPanel")
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
    PresetButton:SetTall(25)
    PresetButton.DoRightClick = function()
        local menu = DermaMenu()
        menu:AddOption("Delete", function()
            net.Start("AEvent:PresetOption")
            net.WriteBool(true) -- isDelete
            net.WriteString(data.id)
            net.SendToServer()
        end)
        menu:AddOption("Rename", function()
            Derma_StringRequest(
                "AEvent Input", 
                "input the new text",
                "",
                function(text)
                    net.Start("AEvent:PresetOption")
                    net.WriteBool(false) -- isDelete
                    net.WriteString(data.id)
                    net.WriteString(text)
                    net.SendToServer()
                end,
                function(text) end
            )
        end)
        menu:Open()
    end
    self.Panels[data.id] = PresetButton
end
vgui.Register("AEvent:PresetEditor", PANEL, "EditablePanel")