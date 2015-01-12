
-- This is an empty entity. It's created when the map editor

BaseEntity = require("entities.core.baseentity")

Node = class("Node", BaseEntity)

function Node:initialize()
    BaseEntity.initialize(self)
end

function Node:initPhysics()
end

function Node:update(dt)
end

function Node:draw()
    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle("fill", 0, 0, 10, 5)
    end
end

return Node
