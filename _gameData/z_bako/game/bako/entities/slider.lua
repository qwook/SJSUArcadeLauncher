
-- This is an empty entity. It's created when the map editor
-- Doesn't supply

BaseEntity = require("entities.core.baseentity")

Slider = class("Slider", BaseEntity)

function Slider:postSpawn()
    local objs = map:findObjectsByName(self:getProperty("object"))
    local obj = objs[1]

    if not obj then return end
    if not obj.body then return end

    local ang = math.rad(tonumber(self:getProperty("angle") or 0))

    self.joint = love.physics.newPrismaticJoint(map.body, obj.body, self.x, self.y, math.cos(ang), math.sin(ang), true)
end

function Slider:destroy()
    BaseEntity.destroy(self)
    self.joint:destroy()
end

function Slider:draw()
    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle("fill", 0, 0, 10, 5)
    end
end

return Slider
