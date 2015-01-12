
-- A camera control entity
-- Triggers:
-- cameraname:setActivated(true)
-- cameraname:setActivated(false)
--
-- Events:
-- onDone

BaseEntity = require("entities.core.baseentity")

Camera = class("Camera", BaseEntity)

function Camera:initialize()
    BaseEntity.initialize(self)
    self.isCamera = true
    self.activated = false
end

function Camera:event_setactivated(activated)
    if activated == "true" then
        self.activated = true
    else
        self.activated = false
    end
end

function Camera:postSpawn()
    self.scale = self.scale or 1
end

function Camera:getCameraPosition()
    return self.x, self.y
end

function Camera:getScale()
    return 1
end

return Camera
