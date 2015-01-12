
Physical = require("entities.core.physical")

BaseEntity = class("BaseEntity", Physical)

function BaseEntity:initialize()
    self.type = "PHYSBOX"

    self.name = "noname"
    self.contacts = {}
    self.touching = {}
    self.properties = {}
    self.visible = true
    self.frozen = false
    self.solid = true
    self.collisiongroup = "shared"
    self.color = {r = 255, g = 255, b = 255, a = 255}
    self.x = 0
    self.y = 0
    self.r = 0

    table.insert(map.objects, self)
end

function BaseEntity:destroy()
    table.removevalue(map.objects, self)

    if self.fixture then
        self.fixture:destroy()
    end
    if self.body then
        self.body:destroy()
    end
    self.body = nil
    self.fixture = nil
    self.shape = nil
end

function BaseEntity:makeSolid(type, shape)
    self.body = love.physics.newBody(world, self.x, self.y, self:getProperty("phystype") or type)
    self.shape = shape
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setUserData(self)
end

function BaseEntity:initPhysics()
end

-- Tiled wrongly positions some stuff
-- so use this function to offset the entity
function BaseEntity:fixSpawnPosition()
end

function BaseEntity:postSpawn()
end

function BaseEntity:setProperty(name, value)
    self.properties[name:lower()] = value
end

function BaseEntity:getProperty(name)
    for k,v in pairs(self.properties) do
        if k:lower() == name:lower() then
            return v
        end
    end
end

function BaseEntity:call(name, args)
    if self["event_" .. name:lower()] then
        self["event_" .. name:lower()](self, unpack(args))
    else
        print("[map warning: " .. self.name .. "] no such event named: " .. name)
    end
end

function BaseEntity:trigger(event, activator)
    local n = self:getProperty(event)
    if n then
        local events = {}
        string.gsub(n..";", "([^;]+);", function(a) table.insert(events, a) end)
        for _, i in pairs(events) do
            self:eval(i, activator)
        end
    end
end

-- evaluate and execute map code
function BaseEntity:eval(str, activator)
    -- (name):(event)((arg))
    local name, event, arg = string.match(str, "([0-9A-z]+)%:([0-9A-z]+)%(([^%)]*)%)")

    if not name then print("[map syntax error: " .. self.name .. "] no name") return end
    if not event then print("[map syntax error: " .. self.name .. "] no event") return end

    name = string.lower(name)
    event = string.lower(event)

    -- split the arguments and store them in a table
    local args = {}
    string.gsub(arg, "[^, ]+", function(a) table.insert(args, a) end)

    local objs = {}

    if name == "global" then
        if events[event] then
            events[event](events[event], unpack(args))
        end
        return
    elseif name == "self" then
        objs = {self}
    elseif name == "player1" then
        objs = {player}
    elseif name == "player2" then
        objs = {player2}
    elseif name == "activator" then
        objs = {activator}
    else
        for k,v in pairs(map.objects) do
            if v.name == name then
                table.insert(objs, v)
            end
        end
    end

    if #objs == 0 then
        print("[map warning: " .. self.name .. "] no such object named: " .. name)
    end

    for k, obj in pairs(objs) do
        if (obj.call) then
            obj:call(event, args)
        end
    end

end

function BaseEntity:event_setcolor(r, g, b, a)
    self.color = {r = tonumber(r), g = tonumber(g), b = tonumber(b), a = tonumber(a)}
end

function BaseEntity:event_setcollisiongroup(group)
    self.collisiongroup = group
    player:forceCollisionRecalculation()
    player2:forceCollisionRecalculation()
end

function BaseEntity:event_destroy()
    self:destroy()
end

function BaseEntity:event_teleportto(name)

    for k,v in pairs(map.objects) do
        if v.name == name then
            self:setPosition(v:getPosition())
            return
        end
    end
end


function BaseEntity:event_setgravity(gravity)
    if not self.body then return end
    self.body:setGravityScale(tonumber(gravity))
end

-- when you freeze a box, you basically weld it to the world
function BaseEntity:event_setfrozen(frozen)
    if not self.body then return end
    if frozen == "true" then
        self.frozen = true
        if self.frozenJoint or not self.visible then return end
        local x, y = self:getPosition()
        self.frozenJoint = love.physics.newWeldJoint(self.body, map.body, x, y, true)
    elseif frozen == "false" then
        self.frozen = false
        if not self.frozenJoint or not self.visible then return end
        self.frozenJoint:destroy()
        self.frozenJoint = nil
    end
