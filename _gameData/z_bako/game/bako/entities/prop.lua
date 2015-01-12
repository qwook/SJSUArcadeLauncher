
BaseEntity = require("entities.core.baseentity")

Prop = class("Prop", BaseEntity)

function Prop:initialize()
    BaseEntity.initialize(self)
end

function Prop:postSpawn()
    self.animlife = 0
    self.spritewidth = tonumber(self:getProperty("spritewidth"))
    self.spriteheight = tonumber(self:getProperty("spriteheight"))
    self.spritesheet = SpriteSheet:new("sprites/" .. self:getProperty("sprite"), self.spritewidth, self.spriteheight)
end

function Prop:event_loopanimation(y, xfrom, xto, speed)
    self.animspeed = speed
    self.animlife = 0
    self.animy = tonumber(y)
    self.xfrom = tonumber(xfrom)
    self.xto = tonumber(xto)
    self.loop = true
end

function Prop:event_playanimation(y, xfrom, xto, duration)
    self.animlife = tonumber(duration)
    self.animduration = tonumber(duration)
    self.animy = tonumber(y)
    self.xfrom = tonumber(xfrom)
    self.xto = tonumber(xto)
    self.loop = false
end

function Prop:update(dt)
    if self.loop then
        self.animlife = self.animlife + dt * self.animspeed
    end

    if self.animlife > 0 and not self.loop then
        self.animlife = self.animlife - dt
    end
end

function Prop:draw()
    if self.animlife > 0 then
        local t

        if self.loop then
            t = self.animlife
        else
            t = (self.animduration - self.animlife) / self.animduration
        end

        local s = (self.xto - self.xfrom) + 1
        self.spritesheet:draw(self.xfrom + (math.floor(t*s) % s), self.animy, -self.spritewidth/2, -self.spriteheight/2)
    else
        self.spritesheet:draw(0, 0, -self.spritewidth/2, -self.spriteheight/2)
    end
end

return Prop
