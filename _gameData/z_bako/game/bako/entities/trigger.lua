
BaseEntity = require("entities.core.baseentity")

Trigger = class("Trigger", BaseEntity)

function Trigger:initialize(x, y, w, h)
    BaseEntity.initialize(self)
    self.width = w
    self.height = h
    self.solid = false
    self.touching = {}
end

function Trigger:initPhysics()
    local shape = love.physics.newRectangleShape(self.width, self.height)
    self:makeSolid("static", shape)
    self:setSensor(true)

    self.hasPressedLastUpdate = false
    self.TriggerDelay = 0
end

function Trigger:update(dt)
    for _, other in ipairs(self.touching) do
        local filter = self:getProperty("filter")
        if (filter and filter == other.name) or (not filter and other.type == "PLAYER") then
            self:trigger("ontouching", other)
        end
    end
end

function Trigger:draw()
    if not DEBUG then return end
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.rectangle('fill', -self.width/2, -self.height/2, self.width, self.height)
    love.graphics.rectangle('line', -self.width/2, -self.height/2, self.width, self.height)
end

function Trigger:beginContact(other, contact, isother)
    table.insert( self.touching, other )
    onNextUpdate(function()
        local filter = self:getProperty("filter")
        if (filter and filter == other.name) or (not filter and other.type == "PLAYER") then
            self:trigger("ontrigger", other)
            local pls = {}
            for k,v in pairs(self.touching) do
                if v.type == "PLAYER" then
                    pls[v] = true
                end
            end

            local plcount = 0

            for k, v in pairs(pls) do plcount = plcount + 1 end

            if plcount >= 2 then
                self:trigger("onbothplayers", other)
            end
        end
    end)
end

function Trigger:endContact(other, contact, isother)
    table.removeonevalue( self.touching, other )
    local filter = self:getProperty("filter")
    if (filter and filter == other.name) or (not filter and other.type == "PLAYER") then
        self:trigger("ontriggerend", other)
        local pls = {}
        for k,v in pairs(self.touching) do
            if v.type == "PLAYER" then
                pls[v] = true
            end
        end

        local plcount = 0
        for k, v in pairs(pls) do plcount = plcount + 1 end
        if plcount == 0 then
            self:trigger("onbothplayersend", other)
        end
    end
end

return Trigger
