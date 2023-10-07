local function NameToIndex(teamName)
    for index, v in ipairs(team.GetAllTeams()) do
        if v.Name == teamName then
            return index
        end
    end
    return false
end

local function FormatJobs()
    local tbl = {}
    for _, v in ipairs(team.GetAllTeams()) do
        table.Add(tbl, {{
            text = v.Name,
            data = {},
        }})
    end
    return tbl
end

local function SplitBetweenTeams(numTeams, data)
    local players = data.players
    local numPlayers = #players
    local playersPerTeam = math.floor(numPlayers / numTeams)

    local teamCounter = 1
    for _, ply in pairs(players) do
        local teamIndex = NameToIndex(data.data[teamCounter].selected)
        if not teamIndex then print("[ AEvent ] 'Split Teams' '"..data.data[teamCounter].selected.."' "..AEvent:GetPhrase("broken_command")) return end

        if DarkRP then
            ply:changeTeam(teamIndex, true)
        else
            ply:SetTeam(teamIndex)
            ply:Spawn()    
        end

        teamCounter = teamCounter + 1
        if teamCounter > numTeams then
            teamCounter = 1
        end
    end
end

local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:SplitTeams"
MODULE.Name = "Split between Teams"

MODULE:AddCommand({
    ID = "Command:SplitTeams:Split",
    Name = "split between 2 teams '...' + '...'",
    ExtraSelection = function()
        return {
            {
                text = "first team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
            {
                text = "second team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        local numTeams = 2
        SplitBetweenTeams(numTeams, data)
    end,
})

MODULE:AddCommand({
    ID = "Command:SplitTeams:SplitThree",
    Name = "split between 3 teams '...' + '...' + '...'",
    ExtraSelection = function()
        return {
            {
                text = "first team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
            {
                text = "second team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
            {
                text = "third team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        local numTeams = 3
        SplitBetweenTeams(numTeams, data)
    end,
})

MODULE:AddCommand({
    ID = "Command:SplitTeams:SplitFour",
    Name = "split between 4 teams '...' + '...' + '...' + '...'",
    ExtraSelection = function()
        return {
            {
                text = "first team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
            {
                text = "second team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
            {
                text = "third team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
            {
                text = "fourth team",
                Type = "Combo Input",
                Options = FormatJobs(),
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        local numTeams = 4
        SplitBetweenTeams(numTeams, data)
    end,
})

AEvent:CreateCommand(MODULE)