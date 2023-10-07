local scrW, scrH = ScrW, ScrH
AEvent:CreateFont("AEvent:14", 14)

local function Request_Answer(text, tbl, callback)
    AEvent:StringRequest(text, tbl, function(tbl)
        callback(tbl)
    end)
end

local targetTypes = {
    ["target_everyone"] = "Target everyone",
    ["target_name"] = "Target everyone '...' in thier name",
    ["target_team"] = "Target everyone as team '...'",    
    ["target_trigger"] = "Target the player who caused the trigger",
    ["target_everyone_event"] = "Target everyone in the event",
    ["target_name_event"] = "Target everyone in the event with '...' in thier name",
    ["target_team_event"] = "Target everyone in the event as team '...'",
    ["other"] = "Other",

    ["target_usergroup_event"] = "Target everyone in the event as usergroup '...'",
    ["target_usergroup"] = "Target everyone as usergroup '...'",
}

local PANEL = {}
function PANEL:Init()
    self.margin = AEvent:Scale(3)
    self.extrasize = 0

    self.table = {}
    self.panels = {}

    self:SetTall(AEvent:Scale(100))

    self.Header = self:Add("Panel")
    self.Header:Dock(TOP)
    self.Header:SetTall(AEvent:Scale(25))
    self.Header:DockMargin(self.margin, self.margin, self.margin, 0)
    self.Header.PerformLayout = function(s, w, h)
      --  self.CommandButton:SetWide(self.CommandButton:GetTall())
        self.DeleteButton:SetWide(self.DeleteButton:GetTall())
        self.Popout:SetWide(self.Popout:GetTall())
    end

    self.HookName = self.Header:Add("DLabel")
    self.HookName:Dock(LEFT)
    self.HookName:DockMargin(self.Header:GetTall(), 0, 0, 0)
    self.HookName:SetFont("AEvent:22:Bold")
    self.HookName:SetTextColor(AEvent.Colors["white"])

    self.DeleteButton = self.Header:Add("AEvent:Button")
    self.DeleteButton:Dock(RIGHT)
    self.DeleteButton:SetText("✕")
    self.DeleteButton:SetColor(AEvent.Colors["red"])
    self.DeleteButton:SetTextColor(color_white)
    self.DeleteButton.DoClick = function()
        self:DeleteClicked()
    end

    self.Popout = self.Header:Add("AEvent:Button")
    self.Popout:Dock(RIGHT)
    self.Popout:DockMargin(0, 0, self.margin, 0)
    self.Popout:SetText("O")
    self.Popout:SetColor(AEvent.Colors["green"])
    self.Popout:SetTextColor(color_black)
    self.Popout.DoClick = function()
        self:PopoutMenu()
    end
end

local function ContainsWords(str, wordTable)
    for _, word in ipairs(wordTable) do
        local start, startEnd = string.find(string.lower(str), string.lower(word))
        if not start then return false end
    end
    return true
end

