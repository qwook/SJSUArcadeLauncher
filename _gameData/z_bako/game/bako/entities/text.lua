
BaseEntity = require("entities.core.baseentity")

Text = class("Text", BaseEntity)

function Text:initialize(x, y, w, h)
    BaseEntity.initialize(self)
    self.string = ""
    self.width = w
    self.height = h
    self.typing = false
    self.typeprogr = 0
    self.nexttype = 0
end

function Text:event_setstring(string)
    self:setProperty("string", string)
end

function Text:event_type()
    self:event_setvisible("true")

    self.typing = true
    self.typeprogr = 0
    self.nexttype = 0.05
end

function Text:update(dt)
    if self.typing and self.typeprogr <= self:getProperty("string"):len() then
        self.nexttype = self.nexttype - dt
        if (self.nexttype <= 0) then
            self.nexttype = 0.05
            self.typeprogr = self.typeprogr + 1
        end
    end
end

function Text:preDraw()
    love.graphics.push()
    love.graphics.translate(self.brushx + 32, self.brushy + 32)
end

function Text:postDraw()
    love.graphics.pop()
end

function Text:draw()

    local string = self:getProperty("string")

    local font = love.graphics.getFont()
    local width, lines = font:getWrap(string, self.width - 20)
    local height = lines*(font:getHeight())

    love.graphics.setColor(0, 0, 0, 100)

    self:drawSquiggleBox(self.width, height + 20)

    love.graphics.setColor(255, 255, 255, 255)

    if self.typing then
        love.graphics.printf(string:sub(0, self.typeprogr), 10, 10, self.width - 20)
    else
        love.graphics.printf(string, 10, 10, self.width - 20)
    end

end

function Text:drawSquiggleBox(w, h)

    local squiggleSpeed = 20

    math.randomseed(math.floor(love.timer.getTime()*squiggleSpeed)/squiggleSpeed)

    local vertices = {}
    for y = 1, h/10 do
        table.insert(vertices, 0    + math.random(-2, 2))
        table.insert(vertices, y*10 + math.random(-2, 2))
    end

    --
    for x = 1, w/10 do
        if (x == w/10) then
            table.insert(vertices, (x+1)*10 + math.random(-2, 2))
            table.insert(vertices, (h+10)    + math.random(-2, 2))
        else
            table.insert(vertices, x*10 + math.random(-2, 2))
            table.insert(vertices, h    + math.random(-2, 2))
        end
    end

    --
    for y = 1, h/10 do
        y = h/10 - y
        table.insert(vertices, w    + math.random(-2, 2))
        table.insert(vertices, y*10 + math.random(-2, 2))
    end

    for x = 1, w/10 do
        x = w/10 - x
        table.insert(vertices, x*10 + math.random(-2, 2))
        table.insert(vertices, 0    + math.random(-2, 2))
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon('fill', vertices)

    -- revert the randomseed back.
    math.randomseed(love.timer.getTime())

end

return Text
