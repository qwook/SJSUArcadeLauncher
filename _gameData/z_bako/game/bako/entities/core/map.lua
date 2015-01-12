
STI =           require("libs.sti")
traceTiles =    require("libs.mapedgetrace")

Tile =          require("entities.core.tile")
Physical =      require("entities.core.physical")

Map = class("Map", Physical)

function Map:initialize(mapname)
    self.mapname = mapname
    self.map = {}
    self.objects = {}

    self.tiledmap = STI.new(mapname)

    self.background = self:getImageLayer("Background")

    local tw = self.tiledmap.tilewidth
    local th = self.tiledmap.tileheight

    self:generateTileCollision("SharedCollision", "shared")
    self:generateTileCollision("GreenCollision", "green")
    self:generateTileCollision("BlueCollision", "blue")
end

-- giant wrapper for the tiled loader
-- don't worry about it
function Map:generateTileCollision(layername, collisiongroup)

    if not self.tiledmap.layers[layername] then
        return
    end

    local collision = self.tiledmap:getCollisionMap(layername).data

    local tiles = {}
    for y, row in pairs(collision) do
        for x, tile in pairs(row) do
            if (tile == 1) then
                if self.tiledmap.layers[layername].data[y][x].properties then
                    local colshape = self.tiledmap.layers[layername].data[y][x].properties.colshape
                    if colshape == "1" then
                        tiles[x] = tiles[x] or {}
                        tiles[x][y] = 1
                    end
                end
            end
        end
    end

    local hack = Physical:new()
    hack.collisiongroup = collisiongroup
    hack.solid = true
    hack.type = "TILE"

    self.polylines = traceTiles(tiles, 32, 32)
    for _, tracedShape in pairs(self.polylines) do

        local shape = love.physics.newChainShape(false, unpack(tracedShape))
        local body = love.physics.newBody(world, 0, 0, 'static')
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData(hack)
        fixture:setFriction(0.5)

        self.body = body
        
    end

    for y, row in pairs(collision) do
        for x, tile in pairs(row) do
            if (tile == 1) then
                if self.tiledmap.layers[layername].data[y][x].properties then
                    local data = self.tiledmap.layers[layername].data[y][x]
                    local colshape = data.properties.colshape

                    -- this is the worst thing i've ever written in my entire life

                    local ang = -1

                    if (colshape == "2") then
                        ang = 0
                    elseif (colshape == "4") then
                        ang = 1
                    elseif (colshape == "3") then
                        ang = 2
                    elseif (colshape == "5") then
                        ang = 3
                    end

                    if data.r == math.rad(-90) then
                        ang = 2*ang - 1
                    elseif data.r == math.rad(90) then
                        ang = ang + 1
                    end

                    ang = ang % 4

                    if data.sx == -1 then
                        if ang == 0 then
                            ang = 1
                        elseif ang == 1 then
                            ang = 0
                        elseif ang == 2 then
                            ang = 3
                        elseif ang == 3 then
                            ang = 2
                        end
                    end

                    if data.sy == -1 then
                        if ang == 0 then
                            ang = 3
                        elseif ang == 3 then
                            ang = 0
                        elseif ang == 1 then
                            ang = 2
                        elseif ang == 2 then
                            ang = 1
                        end
                    end

                    if (colshape ~= "1") then
                        if (ang == -1) then
                            -- this is handled by the optimizer, just kept in incase STI is stupid
                            -- self:set(x, y, Tile:new(self.tiledmap.tilewidth, self.tiledmap.tileheight))
                        elseif (ang == 0) then
                            self:set(x, y, Tile2:new(self.tiledmap.tilewidth, self.tiledmap.tileheight, collisiongroup))
                        elseif (ang == 2) then --
                            self:set(x, y, Tile3:new(self.tiledmap.tilewidth, self.tiledmap.tileheight, collisiongroup))
                        elseif (ang == 1) then --
                            self:set(x, y, Tile4:new(self.tiledmap.tilewidth, self.tiledmap.tileheight, collisiongroup))
                        elseif (ang == 3) then
                            self:set(x, y, Tile5:new(self.tiledmap.tilewidth, self.tiledmap.tileheight, collisiongroup))
                        end
                    end
                end
            end
        end
    end
end

