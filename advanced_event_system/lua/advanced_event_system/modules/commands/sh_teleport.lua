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
                Data = {Job = job.Name, Example = "Hello World!"},
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

AEvent:CreateCommand(MODULE)