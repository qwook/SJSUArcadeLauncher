
BaseEntity = require("entities.core.baseentity")
Coconut = require("entities.coconut")

MisterF = class("MisterF", BaseEntity)
MisterF.spritesheet = SpriteSheet:new("sprites/misterf.png", 64, 32)

function MisterF:initialize()
    BaseEntity.initialize(self)
    self.collisiongroup = "shared"
    self.nextAttack = 0
    self.coconut = nil
    self.anim = 0
    self.ang = 1
end

function MisterF:shouldCollide(other)
    if other.isCoconut then
        return false
    end
end

function MisterF:initPhysics()
    local shape = love.physics.newRectangleShape(32, 32)
    self:makeSolid("static", shape)
end

function MisterF:calculateVelocity(goal)
    local xPos, yPos = self:getPosition()
    local xGoalPos, yGoalPos = goal:getPosition()

    yGoalPos = yGoalPos + 16

    local flipped = false
    if (xGoalPos < xPos) then
        flipped = true
        xGoalPos = 2*xPos - xGoalPos
        xGoalPos = xGoalPos -- slight adjustment
    else
        xGoalPos = xGoalPos + 32 -- slight adjustment
    end

    local dx = xGoalPos - xPos
    local dy = yPos - yGoalPos -- Account for funky coordinate systems.
    local theta, vx, vy -- vx and vy are the x and y components of the projectile velocity.

    -- Root is [÷/-]1. Sometimes two parabolas are possible, root selects which one is to be used.
    -- root = -1 will launch the projectile such that it hits the target before the apex, if possible.
    local root = -1
    -- The discriminant determines if the shot is even possible.

    local vel = 750
    local discriminant = math.pow(vel, 4) - GRAVITY*(GRAVITY*dx*dx + 2*dy*vel*vel)
    
    -- if the lame map editor didn't set a velocity, 
    -- calculate a velocity that will give a good discriminant
    if discriminant <= 0 then
            vel = math.sqrt(math.sqrt(math.pow((GRAVITY*2*dy), 2) + 4*(1 + GRAVITY*(GRAVITY*dx*dx))) + (GRAVITY*2*dy)) / math.sqrt(2)
            discriminant = math.pow(vel, 4) - GRAVITY*(GRAVITY*dx*dx + 2*dy*vel*vel)
    end
    
    if discriminant >= 0 then
        -- Find the angle of launch.
        theta = math.atan((vel*vel + root*math.sqrt(discriminant))/(GRAVITY*dx))
        -- Divide the velocity into x and y components.
        vx = vel*math.cos(theta)
        vy = vel*math.sin(theta)
        if flipped then vx = -vx end

        -- Sanity check to avoid feeding a nil value into the physics engine.
        if vx == vx and vy == vy then
            return vx, -vy
        end
    end
end

function MisterF:getGoal()
    local goal
    local x, y = self:getPosition()

    local distancePlayer1 = math.distance(x, y, player:getPosition())
    local distancePlayer2 = math.distance(x, y, player2:getPosition())

    if (self.collisiongroup == "shared" and distancePlayer1 < distancePlayer2) then
        goal = player
    end

    if (self.collisiongroup == "shared" and distancePlayer2 < distancePlayer1) then
        goal = player2
    end

    return goal
end

function MisterF:update(dt)
    self.nextAttack = self.nextAttack - dt

    self.anim = (math.floor((1 - self.nextAttack) * 7 + 2) % 7)

    local goal = self:getGoal()

    if goal then
        local x, y = self:getPosition()
        local gx, gy = goal:getPosition()
        self.ang = math.sign(gx - x)
        if self.ang == 0 then self.ang = 1 end
    end

    if self.nextAttack <= 0 then
        self.nextAttack = 1

        if goal then
            local vx, vy = self:calculateVelocity(goal)

            if vx and vy then
                local coconut = Coconut:new()
                coconut:setPosition(self:getPosition())
                coconut:initPhysics()

                coconut:setVelocity(vx, vy)
            end
        end
    end
end

function MisterF:draw()
    love.graphics.scale(self.ang, 1)
    self.spritesheet:draw(self.anim, 0, -32, -16)
end

return MisterF
