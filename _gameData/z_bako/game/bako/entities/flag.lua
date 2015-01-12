
BaseEntity = require("entities.core.baseentity")

Flag = class("Flag", BaseEntity)
Flag.spritesheet1 = SpriteSheet:new("sprites/Flag_blue.png", 32, 32)
Flag.spritesheet2 = SpriteSheet:new("sprites/Flag_green.png", 32, 32)

function Flag:initialize()
    BaseEntity.initialize(self)
end

function Flag:fixSpawnPosition()
end

function Flag:postSpawn()
end

function Flag:initPhysics()
end

function Flag:isTouchingPlayer()
    for k,v in pairs(self.touching) do
        if v.type == "PLAYER" then
            return v
        end
    end
    return false
end

function Flag:update(dt)
    if self.FlagDelay > 0 then
        self.FlagDelay = self.FlagDelay - dt
    end

    local isTouching = self:isTouchingPlayer()

    if self.FlagDelay <= 0 then
        if isTouching and not self.hasPressedLastUpdate then
            self:trigger("onpress", isTouching)
            self.FlagDelay = 0.25
            self.pressed = true
        end
    end

    if not isTouching and self.pressed and self.FlagDelay <= 0 then
        self:trigger("onrelease", isTouching)
        self.pressed = false
    end

    self.hasPressedLastUpdate = isTouching
end

function Flag:draw()
    if self.pressed then
        if self.collisiongroup == "blue" then
            self.spritesheet1:draw(1, 0, -16, -16-8)
        else
            self.spritesheet2:draw(1, 0, -16, -16-8)
        end
    else
        if self.collisiongroup == "blue" then
            self.spritesheet1:draw(0, 0, -16, -16-8)
        else
            self.spritesheet2:draw(0, 0, -16, -16-8)
        end
    end
end

return Flag
