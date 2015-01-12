
BaseEntity = require("entities.core.baseentity")

Coconut = class("Coconut", BaseEntity)
Coconut.image = loadImage("sprites/coconut.gif")

function Coconut:initialize()
    BaseEntity.initialize(self)
    self.isCoconut = true
    self.nextDie = 1
end

function Coconut:initPhysics()
    local shape = love.physics.newCircleShape(8)
    self:makeSolid("dynamic", shape)
    self:setFriction(0)
end

function Coconut:update(dt)
    self.nextDie = self.nextDie - dt
    if self.nextDie <= 0 then
        self:destroy()
    end
end

function Coconut:draw()
    love.graphics.draw(self.image, -7, -7)
end

return Coconut
