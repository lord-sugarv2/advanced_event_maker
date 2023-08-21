AEvent = AEvent or {}
AEvent.PreFix = "event"
AEvent.Locations = {
    {name = "Home", pos = Vector(-769.406067, -539.170288, -12223.968750)},
    {name = "Base", pos = Vector(0, 0, -12223.968750)}

}

function AEvent:LocationToPos(str)
    for k, v in ipairs(AEvent.Locations) do
        if v.name == str then return v.pos end
    end
    return false
end