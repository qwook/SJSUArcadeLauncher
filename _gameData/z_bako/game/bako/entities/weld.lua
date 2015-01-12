
-- This is an empty entity. It's created when the map editor
-- Doesn't supply

BaseEntity = require("entities.core.baseentity")

Weld = class("Weld", BaseEntity)

function Weld:postSpawn()
    local objs1 = map:findObjectsByName(self:getProperty("object1"))
    local obj1 = objs1[1]

    if not obj1 then return end
    if not obj1.body then return end

    local objs2 = map:findObjectsByName(self:getProperty("object2"))
    local obj2 = objs2[1]

    if not obj2 then return end
    if not obj2.body then return end

    local x, y = self:getPosition()

    self.joint = love.physics.newWeldJoint(obj1.body, obj2.body, x, y, false)
end

function Weld:destroy()
    BaseEntity.destroy(self)
    self.joint:destroy()
end

function Weld:draw()
    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle("fill", 0, 0, 10, 5)
    end
end

return Weld
