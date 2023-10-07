local function CreateTable()
    sql.Query("CREATE TABLE IF NOT EXISTS AEvent (id TEXT, data TEXT)")
    sql.Query("CREATE TABLE IF NOT EXISTS AEvent_presets (id TEXT, data TEXT)")
end
CreateTable()

function AEvent:SaveEvent(id, data)
    local data = util.TableToJSON(data)
    if sql.Query("SELECT * FROM AEvent WHERE id = "..sql.SQLStr(id)..";") then
        sql.Query("UPDATE AEvent SET data = "..sql.SQLStr(data).." WHERE id = "..sql.SQLStr(id)..";")
    else
        sql.Query("INSERT INTO AEvent (id, data) VALUES("..sql.SQLStr(id)..", "..sql.SQLStr(data)..")")
    end
end

function AEvent:RemoveEvent(id)
    sql.Query("DELETE FROM AEvent WHERE id = "..sql.SQLStr(id)..";")
end

function AEvent:GetEvent(id)
    local data = sql.Query("SELECT * FROM AEvent WHERE id = "..sql.SQLStr(id)..";")
    return data and util.JSONToTable(data[1].data) or {}
end

function AEvent:GetAllEvents()
    local data = sql.Query("SELECT * FROM AEvent;")
    local tbl = {}
    for _, v in ipairs(data or {}) do
        table.Add(tbl, {util.JSONToTable(v.data)})
    end
    return tbl
end


function AEvent:SavePreset(id, data)
    local data = util.TableToJSON(data)
    if sql.Query("SELECT * FROM AEvent_presets WHERE id = "..sql.SQLStr(id)..";") then
        sql.Query("UPDATE AEvent_presets SET data = "..sql.SQLStr(data).." WHERE id = "..sql.SQLStr(id)..";")
    else
        sql.Query("INSERT INTO AEvent_presets (id, data) VALUES("..sql.SQLStr(id)..", "..sql.SQLStr(data)..")")
    end
end

function AEvent:DeletePreset(id)
    sql.Query("DELETE FROM AEvent_presets WHERE id = "..sql.SQLStr(id)..";")
end

function AEvent:RenamePreset(id, name)
    local data = AEvent:GetPreset(id)
    data.name = name

    AEvent:SavePreset(id, data)
end

function AEvent:GetPreset(id)
    local data = sql.Query("SELECT * FROM AEvent_presets WHERE id = "..sql.SQLStr(id)..";")
    return data and util.JSONToTable(data[1].data) or {}
end

function AEvent:GetAllPresets(id)
    local data = sql.Query("SELECT * FROM AEvent_presets;")
    local tbl = {}
    for _, v in ipairs(data or {}) do
        table.Add(tbl, {util.JSONToTable(v.data)})
    end
    return tbl
end