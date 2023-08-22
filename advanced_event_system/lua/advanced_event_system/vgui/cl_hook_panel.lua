local function TextEntryAnswer(text, callback)
    Derma_StringRequest(
	"AEvent Input", 
	text,
	"",
	function(text) callback(text) end,
	function(text) end
    )
end

local PANEL = {}
function PANEL:Init()
    self.margin = 3
    self.extrasize = 0

    self.Table = {}
    self.panels = {}

    self:SetTall(100)

    self.Header = self:Add("Panel")
    self.Header:Dock(TOP)
    self.Header:DockMargin(self.margin, self.margin, self.margin, 0)

    self.CommandButton = self.Header:Add("AEvent:Button")
    self.CommandButton:Dock(LEFT)
    self.CommandButton:SetWide(self.CommandButton:GetTall())
    self.CommandButton:SetText("+")
    self.CommandButton.DoClick = function(s)
        local menu = DermaMenu()
        for categoryID, categoryDATA in pairs(AEvent:GetCategories()) do
            local panel, parent = menu:AddSubMenu(categoryDATA.Name)
            for commandID, commandDATA in pairs(categoryDATA.Commands) do
                local extraSelections = commandDATA.ExtraSelection()
                if extraSelections and extraSelections[1] == "String Input" then
                    local panel, parent = panel:AddOption(commandDATA.Name, function()
                        TextEntryAnswer(extraSelections[2], function(text)
                            table.Add(self.Table, {{commandID = commandID, data = {Selection = text}}})
                            self:AddCommand()
                        end)
                    end)
                elseif extraSelections then
                    local panel, parent = panel:AddSubMenu(commandDATA.Name)
                    for _, v in ipairs(extraSelections) do
                        panel:AddOption(v.Text, function()
                            v.Data.Selection = v.Text
                            table.Add(self.Table, {{commandID = commandID, data = v.Data}})
                            self:AddCommand()
                        end)
                    end
                else
                    local panel, parent = panel:AddOption(commandDATA.Name, function()
                        table.Add(self.Table, {{commandID = commandID, data = {}}})
                        self:AddCommand(data)
                    end)
                end
            end
        end
        menu:Open()
    end

    self.HookName = self.Header:Add("DLabel")
    self.HookName:Dock(LEFT)
    self.HookName:DockMargin(self.margin, 0, 0, 0)
    self.HookName:SetFont("TabLarge")
    self.HookName:SetTextColor(color_black)

    self.DeleteButton = self.Header:Add("AEvent:Button")
    self.DeleteButton:Dock(RIGHT)
    self.DeleteButton:SetWide(self.DeleteButton:GetTall())
    self.DeleteButton:SetText("✕")
    self.DeleteButton:SetColor(Color(255, 100, 100))
    self.DeleteButton:SetTextColor(color_white)
    self.DeleteButton.DoClick = function()
        self:DeleteClicked()
    end
end

function PANEL:RefreshDeleted(intDeleted)
    for int, v in ipairs(self.panels) do
        if not IsValid(v.panel) then continue end
        if v.panel.tablePos <= intDeleted then continue end
        v.panel.tablePos = v.panel.tablePos - 1
    end
end

function PANEL:RefreshInsertAbove(intInserted)
    for int, v in ipairs(self.panels) do
        if not IsValid(v.panel) then continue end
        if v.panel.tablePos <= intInserted then continue end
        v.panel.tablePos = v.panel.tablePos + 1
    end
end

function PANEL:RefreshLayout()
    for _, v in ipairs(self.panels) do
        v.panel:Remove()
    end

    local tbl = table.Copy(self.Table)
    self.Table = {}
    self.panels = {}

    for _, v in ipairs(tbl) do
        self:AddCommand(v)
    end
end

function PANEL:AddCommand(DATA)
    if DATA then
        table.Add(self.Table, {DATA})
    end

    local int = #self.Table
    local data = self.Table[int]

    local text = AEvent:FormatCommandPath(data.commandID)
    text = text and string.Replace(text, "...", data.data.Selection or "") or "BROKEN COMMAND PLEASE FIX OR DELETE THIS LINE"

    local label = self:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(self.margin, self.margin, self.margin, 0)
    label:SetFont("Trebuchet18")
    label:SetTextColor(color_black)
    label:SetText(" -> "..text)
    label:SizeToContents()
    label:SetMouseInputEnabled(true)
    label.tablePos = int
    label.DoRightClick = function(s)
        local menu = DermaMenu()
        menu:AddOption("Delete", function()
            table.remove(self.Table, s.tablePos)
            s:Remove()
            self:RefreshDeleted(s.tablePos)
        end)
        
        local panel, parent = menu:AddSubMenu("Insert Above")
        for categoryID, categoryDATA in pairs(AEvent:GetCategories()) do
            local panel, parent = panel:AddSubMenu(categoryDATA.Name)
            for commandID, commandDATA in pairs(categoryDATA.Commands) do
                local extraSelections = commandDATA.ExtraSelection()
                if extraSelections and extraSelections[1] == "String Input" then
                    local panel, parent = panel:AddOption(commandDATA.Name, function()
                        TextEntryAnswer(extraSelections[2], function(text)
                            table.insert(self.Table, s.tablePos, "placeholder")
                            self.Table[s.tablePos] = {
                                commandID = commandID,
                                data = {Selection = text},
                            }
                            self:RefreshInsertAbove(s.tablePos)
                            self:RefreshLayout()
                        end)
                    end)
                elseif extraSelections then
                    local panel, parent = panel:AddSubMenu(commandDATA.Name)
                    for _, v in ipairs(extraSelections) do
                        panel:AddOption(v.Text, function()
                            v.Data.Selection = v.Text
                            table.insert(self.Table, s.tablePos, "placeholder")
                            self.Table[s.tablePos] = {
                                commandID = commandID,
                                data = v.Data,
                            }
                            self:RefreshInsertAbove(s.tablePos)
                            self:RefreshLayout()
                        end)
                    end
                else
                    local panel, parent = panel:AddOption(commandDATA.Name, function()
                        table.insert(self.Table, s.tablePos, "placeholder")
                        self.Table[s.tablePos] = {
                            commandID = commandID,
                            data = {},
                        }
                        self:RefreshInsertAbove(s.tablePos)
                        self:RefreshLayout()
                    end)
                end
            end
        end
        menu:Open()
    end
    label:SetAutoStretchVertical(true)
    label:SetWrap(true)
    table.Add(self.panels, {{panel = label}})
end

function PANEL:DeleteClicked() end

function PANEL:SetHookID(hookID)
    local hookDATA = AEvent:GetHookDATA(hookID)
    self.HookName:SetText(hookDATA.Name)
    self.HookName:SizeToContents()
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(160, 160, 160, 180)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:PerformLayout(w, h)
    local extra = 0
    for _, v in ipairs(self.panels) do
        if not IsValid(v.panel) then continue end
        extra = extra + v.panel:GetTall() + self.margin
    end
    self:SetTall(80 + extra)
end

vgui.Register("AEvent:HookPanel", PANEL, "EditablePanel")