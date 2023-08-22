local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Kill"
MODULE.Name = "Kill"

MODULE:AddCommand({
    ID = "Command:Kill:WithName",
    Name = "everyone with '...' in thier name",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            local start, startend = string.find(string.lower(ply:Nick()), string.lower(data.Selection))
            if start then
                ply:Kill()
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Kill:AsTeam",
    Name = "everyone as team '...'",
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
                ply:Kill()
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Kill:InEvent",
    Name = "everyone in the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(AEvent:GetPlayersInEvent()) do
            ply:Kill()
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Kill:CausedTrigger",
    Name = "person who caused the trigger to happen",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        if not IsValid(data.playerSupplied) then return end
        data.playerSupplied:Kill()
    end,
})

AEvent:CreateCommand(MODULE)