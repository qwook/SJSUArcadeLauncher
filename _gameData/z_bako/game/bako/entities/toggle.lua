
BaseEntity = require("entities.core.baseentity")

Toggle = class("Toggle", BaseEntity)
Toggle.spritesheet1 = SpriteSheet:new("sprites/switch_blue.png", 32, 32)
Toggle.spritesheet2 = SpriteSheet:new("sprites/switch_green.png", 32, 32)    

function Toggle:initialize()
    BaseEntity.initialize(self)

    self.hasPressedLastUpdate = false
    self.ToggleDelay = 0
    self.pressed = false
end

function Toggle:initPhysics()
    local shape = love.physics.newPolygonShape(
        -16, 3, -- bottom left
        16, 3, -- bottom right
        8, -4, -- top right
        -8, -4 -- top left
    )
    self:makeSolid("static", shape)
    self:setFriction(4)
end

function Toggle:fixSpawnPosition()
    local x, y = self:getPosition()
    self:setPosition(x, y+12)
end

function Toggle:isTouchingPlayer()
    for k,v in pairs(self.touching) do
        if v.type == "PLAYER" then
            return v
        end
    end
    return false
end

function Toggle:update(dt)
    if self.ToggleDelay > 0 then
        self.ToggleDelay = self.ToggleDelay - dt
    end

    local isTouching = self:isTouchingPlayer()

    if isTouching and isTouching.controller:wasKeyPressed("crouch") then
        self:trigger("ontoggle", isTouching)
        self.ToggleDelay = 0.25
        self.pressed = not self.pressed
        if self.pressed == true then
            self:trigger("onpress", isTouching)
            playSound("clack_down.wav")
        else
            self:trigger("onrelease", isTouching)
            playSound("clack_up.wav")
        end
    end

    self.hasPressedLastUpdate = isTouching
end

function Toggle:draw()
    if self.pressed then
        if self.collisiongroup == "blue" then
            self.spritesheet1:draw(1, 0, -16, -16 -12)
        else
            self.spritesheet2:draw(1, 0, -16, -16 -12)
        end
    else
        if self.collisiongroup == "blue" then
            self.spritesheet1:draw(0, 0, -16, -16 -12)
        else
            self.spritesheet2:draw(0, 0, -16, -16 -12)
        end
    end
end

return Toggle
