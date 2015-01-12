
Physical = require("entities.core.physical")
SpriteSheet = require("util.spritesheet")

BlueBall = class("BlueBall", Physical)

function BlueBall:initialize()
    self.spritesheet = SpriteSheet:new("assets/BlueBall.png", 256, 256)

    table.insert(map.objects, self)
end

function BlueBall:destroy()
    table.removevalue(map.objects, self)
end

function BlueBall:initPhysics()
    self.body = love.physics.newBody(world, 0, 0, 'dynamic')
    self.shape = love.physics.newRectangleShape(64, 64)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setUserData(self)
    self.fixture:setFriction(0.5)
end

function BlueBall:setPosition(x, y)
    self.body:setPosition(x, y)
end

function BlueBall:getPosition()
    return self.body:getPosition()
end

function BlueBall:getAngle(r)
    self.body:getAngle(r)
end

function BlueBall:getAngle()
    return self.body:getAngle()
end

function BlueBall:update(dt)
end

function BlueBall:draw()
    local x, y = self:getPosition()
    local r = self:getAngle()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r)

    love.graphics.setColor(255, 255, 255)
    -- love.graphics.rectangle('fill', -16, -16, 32, 32)
    self.spritesheet:draw(math.floor(love.timer.getTime()*10) % 15, 0, -64, -64)

    love.graphics.pop()
end

function BlueBall:beginContact(other, contact)
    if other.type == "PLAYER" then
        -- you can make it so it's a button and it activates on touch
        -- idk
    end
end

function BlueBall:endContact(other, contact)
end

return BlueBall
