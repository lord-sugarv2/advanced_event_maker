AEvent.Areas = AEvent.Areas or {}
function AEvent:OnEnterArea(cornerOne, cornerTwo, func, mainID)
    local ent = ents.Create("aevents_brush")
    ent.boxFunction = function(ply)
        func(ply)
    end
    ent.cornerOne = cornerOne 
    ent.cornerTwo = cornerTwo
    ent.mainID = mainID
    ent:Spawn()
    AEvent.Areas[mainID] = ent
end

function AEvent:RemoveArea(mainID)
    if not AEvent.Areas[mainID] then return end
    AEvent.Areas[mainID]:Remove()
    AEvent.Areas[mainID] = false
end

function AEvent:ClearAllAreas()
    if not AEvent.Areas[mainID] then return end
    AEvent.Areas[mainID]:Remove()
    AEvent.Areas[mainID] = false
end
hook.Run("AEvent:AreasLoaded")