
DEACCELERATION_SPEED = 600 -- how much you're able to deaccelerate after jumping
IMPULSE_AFTER_JUMPING = 7.5 -- how much you're able to "nudge" after jumping
PLAYER_FRICTION = 0.75 -- friction
PLAYER_FRICTION_SLIDING = 0.01 -- friction while sliding

MOVING_ACCELERATION = 20 -- how much it should accelerate
MOVING_SPEED = 200 -- constant moving speed on ground

Physical =      require("entities.core.physical")
SpriteSheet =   require("util.spritesheet")
Particle =      require("entities.core.particle")
WalkingDust =   require("entities.particles.walkingdust")
DebugArrow =    require("entities.particles.debugarrow")
GhostPlayer =   require("entities.particles.ghostplayer")

Player = class('Player', Physical)
Player.spritesheet = SpriteSheet:new("sprites/players.png", 32, 32)

function Player:initialize()
    self.name = "Stewart"
    self.type = "PLAYER"
    self.collisiongroup = "blue"
    self.solid = true

    self.ang = 0
    self.expression = 0
   
    self.isother = false

    self.contacts = {}
    self.contactOwners = {}

    self.floorangle = 0
    self.floornx = 0
    self.floorny = 0

    self.shortJump = 0
    self.nextJump = 0

    self.facing = 'right'
    self.moving = false
    self.crouching = false
    self.lastFVX = 0
    self.lastFVY = 0

    self.nextDust = 0

    self:initPhysics()
end

function Player:event_multiplyvelocity(x, y)
    local vx, vy = self.body:getLinearVelocity()
    self.body:setLinearVelocity(vx * tonumber(x), vy * tonumber(y))
    self.body:setAwake(true)
end

function Player:event_addvelocity(x, y)
    local vx, vy = self.body:getLinearVelocity()
    self.body:setLinearVelocity(vx + tonumber(x), vy + tonumber(y))
    self.body:setAwake(true)
end

function Player:event_setvelocity(x, y)
    self.body:setLinearVelocity(tonumber(x), tonumber(y))
    self.body:setAwake(true)
end

function Player:event_setfriction(frict)
    self.body:setFriction(frict)
    self.body:setAwake(true)
end

function Player:event_applyimpulse(x, y)
    self.body:applyLinearImpulse(x, y)
    self.body:setAwake(true)
end

function Player:event_teleportto(name)

    for k,v in pairs(map.objects) do
        if v.name == name then
            -- print(v:getPosition())
            self:setPosition(v:getPosition())
            -- self:setPosition(self:getPosition())
            return
        end
    end
end

function Player:call(name, args)
    if self["event_" .. name] then
        self["event_" .. name](self, unpack(args))
    end
end

function Player:setController(input)
    self.controller = input
end

function Player:initPhysics()
    self.body = love.physics.newBody(world, 0, 0, 'dynamic')
    self.shape = love.physics.newPolygonShape(-14, -14, -14, 0, 14*math.cos(math.pi*(3/4)), 14*math.sin(math.pi*(3/4)), 0, 14, 14*math.cos(math.pi/4), 14*math.sin(math.pi/4), 14, 0, 14, -14)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setUserData(self)
    self.fixture:setFriction(PLAYER_FRICTION)
    self.body:setLinearDamping(0)
    self.body:setMass(20)
    self.body:setFixedRotation(true)
end

function Player:getFloor()
    local x, y = self:getPosition()
    y = y + 6

    for k, contact in pairs(self.contacts) do
        local x1, y1, x2, y2 = contact:getPositions()
        if ((y1 or y-1) > y and (y2 or y+1) > y) then
            self.floornx, self.floorny = contact:getNormal()
            return self.contactOwners[contact], contact
        end
    end

    return false
end

function Player:delayJump(time)
    self.nextJump = time
    self.shortJump = 0
end

