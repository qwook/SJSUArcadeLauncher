
Physical = require("entities.core.physical")
SpriteSheet = require("util.spritesheet")

Bull = class("Bull", Physical)

function Bull:initialize()
    self.spritesheet = SpriteSheet:new("assets/Bull.png", 256, 256)

    table.insert(map.objects, self)
end

function Bull:destroy()
    table.removevalue(map.objects, self)
end

function Bull:initPhysics()
    self.body = love.physics.newBody(world, 0, 0, 'dynamic')
    self.shape = love.physics.newRectangleShape(32, 32)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setUserData(self)
    self.fixture:setFriction(0.5)
end

function Bull:setPosition(x, y)
    self.body:setPosition(x, y)
end

function Bull:getPosition()
    return self.body:getPosition()
end

function Bull:getAngle(r)
    self.body:getAngle(r)
end

function Bull:getAngle()
    return self.body:getAngle()
end

function Bull:update(dt)
end

function Bull:draw()
    local x, y = self:getPosition()
    local r = self:getAngle()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r)

    love.graphics.setColor(255, 255, 255)
    -- love.graphics.rectangle('fill', -16, -16, 32, 32)
    self.spritesheet:draw(math.floor(love.timer.getTime()*10) % 9, 0, -128, -128)

    love.graphics.pop()
end

function Bull:beginContact(other, contact)
    if other.type == "PLAYER" then
        -- you can make it so it's a button and it activates on touch
        -- idk
    end
end

function Bull:endContact(other, contact)
end

return Bull
