-- Azhukar
-- This work is licensed under the Creative Commons Attribution 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/deed.en_US.

local function get(t,x,y)
    if (t[x]) then return t[x][y] end
end

local function set(t,x,y,v)
    if (t[x]) then t[x][y] = v
    else t[x] = {[y]=v} end
end

local function addVertice(vertices,w,h,x1,y1,x2,y2)
    x1,y1,x2,y2 = x1*w,y1*h,x2*w,y2*h
    local point = get(vertices,x1,y1)
    if (point) then --overlap
        point[3],point[4] = x2,y2
    else
        set(vertices,x1,y1,{x2,y2})
    end
end

local function traceTiles(tiles,w,h)
    local vertices = {}
    local polylines = {}
    local polylinesCount = 0

    for x,row in pairs(tiles) do
        for y,value in pairs(row) do
            if (not get(tiles,x-1,y)) then --left
                addVertice(vertices,w,h,x,y+1,x,y) --bottom to top
            end
            if (not get(tiles,x+1,y)) then --right
                addVertice(vertices,w,h,x+1,y,x+1,y+1) --top to bottom
            end
            if (not get(tiles,x,y-1)) then --top
                addVertice(vertices,w,h,x,y,x+1,y) --left to right
            end
            if (not get(tiles,x,y+1)) then --bottom
                addVertice(vertices,w,h,x+1,y+1,x,y+1) --right to left
            end
        end
    end
    
    for sx,row in pairs(vertices) do
        for sy,value in pairs(row) do
            while (get(vertices,sx,sy)) do
                local point = get(vertices,sx,sy) --prepare starting vertex
                local x1,y1 = sx,sy
                local x2,y2
                if (point[3]) then --overlap
                    x2,y2 = point[3],point[4]
                    point[3],point[4] = nil,nil
                else
                    x2,y2 = point[1],point[2]
                    set(vertices,x1,y1,nil) --vertex done
                end
                
                local points = {x1,y1,x2,y2}
                local pointsCount = 4
                polylines[polylinesCount+1] = points
                polylinesCount = polylinesCount+1
                
                while (get(vertices,x2,y2)) do
                    local nextPoint = get(vertices,x2,y2)
                    if (nextPoint[3]) then
                        local xa,ya,xb,yb = nextPoint[1],nextPoint[2],nextPoint[3],nextPoint[4]
                        nextPoint[3],nextPoint[4] = nil,nil
                        if ((x1 < x2) and (ya > yb))
                        or ((x1 > x2) and (ya < yb))
                        or ((y1 < y2) and (xa < xb))
                        or ((y1 > y2) and (xa > xb)) then --always turn to the (relative) right
                            x1,y1 = x2,y2
                            x2,y2 = xa,ya
                            nextPoint[1],nextPoint[2] = xb,yb
                        else
                            x1,y1 = x2,y2
                            x2,y2 = xb,yb
                        end
                    else
                        set(vertices,x2,y2,nil) --vertex done
                        x1,y1 = x2,y2
                        x2,y2 = nextPoint[1],nextPoint[2]
                    end
                    local px,py = points[pointsCount-3],points[pointsCount-2]
                    if (px==x2) then --same direction as previous, overwrite
                        points[pointsCount] = y2
                    elseif (py==y2) then --same direction as previous, overwrite
                        points[pointsCount-1] = x2
                    else --different direction
                        points[pointsCount+1],points[pointsCount+2] = x2,y2
                        pointsCount = pointsCount + 2
                    end
                end
                
                local xa,ya,xb,yb = points[3],points[4],points[pointsCount-3],points[pointsCount-2]
                if (xa==xb or ya==yb) then --remove redundant start point
                    points[1],points[2] = xb,yb
                    points[pointsCount-1],points[pointsCount] = nil,nil
                end
            end
        end
    end
    
    return polylines
end

return traceTiles
