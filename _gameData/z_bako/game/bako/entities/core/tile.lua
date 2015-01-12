
Physical = require("entities.core.physical")

Tile = class("Tile", Physical)

function Tile:initialize(w, h, collisiongroup)
    self.collisiongroup = collisiongroup or "shared"
    self.solid = true

    self.width = w
    self.height = h
    self.type = "TILE"
    self:initPhysics()
end

function Tile:initPhysics()
    self.body = love.physics.newBody(world, 0, 0, 'static')
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setUserData(self)
end

function Tile:getPosition()
    return self.body:getPosition()
end

function Tile:setPosition(x, y)
    self.body:setPosition(x, y)
end

function Tile:draw()
    local x, y = self:getPosition()

    -- love.graphics.setColor(255, 0, 0)
    -- love.graphics.rectangle('fill', x - self.width/2, y - self.height/2, self.width, self.height)
    -- love.graphics.setColor(0, 255, 0)
    -- love.graphics.rectangle('line', x - self.width/2, y - self.height/2, self.width, self.height)

    love.graphics.setColor(255, 0, 0)
    love.graphics.polygon("fill", self.body:getWorldPoints( self.shape:getPoints() ))

end

Tile2 = class("Tile2", Tile)
Tile2.static.rampright = true

function Tile2:initPhysics()
    local hw = self.width / 2
    local hh = self.height / 2

    self.body = love.physics.newBody(world, 0, 0, 'static')
    self.shape = love.physics.newPolygonShape(-hw, hh, hw, -hh, hw, hh)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setFriction(0.0)

    self.fixture:setUserData(self)
end

-- Triangle
Tile3 = class("Tile3", Tile)
Tile3.static.rampright = true

function Tile3:initPhysics()
    local hw = self.width / 2
    local hh = self.height / 2

    self.body = love.physics.newBody(world, 0, 0, 'static')
    self.shape = love.physics.newPolygonShape(-hw, -hh, -hw, hh, hw, -hh)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setFriction(0.0)

    self.fixture:setUserData(self)
end

-- Triangle
Tile4 = class("Tile4", Tile)
Tile4.static.rampright = true

function Tile4:initPhysics()
    local hw = self.width / 2
    local hh = self.height / 2

    self.body = love.physics.newBody(world, 0, 0, 'static')
    self.shape = love.physics.newPolygonShape(-hw, -hh, -hw, hh, hw, hh)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setFriction(0.0)

    self.fixture:setUserData(self)
end

-- Triangle
Tile5 = class("Tile5", Tile)
Tile5.static.rampright = true

function Tile5:initPhysics()
    local hw = self.width / 2
    local hh = self.height / 2

    self.body = love.physics.newBody(world, 0, 0, 'static')
    self.shape = love.physics.newPolygonShape(-hw, -hh, hw, hh, hw, -hh)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setFriction(0.0)

    self.fixture:setUserData(self)
end

return Tile
