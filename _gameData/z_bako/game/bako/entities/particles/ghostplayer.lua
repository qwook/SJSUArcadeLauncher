
Particle = require("entities.core.particle")

GhostPlayer = class("Particle", Particle)
GhostPlayer.spritesheet = SpriteSheet:new("sprites/players.png", 32, 32)

function GhostPlayer:initialize()
    Particle.initialize(self)

    self.zindex = nil
    self.scale = 1
    self.lifetime = 0.5

    self.ang = 0
end

function GhostPlayer:setAim(x, y)
    self.xAim = x
    self.yAim = y
    self:setAngle(math.atan2(y, x))
end

function GhostPlayer:update(dt)
    Particle.update(self, dt)
end

function GhostPlayer:draw()
    love.graphics.setColor(255, 255, 255, self.lifetime/0.5 * 255)
    self.spritesheet:draw(0, 1, -16, -18)
end

return GhostPlayer
