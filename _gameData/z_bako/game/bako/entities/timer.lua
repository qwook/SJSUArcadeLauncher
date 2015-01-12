
-- This is an empty entity. It's created when the map editor
-- Doesn't supply

BaseEntity = require("entities.core.baseentity")

Timer = class("Timer", BaseEntity)

function Timer:initialize()
    BaseEntity.initialize(self)
    self.activated = false
    self.timeLife = 0
end

function Timer:event_start()
    self.timeLife = tonumber(self:getProperty("time")) or 0
end

function Timer:update(dt)
    if self.timeLife > 0 then
        self.timeLife = self.timeLife - dt
        if self.timeLife <= 0 then
            self:trigger("onend")
        end
    end
end

return Timer