function PANEL:PopoutMenu()
    local teams = {}
    for _, v in ipairs(team.GetAllTeams()) do
        table.Add(teams, {{
            text = v.Name,
            data = {}, -- You can store data here that can be called
        }})
    end

    local usergroups = {}
    for id, v in pairs(CAMI and CAMI:GetUsergroups() or {}) do
        table.Add(usergroups, {{
            text = v.Name,
            data = {}, -- You can store data here that can be called
        }})
    end

    if IsValid(AEvent.Popout) then AEvent.Popout:Remove() end
    AEvent.Popout = vgui.Create("AEvent:Frame")
    AEvent.Popout:SetTitle(AEvent:GetPhrase("addon_name"))
    AEvent.Popout:SetSize(scrW() * .2, scrH() * .2)
    AEvent.Popout:MakePopup()
    AEvent.Popout:Center()
    AEvent.Popout:SetX(AEvent.Frame:GetX() + AEvent.Popout:GetWide() + self.margin)
    AEvent.Popout:SetSizable(true)
    AEvent.Popout.panels = {}
    AEvent.Popout.Think = function(s)
        if not IsValid(self) then s:Remove() end 
    end

    AEvent.Popout.Combo = AEvent.Popout:Add("DComboBox")
    AEvent.Popout.Combo:Dock(TOP)
    AEvent.Popout.Combo:SetSortItems(true)
    AEvent.Popout.Combo:SetTall(AEvent:Scale(22))

    for id, str in pairs(targetTypes) do
        AEvent.Popout.Combo:AddChoice(str, id, id == "target_everyone_event")
    end

    AEvent.Popout.TextBox = AEvent.Popout:Add("AEvent:TextEntry")
    AEvent.Popout.TextBox:Dock(TOP)
    AEvent.Popout.TextBox:DockMargin(0, self.margin, 0, 0)
    AEvent.Popout.TextBox:SetPlaceholderText("Search")
    AEvent.Popout.TextBox:SetTall(AEvent:Scale(22))
    AEvent.Popout.TextBox.OnChange = function(s)
        local val = s:GetText()
        for _, panel in ipairs(AEvent.Popout.panels) do
            if ContainsWords(panel:GetText(), string.Explode(" ", val)) then
                panel:Show()
            else
                panel:Hide()
            end
        end
        AEvent.Popout.Scroll:InvalidateLayout(true)
    end

    AEvent.Popout.Scroll = AEvent.Popout:Add("AEvent:ScrollPanel")
    AEvent.Popout.Scroll:Dock(FILL)
    AEvent.Popout.Scroll:DockMargin(0, self.margin, 0, 0)
    local old = AEvent.Popout.Scroll.PerformLayout
    AEvent.Popout.Scroll.PerformLayout = function(s, w, h)
        old(s, w, h)
        local y = 0
        local size = s:GetVBar():IsVisible() and (s:GetVBar():GetWide()+self.margin+self.margin) or 0
        size = w - size
        local twentyTwo = AEvent:Scale(22)
        for _, panel in ipairs(AEvent.Popout.panels) do
            if not panel:IsVisible() then continue end
            panel:SetSize(size, twentyTwo)
            panel:SetPos(0, y)
            y = y + twentyTwo + self.margin
        end
    end

    for categoryID, categoryDATA in pairs(AEvent:GetCategories()) do
        for commandID, commandDATA in pairs(categoryDATA.Commands) do
            local button = AEvent.Popout.Scroll:Add("AEvent:Button")
            button:SetText(commandDATA.Name)
            button.DoClick = function()
                local extraSelections = commandDATA.ExtraSelection()
                local val, id = AEvent.Popout.Combo:GetSelected()
                id = commandDATA.IsOther and "other" or id

                if id == "target_usergroup_event" or id == "target_usergroup" then
                    extraSelections = extraSelections or {}
                    table.insert(extraSelections, 1, "temp")
                    extraSelections[1] = {
                        text = "",
                        Type = "Combo Input",
                        Options = usergroups,
                    }
                end
    
                if id == "target_name_event" or id == "target_name" then
                    extraSelections = extraSelections or {}
                    table.insert(extraSelections, 1, "temp")
                    extraSelections[1] = {
                        text = "",
                        Type = "String Input",
                        data = {},
                    }
                end
    
                if id == "target_team_event" or id == "target_team" then
                    extraSelections = extraSelections or {}
                    table.insert(extraSelections, 1, "temp")
                    extraSelections[1] = {
                        text = "",
                        Type = "Combo Input",
                        Options = teams,
                    }
                end

                if extraSelections then
                    Request_Answer(AEvent:GetPhrase("addon_name"), extraSelections, function(data)
                        data.targetType = id
                        table.Add(self.table, {{commandID = commandID, data = data}})
                        self:AddCommand()
                    end)
                else
                    table.Add(self.table, {{commandID = commandID, data = {targetType = id}}})
                    self:AddCommand(data)
                end
            end
            table.insert(AEvent.Popout.panels, button)
        end
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

    local tbl = table.Copy(self.table)
    self.table = {}
    self.panels = {}

    for _, v in ipairs(tbl) do
        self:AddCommand(v)
    end
end