end

-- visibility disables physics and drawing
function BaseEntity:event_setvisible(visible)
    if visible == "true" then
        -- automatically freeze them
        -- so they dont fall through the world
        if not self.frozen then
            if self.frozenJoint then
                self.frozenJoint:destroy()
                self.frozenJoint = nil
            end
        end
        self.visible = true
    elseif visible == "false" then
        if self.visible then
            if not self.frozenJoint and self.body then
                local x, y = self:getPosition()
                self.frozenJoint = love.physics.newWeldJoint(self.body, map.body, x, y, true)
            end
        end
        self.visible = false
    end
    player:forceCollisionRecalculation()
    player2:forceCollisionRecalculation()
end

function BaseEntity:event_setposition(x, y)
    self:setPosition(tonumber(x), tonumber(y))
end

function BaseEntity:event_setangle(r)
    self:setAngle(tonumber(r))
end

function BaseEntity:event_setvelocity(x, y)
    self.body:setLinearVelocity(tonumber(x), tonumber(y))
end

function BaseEntity:event_multiplyvelocity(x, y)
    local velx, vely = self.body:getLinearVelocity()
    self.body:setLinearVelocity(velx*tonumber(x), vely*tonumber(y))
end

function BaseEntity:event_addvelocity(x, y)
    local velx, vely = self.body:getLinearVelocity()
    self.body:setLinearVelocity(velx+tonumber(x), vely+tonumber(y))
end

function BaseEntity:setPosition(x, y)
    self.x = x
    self.y = y

    if self.body then
        local hadFrozenJoint = false
        if self.frozenJoint then
            hadFrozenJoint = true
            self.frozenJoint:destroy()
        end
        self.body:setPosition(x, y)
        if hadFrozenJoint then
            local x, y = self:getPosition()
            self.frozenJoint = love.physics.newWeldJoint(self.body, map.body, x, y, true)
        end
    end
end

function BaseEntity:getPosition()
    if not self.body then
        return self.x, self.y
    end
    return self.body:getPosition()
end

function BaseEntity:setAngle(r)
    self.r = r

    if self.body then
        local hadFrozenJoint = false
        if self.frozenJoint then
            hadFrozenJoint = true
            self.frozenJoint:destroy()
        end
        self.body:setAngle(r)
        if hadFrozenJoint then
            local x, y = self:getPosition()
            self.frozenJoint = love.physics.newWeldJoint(self.body, map.body, x, y, true)
        end
    end
end

function BaseEntity:getAngle()
    if not self.body then return self.r end
    return self.body:getAngle()
end

function BaseEntity:setVelocity(x, y)
    self.body:setLinearVelocity(x, y)
end

function BaseEntity:getVelocity()
    return self.body:getLinearVelocity()
end

function BaseEntity:setFriction(frict)
    if not self.fixture then return end
    self.fixture:setFriction(frict)
end

function BaseEntity:getFriction()
    return self.fixture:getFriction()
end

function BaseEntity:setSensor(bool)
    if not self.fixture then return end
    self.fixture:setSensor(bool)
end

function BaseEntity:update(dt)
end

function BaseEntity:preDraw()
    local x, y = self:getPosition()
    local r = self:getAngle()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r)

    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
end

function BaseEntity:postDraw()
    love.graphics.pop()

    if DEBUG and self.body and self.shape then
        love.graphics.setColor(255, 0, 0, 100)
        if self.shape:typeOf("PolygonShape") then
            love.graphics.polygon("fill", self.body:getWorldPoints( self.shape:getPoints() ))
        elseif self.shape:typeOf("CircleShape") then
            local x, y = self:getPosition()
            love.graphics.circle("fill", x, y, self.shape:getRadius())
        end
    end
end

function BaseEntity:draw()
end

function BaseEntity:beginContact(other, contact)
    table.insert(self.contacts, contact)
    table.insert(self.touching, other)
end

function BaseEntity:endContact(other, contact)
    table.removevalue(self.contacts, contact)
    table.removeonevalue(self.touching, other)
end

return BaseEntity
