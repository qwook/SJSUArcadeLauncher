
require("libs.mathext") -- this extends the math library
require("libs.tableext") -- this extends the table library
require("libs.print2") -- this adds "print2"

GRAVITY =       1000

class =         require("libs.middleclass")

require("core.update")
require("core.draw")
require("core.sounds")
require("core.cache")

Input =         require("core.input")
Events =        require("core.events")

Player =        require("entities.core.player")
Map =           require("entities.core.map")
Node =          require("entities.core.node")
Camera =        require("entities.camera")
RushCamera =    require("entities.rushcamera")
TitleScreen =   require("entities.core.titlescreen")
Text =          require("entities.text")
Timer =         require("entities.timer")
MisterF =       require("entities.misterf")

PhysBox =       require("entities.physbox")
Button =        require("entities.button")
Toggle =        require("entities.toggle")
Trigger =       require("entities.trigger")
Prop =          require("entities.prop")
LayerObject =   require("entities.layerobject")
Trampoline =    require("entities.trampoline")
Slider =        require("entities.slider")
Weld =        require("entities.weld")

Bull =          require("entities.npc.bull")
BlueBall =      require("entities.npc.blueball")
Fonz =          require("entities.npc.fonz")

----------------------------------------------------

local arguments = {}
for k, v in pairs(arg) do
    arguments[string.lower(v)] = true
end

if arguments["debug"] then
    DEBUG = true
end

if arguments["slide"] then
    SLIDE = true
end

----------------------------------------------------

pausing = false

----------------------------------------------------


-- replace with tiled later
local tempmap = {
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0};
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0};
    {1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0};
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0};
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0};
}

function beginContact(fixture1, fixture2, contact)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()


    physical1:beginContact(physical2, contact, false)
    physical2:beginContact(physical1, contact, true)
end

function endContact(fixture1, fixture2, contact)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1:endContact(physical2, contact, false)
    physical2:endContact(physical1, contact, true)
end

function preSolve(fixture1, fixture2, contact)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1:preSolve(physical2, contact, false)
    physical2:preSolve(physical1, contact, true)
end

function postSolve(fixture1, fixture2, contact, normal, tangent)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1:postSolve(physical2, contact, normal, tangent, false)
    physical2:postSolve(physical1, contact, normal, tangent, true)
end

function contactFilter(fixture1, fixture2)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1.collisiongroup = physical1.collisiongroup or "shared"
    physical2.collisiongroup = physical2.collisiongroup or "shared"

    if physical1:shouldCollide(physical2) == false or physical2:shouldCollide(physical1) == false then
        return false
    end

    if physical1.visible == false or physical2.visible == false then
        return false
    end

    if physical1.collisiongroup == "notplayer" and physical2.type == "PLAYER" then
        return false
    end

    if physical2.collisiongroup == "notplayer" and physical1.type == "PLAYER" then
        return false
    end

    if physical1.type == "PLAYER" and physical2.type == "PLAYER" then
        return true
    end

    if physical1.collisiongroup == "shared" or physical2.collisiongroup == "shared" then
        return true
    end

    -- there is probably a more elegant way to make this logic
    -- i'm just so tired
    if physical1.type == "TILE" or physical2.type == "TILE" then
        if physical1.collisiongroup ~= physical2.collisiongroup then
            if not collisionSwapped then
                return false
            end
        else
            if collisionSwapped then
                return false
            end
        end
    else
        if physical1.collisiongroup ~= physical2.collisiongroup then
            return false
        end
    end

    return true
end

function changeMap(mapname)

    if world then
        world:destroy()
    end

    world = love.physics.newWorld()
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    world:setContactFilter(contactFilter)
    world:setGravity(0, GRAVITY)

    collisionSwapped = false
    singleCamera = false

    clearUpdates()

    map = Map:new("assets/maps/" .. mapname)

    map:spawnObjects()
end

function reset()

    if world then
        world:destroy()
    end

    world = love.physics.newWorld()
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    world:setContactFilter(contactFilter)
    world:setGravity(0, 1000)

    if arg[2] then 
        map = Map:new(arg[2])
    else
        if not map then
            map = Map:new("assets/maps/title")
        else
            map = Map:new(map.mapname)
        end
    end
    
    collisionSwapped = false
    singleCamera = false

    clearUpdates()
    map:spawnObjects()
end

function love.load()

    love.mouse.setVisible(false)

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setBackgroundColor(134, 200, 255)

    input = Input:new()
    input2 = Input:new()
    if arg[2] == "dvorak" then
        keyBoardLayout = "dvorak"
    end
    Input:loadKeyBindings()

    events = Events:new()
    reset()

end