function Player:update(dt)

    -- handle animation --

    if self.controller:wasKeyPressed("left") then
        self.facing = 'left'
    elseif self.controller:wasKeyPressed("right")  then
        self.facing = 'right'
    end

    if self.controller:isKeyDown("crouch") then
        self.crouching = true
    else
        self.crouching = false
    end

    if self.nextDust > 0 then
        self.nextDust = self.nextDust - dt
    end

    self.expression = 0
    if (self.controller:isKeyDown(":|")) then self.expression = self.expression + 1 end
    if (self.controller:isKeyDown(":/")) then self.expression = self.expression + 2 end

    -- handle physics --

    local velx, vely = self.body:getLinearVelocity()

    if math.length(velx, vely) > 0.1 then
        self.moving = true
    else
        self.moving = false
    end

    if self.nextJump > 0 then
        self.nextJump = self.nextJump - dt
    end

    local floordata, contact = self:getFloor()

    if floordata then

        local floor = floordata.entity
        local floorang = math.atan2(floordata.normy, floordata.normx) + math.pi/2
        self.ang = math.lerpAngle(self.ang, floorang, 10*dt)


        -- compensate for moving platform
        if floor.type ~= "TILE" and self.nextJump <= 0 then
            local fvx, fvy = floor.body:getLinearVelocity()
            if math.distance(fvx, fvy, self.lastFVX, self.lastFVY) > 100 then
                self.body:setLinearVelocity(fvx, fvy)
            end
            self.lastFVY = fvy
            self.lastFVX = fvx


            if math.distance(fvx, fvy, velx, vely) > 0.1 then
                self.moving = true
            else
                self.moving = false
            end
        end

        if self.controller:isKeyDown("right") then
            if velx < 250 then
                self.body:applyForce(1000, 0)
            end
        elseif self.controller:isKeyDown("left") then
            if velx > -250 then
                self.body:applyForce(-1000, 0)
            end
        end
        if self.controller:isKeyDown("jump") and self.nextJump <= 0 then
            self.nextJump = 0.1
            self.shortJump = 0.075

            self.body:applyLinearImpulse(-velx*0.25, -125-vely)
            playSound("bwop.wav")
            local smoke = Particle:new()
            smoke:setPosition(self:getPosition())
        end
    else -- henry: okay so this code is basically the same as when we're on the floot
        -- with the exception that we can jump
        -- should we make it less redundant or something

        local ang = math.sign(velx) * -math.pi/20 * -math.sign(vely)
        self.ang = math.lerpAngle(self.ang, ang, 1*dt)

        -- we go slower in the air
        if self.controller:isKeyDown("right") then
            if velx < 200 then
                self.body:applyForce(250, 0)
            end
        elseif self.controller:isKeyDown("left") then
            if velx > -200 then
                self.body:applyForce(-250, 0)
            end
        end

        -- we just jumped, allow for a longer jump
        if self.shortJump > 0 and self.controller:isKeyDown("jump") then
            self.body:applyForce(0, -3500)
            self.shortJump = self.shortJump - dt
        else
            -- OCD.. constantly make sure we can't short jump
            self.shortJump = 0
        end
    end

end

function Player:draw()
    local x, y = self:getPosition()
    local r = self:getAngle()

    love.graphics.push()
    love.graphics.translate(x, y)
    -- love.graphics.rotate(r)
    love.graphics.rotate(self.ang)

    if self.facing == 'right' then
        love.graphics.scale(1, 1)
    else
        love.graphics.scale(-1, 1)
    end

    love.graphics.setColor(255, 255, 255)

    self:drawPlayer()

    love.graphics.pop()
end

function Player:drawPlayer()
    -- local anim = 5
    local anim = 0
    if self.moving then
        anim = math.floor(love.timer.getTime()*10) % 4
        -- anim = math.floor(love.timer.getTime()*20) % 6
    end

    local offset = 0
    if self.crouching then
        anim = 2
        offset = 6
    end


    self.spritesheet:draw(anim, 1, -16, -18 + offset)
    -- self.spritesheet:draw(anim, 0, -16, -18 + offset)
    self.spritesheet:draw(self.expression, 0, -16, -18 + offset)
end

function Player:getVelocity()
    return self.body:getLinearVelocity()
end

function Player:setVelocity(x, y)
    self.body:setLinearVelocity(x, y)
end

function Player:getPosition()
    return self.body:getPosition()
end

function Player:setPosition(x, y)
    self.body:setPosition(x, y)
end

function Player:getAngle()
    return self.body:getAngle()
end

function Player:setAngle(r)
    self.body:setAngle(r)
end

