local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:God"
MODULE.Name = "God"

MODULE:AddCommand({
    ID = "Command:God:WithName",
    Name = "god everyone with '...' in thier name",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            local start, startend = string.find(string.lower(ply:Nick()), string.lower(data.Selection))
            if start then
                ply:GodEnable()
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:God:AsTeam",
    Name = "god everyone as team '...'",
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
                ply:GodEnable()
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:God:InEvent",
    Name = "god everyone in the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(AEvent:GetPlayersInEvent()) do
            ply:GodEnable()
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:God:CausedTrigger",
    Name = "god person who caused this trigger to happen",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        if not IsValid(data.playerSupplied) then return end
        data.playerSupplied:GodEnable()
    end,
})

MODULE:AddCommand({
    ID = "Command:UnGod:InEvent",
    Name = "ungod everyone in event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, v in ipairs(player.GetAll()) do
            v:GodDisable()
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:UnGod:WithName",
    Name = "ungod everyone with '...' in thier name",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        for _, ply in ipairs(player.GetAll()) do
            local start, startend = string.find(string.lower(ply:Nick()), string.lower(data.Selection))
            if start then
                ply:GodDisable()
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:UnGod:AsTeam",
    Name = "ungod everyone as team '...'",
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
                ply:GodDisable()
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:UnGod:CausedTrigger",
    Name = "ungod person who caused this trigger to happen",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        if not IsValid(data.playerSupplied) then return end
        data.playerSupplied:GodDisable()
    end,
})
AEvent:CreateCommand(MODULE)