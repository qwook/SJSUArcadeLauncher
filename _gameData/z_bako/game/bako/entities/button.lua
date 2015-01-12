
BaseEntity = require("entities.core.baseentity")

Button = class("Button", BaseEntity)
Button.spritesheet1 = SpriteSheet:new("sprites/button_blue.png", 32, 32)
Button.spritesheet2 = SpriteSheet:new("sprites/button_green.png", 32, 32)

function Button:initialize()
    BaseEntity.initialize(self)

    self.hasPressedLastUpdate = false
    self.buttonDelay = 0
    self.pressed = false
end

function Button:initPhysics()
    local shape = love.physics.newPolygonShape(
        -16, 3, -- bottom left
        16, 3, -- bottom right
        8, -4, -- top right
        -8, -4 -- top left
    )
    self:makeSolid("static", shape)
    self:setFriction(4)
end

function Button:fixSpawnPosition()
    local x, y = self:getPosition()
    self:setPosition(x, y+12)
end

function Button:isTouchingPlayer()
    for k,v in pairs(self.touching) do
        if v.type == "PLAYER" then
            return v
        end
    end
    return false
end

function Button:update(dt)
    if self.buttonDelay > 0 then
        self.buttonDelay = self.buttonDelay - dt
    end

    local isTouching = self:isTouchingPlayer()

    if self.buttonDelay <= 0 then
        if isTouching and not self.hasPressedLastUpdate then
            self:trigger("onpress", isTouching)
            self.buttonDelay = 0.25
            self.pressed = true
            playSound("click_hi.wav")
        end
    end

    if not isTouching and self.pressed and self.buttonDelay <= 0 then
        self:trigger("onrelease", isTouching)
        self.pressed = false
        playSound("click_lo.wav")
    end

    self.hasPressedLastUpdate = isTouching
end

function Button:draw()
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

return Button
