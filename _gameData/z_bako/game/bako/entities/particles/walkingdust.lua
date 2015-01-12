
Particle = require("entities.core.particle")

WalkingDust = class("Particle", Particle)

function WalkingDust:initialize()
    Particle.initialize(self)

    self.scale = 1
    self.velx = 0
    self.vely = 0
    self.lifetime = 0.5
    self.spritesheet = SpriteSheet:new("sprites/dust2.png", 32, 32)
end

function WalkingDust:setVelocity(velx, vely)
    self.velx = velx
    self.vely = vely
end

function WalkingDust:setScale(scale)
    self.scale = scale
end

function WalkingDust:update(dt)
    Particle.update(self, dt)

    self.x = self.x + self.velx * dt
    self.y = self.y + self.vely * dt
end

function WalkingDust:draw()
    love.graphics.scale(self.scale)

    love.graphics.setColor(141, 143, 166)
    self.spritesheet:draw(math.floor((0.5 - self.lifetime)/0.5*5)%5, 0, -16, -16)
end

return WalkingDust
