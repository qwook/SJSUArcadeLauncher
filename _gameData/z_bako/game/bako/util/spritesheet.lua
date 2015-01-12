
SpriteSheet = class("SpriteSheet")

function SpriteSheet:initialize(img, w, h)
    self.image = loadImage(img)
    self.w = w
    self.h = h

    self.tw = self.image:getWidth() / w
    self.th = self.image:getHeight() / h

    self.quads = {}

    for y = 0, self.th-1 do
        for x = 0, self.tw-1 do
            table.insert( self.quads, love.graphics.newQuad(x * w, y * h, w, h, self.image:getWidth(), self.image:getHeight()))
        end
    end
end

function SpriteSheet:draw(x, y, xoff, yoff, r, sx, sy)
    xoff = xoff or 0
    yoff = yoff or 0

    local quad = self.quads[(x + y * self.tw) + 1]
    if not quad then return end

    love.graphics.draw(self.image, quad, xoff, yoff, r, sx, sy)
end

return SpriteSheet
