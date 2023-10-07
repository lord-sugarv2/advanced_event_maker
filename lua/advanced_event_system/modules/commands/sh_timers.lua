-- timers are special they get unique properties
-- and get fed all the upcoming commands

local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Timer"
MODULE.Name = "Timers"

MODULE:AddCommand({
    ID = "Command:Timer:Silent",
    Name = "silent timer",
    IsTimer = true,
    ExtraSelection = function()
        return {
            {
                text = "seconds",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data, callback)
        local time = data.data[1].selected
        time = tonumber(time)
        local str = AEvent:GenerateID(20)
        table.insert(AEvent.Timers, str)
        timer.Create(str, time, 1, function()
            callback()
        end)
    end,
})

MODULE:AddCommand({
    ID = "Command:Timer:ScreenCountdown",
    Name = "screen countdown",
    IsTimer = true,
    ExtraSelection = function()
        return {
            {
                text = "seconds to wait + countdown",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data, callback)
        local time = data.data[1].selected
        time = tonumber(time)
        net.Start("AEvent:ScreenCountdown")
        net.WriteUInt(time, 32)
        net.Send(data.players)

        local str = AEvent:GenerateID(20)
        table.insert(AEvent.Timers, str)
        timer.Create(str, time, 1, function()
            callback()
        end)
    end,
})

AEvent:CreateCommand(MODULE)