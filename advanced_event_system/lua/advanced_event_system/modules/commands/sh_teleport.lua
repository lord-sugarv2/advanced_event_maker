local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Bring" -- THIS NEEDS TO BE A UNIQUE ID
MODULE.Name = "Bring" -- Nicer name for the id to be displayed as

local function GetLocations(str)
    local tbl = {}
    for _, v in ipairs(AEvent.Locations) do
        table.Add(tbl, {{Text = v.name, Data = {Location = v.name, Job = str}}})
    end
    return tbl
end

MODULE:AddCommand({
    ID = "COMMAND:BRING:EVERYONEWITHEVENT",
    Name = "everyone with "..AEvent.PreFix.." in thier name to '...'",
    ExtraSelection = function()
        local tbl = GetLocations("with prefix in name")
        return tbl
    end,
    RunCommand = function()
    end,
})

MODULE:AddCommand({
    ID = "COMMAND:BRING:EVERYONE",
    Name = "everyone around the map to '...'",
    ExtraSelection = function()
        local tbl = GetLocations("everyone")
        return tbl
    end,
    RunCommand = function()
    end,
})

for _, job in ipairs(team.GetAllTeams()) do
    MODULE:AddCommand({
        ID = "COMMAND:BRING:"..job.Name,
        Name = job.Name.." to '...'",
        ExtraSelection = function()
            local tbl = GetLocations(job.Name)
            return tbl
        end,
        RunCommand = function(data)
            for _, ply in ipairs(player.GetAll()) do
                if team.GetName(ply:Team()) ~= data.Job then continue end

                local pos = AEvent:LocationToPos(data.Location)
                if not pos then continue end
                ply:SetPos(pos)
            end
        end,
    })
end

AEvent:CreateCommand(MODULE)


local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Kill" -- THIS NEEDS TO BE A UNIQUE ID
MODULE.Name = "Kill" -- Nicer name for the id to be displayed as

MODULE:AddCommand({
    ID = "COMMAND:KILL:EVERYONE",
    Name = "everyone",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function()
    end,
})

MODULE:AddCommand({
    ID = "COMMAND:KILL:EVERYONEINEVENT",
    Name = "everyone in the event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function()
    end,
})


AEvent:CreateCommand(MODULE)