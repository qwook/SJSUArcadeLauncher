
Particle = require("entities.core.particle")

DebugArrow = class("Particle", Particle)

function DebugArrow:initialize()
    Particle.initialize(self)

    self.zindex = nil
    self.scale = 1
    self.lifetime = 0.5

    self.ang = 0
end

function DebugArrow:setAim(x, y)
    self.xAim = x
    self.yAim = y
    self.ang = math.atan2(y, x)
end

function DebugArrow:update(dt)
    Particle.update(self, dt)
end

function DebugArrow:draw()
    self.xAim = self.xAim or 0
    self.yAim = self.yAim or 0

    love.graphics.setLineWidth(3)

    love.graphics.setColor(0, 0, 255, self.lifetime/0.5 * 255)
    love.graphics.line(0, 0, self.xAim, self.yAim)
    love.graphics.line(self.xAim, self.yAim, self.xAim + math.cos(self.ang+math.pi*(3/4))*10, self.yAim + math.sin(self.ang+math.pi*(3/4))*10)
    love.graphics.line(self.xAim, self.yAim, self.xAim + math.cos(self.ang-math.pi*(3/4))*10, self.yAim + math.sin(self.ang-math.pi*(3/4))*10)

    love.graphics.setLineWidth(1)
end

return DebugArrow