-- So if we disable a the collision for an object
-- The player might still float on a "ghost" version of the object
-- This forces the player to recalculate the collision
-- It's very hacky but it works.
function Player:forceCollisionRecalculation()
    local categories, mask, group = self.fixture:getFilterData()

    self.fixture:setFilterData(1, 0, 0)
    self.fixture:setFilterData(2, 0, 0)
    self.fixture:setFilterData(categories, mask, group)
end

-- the player hit something
function Player:beginContact(other, contact, isother)
    self.isother = isother

    if not other.solid then return end

    local x, y = self:getPosition()
    local normx, normy = contact:getNormal()

    -- "Conservation of Energy"
    ------------------------------------------------------

    if SLIDE or self.crouching == true then

        local velx, vely = self.body:getLinearVelocity()

        -- local smoke = DebugArrow:new()
        local smoke = GhostPlayer:new()
        smoke:setPosition(x, y)

        local ang = math.atan2(normy, normx)
        local tanx = math.cos(ang + math.pi/2)
        local tany = math.sin(ang + math.pi/2)
        local dot = math.dotproduct(velx, vely, 0, tanx, tany, 0)
        if dot < 0 then
            tanx = -tanx
            tany = -tany
        end

        local velmag = math.length(velx, vely)
        velmag = velmag

        smoke:setAim(tanx*40, tany*40)

        -- CONSERVE ALL THE ENERGIES!
        self.body:setLinearVelocity(tanx*velmag, tany*velmag)
    end

    ------------------------------------------------------

    y = y + 6

    if isother == false then
        normx = -normx
        normy = -normy
    end

    table.insert(self.contacts, contact)
    self.contactOwners[contact] = {entity = other, normx = normx, normy = normy}

    -- detect a floor
    local x1, y1, x2, y2 = contact:getPositions()

    local id, id2 = contact:getChildren()
    if isother then id = id2 end -- `isother` means we are the second object

    if ((y1 or y-1) > y and (y2 or y+1) > y) then -- and ((math.acos(dot) <= math.pi / 4 + 0.1) or (math.acos(dot) >= math.pi * (3 / 4) - 0.1)) then        
        self.floorangle = math.atan2(normy, normx)
        self.floornx = normx
        self.floorny = normy
    else
        -- if it isn't a floor, set the friction to 0
        -- we want to slide down walls, not cling onto them
        --contact:setFriction(0)
    end

    if other.type == "PLAYER" then
        contact:setFriction(1.5)
    end

end

function Player:endContact(other, contact, isother)
    local normx, normy = contact:getNormal()
    local cx, cy, cz = math.crossproduct(normx, normy, 0, 0, 1, 0)

    table.removevalue(self.contacts, contact)
    self.contactOwners[contact] = nil

    local x, y = self:getPosition()
    local x1, y1, x2, y2 = contact:getPositions()

    local id, id2 = contact:getChildren()
    if isother then id = id2 end -- `isother` means we are the second object

end

function Player:postSolve(other, contact, nx, ny, isother)
    if self.moving and self.nextDust <= 0 and self:getFloor() ~= false then
        local smoke = WalkingDust:new()
        local x, y = self:getPosition()
        local vx, vy = 0, -50

        if self.facing == "left" then
            vx = 25
        else
            vx = -25
        end

        smoke:setPosition(x+vx*0.70, y + 16)
        smoke:setVelocity(vx, vy)
        smoke:setScale(math.length(self.body:getLinearVelocity())/200)
        self.nextDust = 0.15
    end
end


-- Cindy is player 2.
Cindy = class("Cindy", Player)

function Cindy:initialize()
    Player.initialize(self)

    self.collisiongroup = "green"
    self.name = "Cindy"
end

function Cindy:drawPlayer()
    -- local anim = 5
    local anim = 0
    if self.moving then
        anim = math.floor(love.timer.getTime()*10) % 4
        -- anim = math.floor(love.timer.getTime()*20) % 6
    end

    local offset = 0
    if self.crouching then
        anim = 2
        offset = 6
    end


    self.spritesheet:draw(anim, 3, -16, -18 + offset)
    -- self.spritesheet:draw(anim, 0, -16, -18 + offset)
    self.spritesheet:draw(self.expression, 2, -16, -18 + offset)

end


return Player
