
BaseEntity = require("entities.core.baseentity")

Particle = class("Particle", BaseEntity)
Particle.spritesheet = SpriteSheet:new("sprites/dust1.png", 32, 32)

function Particle:initialize()
    BaseEntity.initialize(self)

    self.zindex = -1
    self.x = 0
    self.y = 0

    self.lifetime = 0.5

end

function Particle:update(dt)
    self.lifetime = self.lifetime - dt
    if self.lifetime < 0 then
        self:destroy()
    end
end

function Particle:draw()
    love.graphics.scale(2)
    love.graphics.setColor(141, 143, 166)
    self.spritesheet:draw(math.floor((0.5 - self.lifetime)/0.5*6)%6, 0, -16, -16)
end

return Particle
