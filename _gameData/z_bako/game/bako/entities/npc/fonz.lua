
BaseEntity = require("entities.core.baseentity")
SpriteSheet = require("util.spritesheet")

Fonz = class("Fonz", BaseEntity)

function Fonz:initialize()
    self.spritesheet = SpriteSheet:new("assets/fonz.png", 256, 256)

    table.insert(map.objects, self)
end

function Fonz:destroy()
    table.removevalue(map.objects, self)
end

function Fonz:initPhysics()
    self.body = love.physics.newBody(world, 0, 0, 'dynamic')
    -- self.shape = love.physics.newRectangleShape(32, 32)
    self.shape = love.physics.newCircleShape(16)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setUserData(self)
    self.fixture:setFriction(0.5)
end

function Fonz:setPosition(x, y)
    self.body:setPosition(x, y)
end

function Fonz:getPosition()
    return self.body:getPosition()
end

function Fonz:getAngle(r)
    self.body:getAngle(r)
end

function Fonz:getAngle()
    return self.body:getAngle()
end

function Fonz:update(dt)
end

function Fonz:draw()
    local x, y = self:getPosition()
    local r = self:getAngle()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r)

    love.graphics.setColor(255, 255, 255)
    -- love.graphics.rectangle('fill', -16, -16, 32, 32)
    self.spritesheet:draw(math.floor(love.timer.getTime()*10) % 8, 0, -128, -128)

    love.graphics.pop()
end

function Fonz:beginContact(other, contact)
    if other.type == "PLAYER" then
        -- you can make it so it's a button and it activates on touch
        -- idk
    end
end

function Fonz:endContact(other, contact)
end

return Fonz
