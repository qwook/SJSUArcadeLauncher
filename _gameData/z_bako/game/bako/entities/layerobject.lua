
BaseEntity = require("entities.core.baseentity")

LayerObject = class("LayerObject", BaseEntity)

function LayerObject:initialize()
    BaseEntity.initialize(self)
end

function LayerObject:isTouchingPlayer()
end

function LayerObject:update(dt)
end

function LayerObject:draw()
end

return LayerObject
