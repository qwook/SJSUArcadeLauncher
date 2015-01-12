
function math.dotproduct(x1, y1, z1, x2, y2, z2)
    return x1*x2 + y1*y2 + z1*z2
end

function math.crossproduct(x1, y1, z1, x2, y2, z2)
    return y1*z2 - y2*z1, z1*x2 - z2*x1, x1*y2 - x2*y1
end

function math.length(x, y)
    return math.sqrt(x*x + y*y)
end

function math.distance(x1, y1, x2, y2)
    return math.length(x1 - x2, y1 - y2)
end

function math.normal(x, y)
    local len = math.length(x, y)
    return x / len, y / len
end

function math.clamp(input, min, max)
    if (min > max) then
        local _ = min
        min = max
        max = _
    end

    if (input < min) then return min end
    if (input > max) then return max end

    return input
end

function math.sign(n)
    if (n > 0) then return 1 end
    if (n < 0) then return -1 end
    return 0
end

function math.approach(start, _end, inc)
    return math.clamp(start + inc, start, _end)
end

function math.approach2(start, _end, inc)
    local dir = math.sign(_end - start)
    return math.clamp(start + (dir * inc), start, _end)
end

function math.lerp(x1, y1, x2, y2, alpha)
    local dist = math.distance(x1, y1, x2, y2)
    return math.approach2(x1, x2, alpha * dist), math.approach2(y1, y2, alpha * dist)
end

function math.lerpAngle(start, _end, inc)
    local x, y, cross = math.crossproduct(math.cos(start), math.sin(start), 0, math.cos(_end), math.sin(_end), 0)
    local sign = math.sign(cross)

    local result = start + inc*sign

    local x, y, cross2 = math.crossproduct(math.cos(result), math.sin(result), 0, math.cos(_end), math.sin(_end), 0)
    local sign2 = math.sign(cross2)

    if sign == sign2 then
        return result
    else
        return _end
    end
end

function math.round(num)
    if (num - math.floor(num)) < 0.5 then
        return math.floor(num)
    else
        return math.ceil(num)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- tween.lua - v1.0.1 (2012-02)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- tweening functions for lua
-- inspired by jquery's animate function
-----------------------------------------------------------------------------------------------------------------------

-- bounce
function math.outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end