-- spawn the objects defined in a map
function Map:spawnObjects()
    local spawned = {}
    for _, v in ipairs(self:getObjectsLayer("Objects")) do
        -- spawnpoint for player 1
        if v.name == "player1" then
            player = Player:new()
            player:setController(input)
            -- tiled positional data being janky
            -- this offsets the player
            player:setPosition(v.x + 32 + 16, v.y - 32 + 16)
        -- spawnpoint for player 2
        elseif v.name == "player2" then
            player2 = Cindy:new()
            player2:setController(input2)
            player2:setPosition(v.x + 32 + 16, v.y - 32 + 16)
        end

        -- so this determines the class by the Type
        -- Node is the default class for each object
        local c = Node
        if tostring(v.type) and _G[v.type] and type(_G[v.type]) == "table" then
            -- alright so we found a class that matches the type
            -- lets create that
            c = _G[v.type]
        end

        -- create the object
        local instance = c:new(v.x, v.y, v.width, v.height)
        instance.name = v.name
        instance.brushx = v.x
        instance.brushy = v.y
        instance.brushw = v.width
        instance.brushh = v.height

        -- tiled is very janky and offsets stuff
        if v.width == 0 and v.height == 0 then
            instance.brushy = instance.brushy - 32
            instance.brushw = 32
            instance.brushh = 32
        end

        -- set all the properties of the object
        for prop, val in pairs(v.properties) do
            instance:setProperty(prop, val)
        end

        -- set the position and then offset it
        instance:setPosition(instance.brushx + instance.brushw/2 + 32, instance.brushy + instance.brushh/2 + 32)
        instance:fixSpawnPosition() -- additional fixes for special objects

        -- insert the object in our `spawned` pool
        table.insert(spawned, instance)
    end

    -- we do all the main stuff after we set the properties
    -- mostly because most of this stuff depends on the properties
    -- being set on every object.

    -- initialize all the physics for the
    -- spawned map objects
    for k,v in pairs(spawned) do
        v:initPhysics()

        v.collisiongroup = v:getProperty("collisiongroup") or "shared"
        v:event_setfrozen(v:getProperty("frozen"))

        if v.fixture and v.body then
            v.fixture:setFriction(v:getProperty("friction") or 0.1)
            v.body:setMass(v:getProperty("mass") or 1)
            v.body:setFixedRotation(v:getProperty("disablerotation") == "true")
        end
    end

    for k,v in pairs(spawned) do
        v:postSpawn()
        v:trigger("onspawn")
    end
end

function Map:findObjectsByName(name)
    local objs = {}

    for k,v in pairs(self.objects) do
        if v.name == name then
            table.insert(objs, v)
        end
    end

    return objs
end

function Map:getImageLayer(layername)
    if self.tiledmap.layers[layername] == nil then return nil end
    return self.tiledmap.layers[layername].image
end

function Map:getObjectsLayer(layername)
    if self.tiledmap.layers[layername] == nil then return {} end
    return self.tiledmap.layers[layername].objects or {}
end

function Map:initPhysics()
    -- self.body = love.physics.newBody(world, 0, 0, 'dynamic')
    -- self.shape = love.physics.newRectangleShape(50, 50)
    -- self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function Map:set(x, y, tile)
    self.map[y] = self.map[y] or {}
    self.map[y][x] = tile

    tile:setPosition((x+1/2) * self.tiledmap.tilewidth, (y+1/2) * self.tiledmap.tileheight)
end

function Map:get(x, y)
    if self.map[y] == nil then
        return nil
    end

    return self.map[y][x]
end

function Map:drawLayer(layerName)
    if not self.tiledmap.layers[layerName] then return end
    self.tiledmap:drawTileLayer(self.tiledmap.layers[layerName])
end

function Map:draw(player)
    love.graphics.push()
    love.graphics.translate(self.tiledmap.tilewidth, self.tiledmap.tileheight)
    love.graphics.setColor(255, 255, 255, 255)

    if player == "player1" then
        self:drawLayer("BlueLayer")
    elseif player == "player2" then
        self:drawLayer("GreenLayer")
    end

    self:drawLayer("SharedLayer")

    self:drawLayer("Decoration")
    love.graphics.pop()

    -- debug drawings:

    -- self.tiledmap:drawCollisionMap()
    -- for y, row in pairs(self.map) do
    --     for x, tile in pairs(row) do
    --         tile:draw()
    --     end
    -- end
    -- for i=1,#self.polylines do
    --     love.graphics.line(self.polylines[i])
    -- end
end

return Map
