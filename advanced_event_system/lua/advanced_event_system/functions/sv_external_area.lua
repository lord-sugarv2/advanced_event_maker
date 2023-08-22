local function IsPlayerBetweenPoints(ply, pointA, pointB)
    local playerPosition = ply:GetPos()
    if playerPosition.x >= math.min(pointA.x, pointB.x) and playerPosition.x <= math.max(pointA.x, pointB.x) then
        if playerPosition.y >= math.min(pointA.y, pointB.y) and playerPosition.y <= math.max(pointA.y, pointB.y) then
            if playerPosition.z >= math.min(pointA.z, pointB.z) and playerPosition.z <= math.max(pointA.z, pointB.z) then
                return true
            end
        end
    end

    return false
end

function AEvent:IsInArea(ply, cornerOne, cornerTwo)
    return IsPlayerBetweenPoints(ply, cornerOne, cornerTwo)
end

AEvent.Areas = AEvent.Areas or {}
AEvent.Players = AEvent.Players or {}

function AEvent:IsInID(ply, id)
    for _, data in ipairs(AEvent.Areas) do
        if data.mainID ~= id then continue end
        return AEvent:IsInArea(ply, data.cornerOne, data.cornerTwo)
    end
end

function AEvent:GetIDData(ply, id)
    for _, data in ipairs(AEvent.Areas) do
        if data.mainID ~= id then continue end
        return data
    end
end

function AEvent:OnEnterArea(cornerOne, cornerTwo, func, mainID)
    func = func or function() end
    mainID = mainID or math.random(1, 999999)

    for k, v in ipairs(AEvent.Areas) do
        if v.mainID == mainID then
            table.remove(AEvent.Areas, k)
            break
        end
    end

    table.Add(AEvent.Areas, {{
        mainID = mainID,
        id = tostring(cornerOne + cornerTwo),
        cornerOne = cornerOne,
        cornerTwo = cornerTwo,
        type = "OnEnter",
        func = func,
    }})
end

function AEvent:OnExitArea(cornerOne, cornerTwo, func, mainID)
    func = func or function() end
    mainID = mainID or math.random(1, 999999)

    for k, v in ipairs(AEvent.Areas) do
        if v.mainID == mainID then
            table.remove(AEvent.Areas, k)
            break
        end
    end

    table.Add(AEvent.Areas, {{
        mainID = mainID,
        id = tostring(cornerOne + cornerTwo),
        cornerOne = cornerOne,
        cornerTwo = cornerTwo,
        type = "OnExit",
        func = func,
    }})
end

function AEvent:WhileInArea(cornerOne, cornerTwo, func, mainID)
    func = func or function() end
    mainID = mainID or math.random(1, 999999)

    for k, v in ipairs(AEvent.Areas) do
        if v.mainID == mainID then
            table.remove(AEvent.Areas, k)
            break
        end
    end

    table.Add(AEvent.Areas, {{
        mainID = mainID,
        id = tostring(cornerOne + cornerTwo),
        cornerOne = cornerOne,
        cornerTwo = cornerTwo,
        type = "WhileIn",
        func = func,
    }})
end

function AEvent:WhileNotInArea(cornerOne, cornerTwo, func, mainID)
    func = func or function() end
    mainID = mainID or math.random(1, 999999)

    for k, v in ipairs(AEvent.Areas) do
        if v.mainID == mainID then
            table.remove(AEvent.Areas, k)
            break
        end
    end

    table.Add(AEvent.Areas, {{
        mainID = mainID,
        id = tostring(cornerOne + cornerTwo),
        cornerOne = cornerOne,
        cornerTwo = cornerTwo,
        type = "WhileNotIn",
        func = func,
    }})
end

function AEvent:JoinAreas(idOne, idTwo)
    local areaOne = 0
    local areaTwo = 0
    for k, v in ipairs(AEvent.Areas) do
        if v.mainID == idOne then
            areaOne = k
        end
    
        if v.mainID == idTwo then
            areaTwo = k
        end
    end

    if areaOne == 0 or areaTwo == 0 then return end
    AEvent.Areas[areaOne].Joined = idTwo
    AEvent.Areas[areaTwo].Joined = idOne
end

local function InArea(ply, data)
    print(AEvent.Players[ply][data.id])

    if data.type == "OnEnter" and not AEvent.Players[ply][data.id] then
        if data.Joined and AEvent:IsInID(ply, data.Joined) then
            AEvent.Players[ply][data.id] = true
            return
        end
    
        data.func(ply, data.cornerOne, data.cornerTwo)
        AEvent.Players[ply][data.id] = true
    end

    if data.type == "WhileIn" then
        data.func(ply, data.cornerOne, data.cornerTwo)
    end
end

local function NotInArea(ply, data)
    if data.Joined and AEvent:IsInID(ply, data.Joined) then
        return
    end

    if data.type == "OnExit" and AEvent.Players[ply][data.id] then
        data.func(ply, data.cornerOne, data.cornerTwo)
        AEvent.Players[ply][data.id] = false
        if data.Joined then
            AEvent.Players[ply][AEvent:GetIDData(ply, data.Joined).id] = false
        end
    end

    if data.type == "WhileNotIn" and not AEvent.Players[ply][data.id] then
        data.func(ply, data.cornerOne, data.cornerTwo)
    end
end

local time = CurTime()
hook.Add("Think", "AEvent:Areas", function()
    if CurTime() < time then return end
    time = time + 0.2
   -- if not AEvent.CurrentEvent or not AEvent.CurrentEvent.IsActive then return end

    for _, ply in ipairs(player.GetAll()) do
        for _, data in ipairs(AEvent.Areas) do
            AEvent.Players[ply] = AEvent.Players[ply] or {}
            local inArea = AEvent:IsInArea(ply, data.cornerOne, data.cornerTwo)
            if inArea and ply:Alive() then
                InArea(ply, data)
            else
                NotInArea(ply, data)
            end
            AEvent.Players[ply][data.id] = inArea and true or false
        end
    end
end)

function AEvent:PlayersWithinDistance(pos, dist)
    local distSqr = dist * dist
    local tbl = {}
    for k, ply in ipairs(player.GetAll()) do
        if ply:GetPos():DistToSqr(pos) > distSqr then continue end
        table.insert(tbl, ply)
    end
	return tbl
end

function AEvent:RemoveArea(mainID)
    for k, v in ipairs(AEvent.Areas) do
        if v.mainID == mainID then
            table.remove(AEvent.Areas, k)
            break
        end
    end
end

function AEvent:ClearAll()
    AEvent.Areas = {}
end

hook.Run("AEvent:AreasLoaded")
