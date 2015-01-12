
function table.hasvalue(tbl, val)
    for _, v in pairs(tbl) do
        if val == v then return true end
    end
    return false
end

function table.removeonevalue(tbl, val)
    for i, v in pairs(tbl) do
        if val == v then table.remove(tbl, i) break end
    end
end

function table.removevalue(tbl, val)
    while table.hasvalue(tbl, val) do
        for i, v in pairs(tbl) do
            if val == v then table.remove(tbl, i) break end
        end
    end
end

function table.clear(tbl)
    for k,v in pairs(tbl) do
        tbl[k] = nil
    end
end

function table.copyto(from, to)
    for k,v in pairs(from) do
        to[k] = from[k]
    end
end
