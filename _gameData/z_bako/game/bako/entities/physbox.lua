
Physical = require("entities.core.physical")

PhysBox = class("PhysBox", BaseEntity)
PhysBox.spritesheet = SpriteSheet:new("sprites/box_generic.png", 32, 32)
PhysBox.image = loadImage("sprites/doorcrate.gif"):getData()

function PhysBox:initialize(x, y, w, h)
    BaseEntity.initialize(self)

    self.width = 32
    self.height = 32

    if w > 0 and h > 0 then
        self.width = w
        self.height = h
    end
end

-- this will act as if an image is a framebuffer and draws on it
-- useful for generating boxes of random sizes
-- todo: move this somewhere else
local function blit(dst, src, dx, dy, sx, sy, sw, sh)
    dst:mapPixel(function(x, y, r, g, b, a)
                 if (x >= dx and x < dx + sw) and
                    (y >= dy and y < dy + sh) then

                    local deltax = (x - dx)
                    local deltay = (y - dy)

                    local r, g, b, a = src:getPixel(sx + deltax, sy + deltay)
                    if a > 0 then
                        return r, g, b, a
                    end

                 end

                 return r, g, b, a
    end)
end

function PhysBox:initPhysics()
    local shape = love.physics.newRectangleShape(self.width, self.height)
    self:makeSolid("dynamic", shape)
end

function PhysBox:postSpawn()
    -- generate a randomized box
    -- store and imagedata for each box
    -- (a lot better than storing framebuffers)
    local data = love.image.newImageData(self.width, self.height)

    -- draw inner boxes
    for x = 0, math.ceil(self.width/32) do
        for y = 0, math.ceil(self.height/32) do
            blit(data, self.image, x*32, y*32, 32*math.floor(math.random(3, 4)), 0, 32, 32)
        end
    end

    -- draw sides
    for x = 0, math.ceil(self.width/32) do
        blit(data, self.image, x*32, 0, 32*1, 0, 32, 32)
        blit(data, self.image, x*32, self.height-32, 32*1, 32*2, 32, 32)
    end
    for y = 0, math.ceil(self.height/32) do
        blit(data, self.image, 0, y*32, 0, 32*1, 32, 32)
        blit(data, self.image, self.width-32, y*32, 32*2, 32*1, 32, 32)
    end

    -- draw corners
    blit(data, self.image, 0, 0, 0, 0, 32, 32)
    blit(data, self.image, self.width-32, 0, 32*2, 0, 32, 32)
    blit(data, self.image, self.width-32, self.height-32, 32*2, 32*2, 32, 32)
    blit(data, self.image, 0, self.height-32, 0, 32*2, 32, 32)
    self.generatedbox = love.graphics.newImage(data)
end

function PhysBox:draw()
    love.graphics.draw(self.generatedbox, -self.width/2, -self.height/2)
end


return PhysBox
