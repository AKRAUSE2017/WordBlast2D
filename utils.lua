Utils = Class{}

function Utils:collision(proj, let)
    projectileLeftEdge = proj.x
    projectileRightEdge = proj.x + proj.width
    projectileBtmEdge = proj.y + proj.height
    projectileTopEdge = proj.y

    letterLeftEdge = let.x
    letterRightEdge = let.x + let.width
    letterTopEdge = let.y
    letterBtmEdge = let.y + let.height

    case1 = projectileRightEdge > letterLeftEdge and projectileRightEdge < letterRightEdge and projectileBtmEdge > letterTopEdge and projectileTopEdge < letterBtmEdge
    case2 = projectileLeftEdge < letterRightEdge and projectileLeftEdge > letterLeftEdge and projectileBtmEdge > letterTopEdge and projectileTopEdge < letterBtmEdge

    return case1 or case2
end

function Utils:shuffleTable(tbl)
    local n = #tbl
    for i = n, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function Utils:isInTable(elem, table)
    local i = 1
    while i <= #table do
        if table[i] == elem then
            return true
        end
        i = i + 1
    end
    return false
end

function Utils:round(number, digit_position) 
    local precision = math.pow(10, digit_position)
    number = number + (precision / 2); -- this causes value #.5 and up to round up
                                       -- and #.4 and lower to round down.
    return math.floor(number / precision) * precision
end