function PANEL:AddCommand(DATA)
    if self.Broken then return end

    if DATA then
        table.Add(self.table, {DATA})
    end

    local int = #self.table
    local data = self.table[int]
    local text = ""
    if #data.data > 0 then
        // its a multi line selector option
        text = AEvent:FormatCommandPath(targetTypes[data.data.targetType], data.commandID)
        if not text then
            text = AEvent:GetPhrase("broken_command")
        else
            text = string.Replace(text, "...", "%s")

            local tbl = {}
            for _, v in ipairs(data.data) do
                table.insert(tbl, v.data.selected)
            end
            text = string.format(text, unpack(tbl))
            text = string.Replace(text, "%s", "...")
        end
    else
        text = AEvent:FormatCommandPath(targetTypes[data.data.targetType], data.commandID)
        text = text and string.Replace(text, "...", data.data.Selection or "") or AEvent:GetPhrase("broken_command")
    end

    local teams = {}
    for _, v in ipairs(team.GetAllTeams()) do
        table.Add(teams, {{
            text = v.Name,
            data = {}, -- You can store data here that can be called
        }})
    end

    local usergroups = {}
    for id, v in pairs(CAMI and CAMI:GetUsergroups() or {}) do
        table.Add(usergroups, {{
            text = v.Name,
            data = {}, -- You can store data here that can be called
        }})
    end

    local label = self:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(self.Header:GetTall() + self.margin, self.margin, self.margin, 0)
    label:SetFont("AEvent:14")
    label:SetTextColor(AEvent.Colors["white"])
    label:SetText(text)
    label:SizeToContents()
    label:SetMouseInputEnabled(true)
    label.tablePos = int
    label.DoRightClick = function(s)
        local menu = AEvent:DermaMenu()
        menu:AddOption(AEvent:GetPhrase("delete"), function()
            table.remove(self.table, s.tablePos)
            s:Remove()
            self:RefreshDeleted(s.tablePos)
        end)

        local panel, parent = menu:AddSubMenu(AEvent:GetPhrase("insert_above"))
        for id, str in pairs(targetTypes) do
            local panel, parent = panel:AddSubMenu(str, function() end)
            for categoryID, categoryDATA in pairs(AEvent:GetCategories()) do
                for commandID, commandDATA in pairs(categoryDATA.Commands) do
                    local extraSelections = commandDATA.ExtraSelection()
        
                    if id == "other" and not commandDATA.IsOther then
                        continue
                    end
        
                    if id ~= "other" and commandDATA.IsOther then
                        continue
                    end
        
                    if id == "target_usergroup_event" or id == "target_usergroup" then
                        extraSelections = extraSelections or {}
                        table.insert(extraSelections, 1, "temp")
                        extraSelections[1] = {
                            text = "",
                            Type = "Combo Input",
                            Options = usergroups,
                        }
                    end

                    if id == "target_name_event" or id == "target_name" then
                        extraSelections = extraSelections or {}
                        table.insert(extraSelections, 1, "temp")
                        extraSelections[1] = {
                            text = "",
                            Type = "String Input",
                            data = {},
                        }
                    end
        
                    if id == "target_team_event" or id == "target_team" then
                        extraSelections = extraSelections or {}
                        table.insert(extraSelections, 1, "temp")
                        extraSelections[1] = {
                            text = "",
                            Type = "Combo Input",
                            Options = teams,
                        }
                    end
        
                    if extraSelections then
                        local panel, parent = panel:AddOption(commandDATA.Name, function()
                            Request_Answer(AEvent:GetPhrase("addon_name"), extraSelections, function(data)
                                data.targetType = id

                                table.insert(self.table, s.tablePos, "placeholder")
                                self.table[s.tablePos] = {
                                    commandID = commandID,
                                    data = data,
                                }
                                self:RefreshInsertAbove(s.tablePos)
                                self:RefreshLayout()
                            end)
                        end)
                    else
                        local panel, parent = panel:AddOption(commandDATA.Name, function()
                            table.insert(self.table, s.tablePos, "placeholder")
                            self.table[s.tablePos] = {
                                commandID = commandID,
                                data = {targetType = id},
                            }
                            self:RefreshInsertAbove(s.tablePos)
                            self:RefreshLayout()
                        end)
                    end
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
    if not hookDATA then
        self.HookName:SetText(AEvent:GetPhrase("broken_command"))
        self.HookName:SizeToContents()
        self.Broken = true
        return
    end

    self.HookName:SetText(hookDATA.Name)
    self.HookName:SizeToContents()
end

local w2 = 2
function PANEL:Paint(w, h)
    surface.SetDrawColor(AEvent.Colors["secondary"].r, AEvent.Colors["secondary"].g, AEvent.Colors["secondary"].b, AEvent.Colors["secondary"].a)
    surface.DrawRect(0, 0, w, h)

    local radius = math.floor(AEvent:Scale(6))
    local x, y = self.margin + (self.Header:GetTall()/2) - (w2/2), AEvent:Scale(22)

    local fourTeen = AEvent:Scale(14) -- size of label font
    surface.SetDrawColor(AEvent.Colors["blue"].r, AEvent.Colors["blue"].g, AEvent.Colors["blue"].b, AEvent.Colors["blue"].a)
	surface.DrawRect(x - (fourTeen/2) + 1, self.margin + (self.Header:GetTall()/2) - (fourTeen/2), fourTeen, fourTeen)

    for _, v in ipairs(self.panels) do
        if not IsValid(v.panel) then continue end
        local x2, circleY = x + (w2/2), v.panel:GetY() + (radius + 1)
        surface.DrawCircle(x2, circleY, radius, AEvent.Colors["blue"].r, AEvent.Colors["blue"].g, AEvent.Colors["blue"].b, AEvent.Colors["blue"].a) 

        surface.SetDrawColor(AEvent.Colors["blue"].r, AEvent.Colors["blue"].g, AEvent.Colors["blue"].b, AEvent.Colors["blue"].a)
        surface.DrawRect(x2 - (w2/2), y, w2, circleY - y - radius)
        y = y + (circleY - y) + (radius)
    end

    --surface.SetDrawColor(AEvent.Colors["blue"].r, AEvent.Colors["blue"].g, AEvent.Colors["blue"].b, AEvent.Colors["blue"].a)
    --surface.DrawRect(x + (w2/2) - (w2/2), y, w2, h - y)
end

function PANEL:PerformLayout(w, h)
    local extra = 0
    for _, v in ipairs(self.panels) do
        if not IsValid(v.panel) then continue end
        extra = extra + v.panel:GetTall() + self.margin
    end
    self:SetTall(AEvent:Scale(80) + extra)
end

vgui.Register("AEvent:HookPanel", PANEL, "EditablePanel")