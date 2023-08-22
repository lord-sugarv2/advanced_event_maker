local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Freeze"
MODULE.Name = "Freeze"

MODULE:AddCommand({
    ID = "Command:Freeze:WithName",
    Name = "freeze everyone with '...' in thier name",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            local start, startend = string.find(string.lower(ply:Nick()), string.lower(data.Selection))
            if start then
                ply:Freeze(true)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Freeze:AsTeam",
    Name = "freeze everyone as team '...'",
    ExtraSelection = function()
        local tbl = {}
        for _, job in ipairs(team.GetAllTeams()) do
            table.Add(tbl, {{
                Text = job.Name,
                Data = {Job = job.Name},
            }})
        end
        return tbl
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            if string.lower(team.GetName(ply:Team())) == string.lower(data.Job) then
                ply:Freeze(true)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Freeze:InEvent",
    Name = "freeze everyone in the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(AEvent:GetPlayersInEvent()) do
            ply:Freeze(true)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Freeze:CausedTrigger",
    Name = "freeze person who caused this trigger to happen",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        if not IsValid(data.playerSupplied) then return end
        data.playerSupplied:Freeze(true)
    end,
})

MODULE:AddCommand({
    ID = "Command:UnFreeze:InEvent",
    Name = "unfreeze everyone in event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, v in ipairs(player.GetAll()) do
            v:Freeze(false)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:UnFreeze:WithName",
    Name = "unfreeze everyone with '...' in thier name",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            local start, startend = string.find(string.lower(ply:Nick()), string.lower(data.Selection))
            if start then
                ply:Freeze(false)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:UnFreeze:AsTeam",
    Name = "unfreeze everyone as team '...'",
    ExtraSelection = function()
        local tbl = {}
        for _, job in ipairs(team.GetAllTeams()) do
            table.Add(tbl, {{
                Text = job.Name,
                Data = {Job = job.Name},
            }})
        end
        return tbl
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            if string.lower(team.GetName(ply:Team())) == string.lower(data.Job) then
                ply:Freeze(false)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:UnFreeze:CausedTrigger",
    Name = "unfreeze person who caused this trigger to happen",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        if not IsValid(data.playerSupplied) then return end
        data.playerSupplied:Freeze(false)
    end,
})
AEvent:CreateCommand(MODULE)