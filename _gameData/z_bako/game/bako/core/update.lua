
local updateList = {}
function onNextUpdate(cb)
    table.insert(updateList, cb)
end

local timeouts = {}
function setTimeout(cb, delay)
    table.insert(timeouts, {cb = cb, delay = love.timer.getTime() + delay})
end

function clearUpdates()
    table.clear(timeouts)
    table.clear(updateList)
end

function love.update(dt)

    local tmp = {}
    for k,v in pairs(timeouts) do
        if (love.timer.getTime() > v.delay) then
            v.cb()
        else
            table.insert(tmp, v)
        end
    end
    table.clear(timeouts)
    table.copyto(tmp, timeouts)

    -- update joystick axes detection
    -- its stupid we can do better
    inputUpdate(dt)

    input:update(dt)
    input2:update(dt)

    cameraLife = cameraLife - dt

    if input:wasKeyPressed("select") or input2:wasKeyPressed("select") then
        pausing = not pausing
        if not pausing then
            afkTimer = 0
        end
    end

    if (input:isKeyDown("start") and input:wasKeyPressed("select")) or
        (input:wasKeyPressed("start") and input:isKeyDown("select")) or
        (input2:isKeyDown("start") and input2:wasKeyPressed("select")) or
        (input2:wasKeyPressed("start") and input2:isKeyDown("select"))
    then
        reset() -- this is just a global function that will reset the entire level
        pausing = false
    end

    if pausing then return end

    player:update(dt)
    player2:update(dt)

    world:update(dt)

    if changeMapTime > 0 then
        changeMapTime = changeMapTime - dt
    elseif changeMapQueue ~= nil then
        changeMapTimeOut = 1
        changeMap(changeMapQueue)
        changeMapQueue = nil
    end

    if changeMapTimeOut > 0 then
        changeMapTimeOut = changeMapTimeOut - dt
    end

    for i, object in pairs(map.objects) do
        object:update(dt)
    end

    while (#updateList > 0) do
        updateList[1]()
        table.remove(updateList, 1)
    end
end

function updateJoystickDetection()
end
