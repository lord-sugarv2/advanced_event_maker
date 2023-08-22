-- Timers are special they get unique properties
-- and get fed all the upcoming commands

AEvent.Timers = AEvent.Timers or {}
local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Timers"
MODULE.Name = "Timers"

MODULE:AddCommand({
    ID = "Command:Timers:SilentCountdown",
    Name = "wait '...'s (silently)",
    IsTimer = true,
    ExtraSelection = function()
        return {"String Input", "input a number"}
    end,
    RunCommand = function(data, callback)
        local time = data.Selection
        time = tonumber(time)
        if not isnumber(time) then
            print("[ AEvent ] BROKEN TIMER '"..time.."' PLEASE FIX")
            print("[ AEvent ] SET TIMER AT TEMPORARY 3s")
            time = 3
        end

        local str = AEvent:GenerateID(20)
        table.insert(AEvent.Timers, str)
        timer.Create(str, time, 1, function()
            callback()
        end)
    end,
})

MODULE:AddCommand({
    ID = "Command:Timers:ScreenCount",
    Name = "wait '...'s (screen countdown for people in the event)",
    IsTimer = true,
    ExtraSelection = function()
        return {"String Input", "input a number"}
    end,
    RunCommand = function(data, callback)
        local time = data.Selection
        time = tonumber(time)
        if not isnumber(time) then
            print("[ AEvent ] BROKEN SCREEN TIMER '"..time.."' PLEASE FIX")
            print("[ AEvent ] SET TIMER AT TEMPORARY 3s")
            time = 3
        end

        for _, ply in ipairs(AEvent:GetPlayersInEvent()) do
            net.Start("AEvent:ScreenCountdown")
            net.WriteUInt(time, 32)
            net.Send(AEvent:GetPlayersInEvent())
        end

        local str = AEvent:GenerateID(20)
        table.insert(AEvent.Timers, str)
        timer.Create(str, time, 1, function()
            callback()
        end)
    end,
})

AEvent:CreateCommand(MODULE)

if CLIENT then
    surface.CreateFont("AEvent:MegaLarge", {
        font = "Arial",
        size = 67,
        weight = 500,
    } )

    net.Receive("AEvent:ScreenCountdown", function()
        local time = net.ReadUInt(32)
        table.Add(AEvent.Timers, {{
            time = time + CurTime(),
        }})
    end)

    net.Receive("AEvent:EventStopped", function()
        AEvent.Timers = {}
        AEvent.KillBoxes = {}
    end)

    hook.Add("HUDPaint", "AEvent:DrawHud", function()
        local y = ScrH()*.1
        for int, v in ipairs(AEvent.Timers) do
            local time = v.time-CurTime()
            if time < 0 then table.remove(AEvent.Timers, int) continue end
            local niceTime = math.max(math.Round(v.time-CurTime()), 0).."s"
            draw.SimpleText(niceTime, "AEvent:MegaLarge", ScrW()/2 + 2, y + 2, color_black, 1, 0)
            draw.SimpleText(niceTime, "AEvent:MegaLarge", ScrW()/2, y, color_white, 1, 0)
            y = y + 70
        end
    end)
else
    util.AddNetworkString("AEvent:ScreenCountdown")
    util.AddNetworkString("AEvent:EventStopped")
    hook.Add("AEvent:EventStopped", "AEvent:EventStopped", function()
        for _, v in ipairs(AEvent.Timers) do
            timer.Remove(v)
        end

        AEvent.Timers = {}

        net.Start("AEvent:EventStopped")
        net.Broadcast()
    end)
end