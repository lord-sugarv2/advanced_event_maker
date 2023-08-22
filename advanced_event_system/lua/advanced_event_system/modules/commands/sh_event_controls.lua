local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:EventControls"
MODULE.Name = "Event Controls"

MODULE:AddCommand({
    ID = "Command:EventControls:AddAll",
    Name = "add everyone to the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            AEvent:AddPlayerToEvent(ply)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:AddTeam",
    Name = "add team '...' to the event",
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
                AEvent:AddPlayerToEvent(ply)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:AddWithName",
    Name = "add people with '...' in thier name to the event",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            local start, startend = string.find(string.lower(ply:Nick()), string.lower(data.Selection))
            if start then
                AEvent:AddPlayerToEvent(ply)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:AddCausedEvent",
    Name = "add the person who caused this trigger to the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        if IsValid(data.playerSupplied) then
            AEvent:AddPlayerToEvent(data.playerSupplied)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:StopEvent",
    Name = "stop the current event (commands still to be proccessed will be run)",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        AEvent:StopEvent()
    end,
})





MODULE:AddCommand({
    ID = "Command:EventControls:RemoveAll",
    Name = "remove everyone in the event from the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(AEvent:GetPlayersInEvent()) do
            AEvent:RemovePlayerFromEvent(ply)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:RemoveTeam",
    Name = "remove team '...' from the event",
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
            if not AEvent:IsInEvent(ply) then continue end
            if string.lower(team.GetName(ply:Team())) == string.lower(data.Job) then
                AEvent:RemovePlayerFromEvent(ply)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:RemoveWithName",
    Name = "remove people with '...' in thier name from the event",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            if not AEvent:IsInEvent(ply) then continue end
            local start, startend = string.find(string.lower(ply:Nick()), string.lower(data.Selection))
            if start then
                AEvent:RemovePlayerFromEvent(ply)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:RemoveCausedEvent",
    Name = "remove the person who caused this trigger from the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        if IsValid(data.playerSupplied) then
            AEvent:RemovePlayerFromEvent(data.playerSupplied)
        end
    end,
})

AEvent:CreateCommand(MODULE)