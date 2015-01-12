
-- A camera control entity
-- Triggers:
-- cameraname:setActivated(true)
-- cameraname:setActivated(false)
--
-- Events:
-- onDone

BaseEntity = require("entities.core.baseentity")

RushCamera = class("RushCamera", BaseEntity)

function RushCamera:initialize()
    BaseEntity.initialize(self)
    self.isCamera = true
    self.activated = false
end

function RushCamera:event_setactivated(activated)
    if activated == "true" then
        self.activated = true
    else
        self.activated = false
    end
end

function RushCamera:postSpawn()
    self.scale = self.scale or 1
end

function RushCamera:getRushCameraPosition()
    return self.x, self.y
end

function RushCamera:getScale()
    return 1
end

return RushCamera
