local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:JoinPopup"
MODULE.Name = "Join Popups"

MODULE:AddCommand({
    ID = "Command:JoinPopup:Enable",
    Name = "enable join event popup",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        local safeTbl = {}
        for _, ply in ipairs(data.players) do
            if AEvent:IsInEvent(ply) then continue end
            table.insert(safeTbl, ply)
            ply.AEventCanJoin = true
        end

        net.Start("AEvent:JoinPopup")
        net.WriteBool(true) -- enable it: false removes it
        net.Send(data.players)
    end,
})

MODULE:AddCommand({
    ID = "Command:JoinPopup:Disable",
    Name = "disable join event popup",
    IsOther = true,
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        local safeTbl = {}
        for _, ply in ipairs(data.players) do
            if AEvent:IsInEvent(ply) then continue end
            table.insert(safeTbl, ply)
            ply.AEventCanJoin = false
        end

        net.Start("AEvent:JoinPopup")
        net.WriteBool(false) -- enable it: false removes it
        net.Send(data.players)
    end,
})

AEvent:CreateCommand(MODULE)