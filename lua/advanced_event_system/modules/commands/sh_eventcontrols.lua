local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:EventControls"
MODULE.Name = "Event Controls"

MODULE:AddCommand({
    ID = "Command:EventControls:AddToEvent",
    Name = "add to event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            AEvent:AddPlayerToEvent(ply)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:RemoveFromEvent",
    Name = "remove from event",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            AEvent:AddPlayerToEvent(ply)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:EventControls:StopEvent",
    Name = "stop the event",
    IsOther = true,
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        AEvent:StopEvent()
    end,
})

AEvent:CreateCommand(MODULE)