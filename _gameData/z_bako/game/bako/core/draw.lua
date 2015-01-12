local Feathering = 4.0
local Attraction = 4.0
local Break = 2.0

local camera1_x, camera1_y = 0, 0
local camera2_x, camera2_y = 0, 0

local CAM_MAX_HORIZONTAL = 100
local CAM_MAX_VERTICAL = 100

cameraLife = 0

local function drawSingleScreen()

    for i, object in pairs(map.objects) do
        if object.isCamera then
            camera1_x, camera1_y = object:getCameraPosition()
        end
    end


    local bg_ratio = love.graphics.getHeight()/map.background:getHeight()

    local offsetx = love.graphics.getWidth()/2
    local offsety = love.graphics.getHeight()/2

    love.graphics.push()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(map.background, 0, 0, 0, bg_ratio, bg_ratio)

        love.graphics.translate(math.round(-camera1_x+offsetx), math.round(-camera1_y+offsety))

        map:draw("player1")

        player2:draw()
        player:draw()
        
        for i, object in pairs(map.objects) do
            object:preDraw()
            object:draw()
            object:postDraw()
        end
        
    love.graphics.pop()

end

local function MoveCamera2D(present_x, present_y, target_x, target_y, dT)
    local dist = math.sqrt(math.pow(target_x - present_x, 2) + math.pow(target_y - present_y, 2))
    local attr = Attraction / (dist + Attraction)
    local br = Break / (dist + Break)
    local alpha = Feathering * dT + attr - br -- MAGIC
    return math.lerp(present_x, present_y, target_x, target_y, alpha)
end


local function drawSplitScreen()

    local offsetx = love.graphics.getWidth()/2
    local offsety = love.graphics.getHeight()/2

    local p1x, p1y = player:getPosition()
    local p2x, p2y = player2:getPosition()

    local goal1x, goal1y = p1x, p1y
    local goal2x, goal2y = p2x, p2y

    local timestepScale = 1

    -- custom camera object
    for i, object in pairs(map.objects) do
        if object.isCamera and object.activated then
            goal1x, goal1y = object:getCameraPosition()
            goal2x, goal2y = object:getCameraPosition()
            timestepScale = 0.25
            cameraLife = 1 -- keep refreshing the camera life everytime we draw
            -- so that when we dont have a camera, we just ease ourself back in.
        end
    end

    local dT = love.timer.getDelta() * timestepScale

    camera1_x, camera1_y = MoveCamera2D(camera1_x, camera1_y, goal1x, goal1y, dT);
    camera2_x, camera2_y = MoveCamera2D(camera2_x, camera2_y, goal2x, goal2y, dT);

    -- make it so if the player goes faster the the camera
    -- we snap the camera.
    if cameraLife <= 0 then
        camera1_x = math.clamp(camera1_x, p1x - CAM_MAX_HORIZONTAL, p1x + CAM_MAX_HORIZONTAL)
        camera1_y = math.clamp(camera1_y, p1y - CAM_MAX_VERTICAL, p1y + CAM_MAX_VERTICAL)
        camera2_x = math.clamp(camera2_x, p2x - CAM_MAX_HORIZONTAL, p2x + CAM_MAX_HORIZONTAL)
        camera2_y = math.clamp(camera2_y, p2y - CAM_MAX_VERTICAL, p2y + CAM_MAX_VERTICAL)
    end

    local bg_ratio = love.graphics.getHeight()/map.background:getHeight()

    love.graphics.push()
        love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight()/2)

        love.graphics.translate(0, math.round(-love.graphics.getHeight()/4))

        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(map.background, -camera1_x/50, -camera1_y/40, 0, bg_ratio, bg_ratio)

        love.graphics.translate(math.round(-camera1_x+offsetx), math.round(-camera1_y+offsety))

            if not collisionSwapped then
                map:draw("player1")
            else
                map:draw("player2")
            end

            for i, object in pairs(map.objects) do
                if object.zindex == -1 then
                    object:preDraw()
                    object:draw()
                    object:postDraw()
                end
            end
            
            player2:draw()
            player:draw()

            for i, object in pairs(map.objects) do
                if (object.zindex == 0 or object.zindex == nil) and object.visible ~= false then
                    if (object.collisiongroup == nil or
                        object.collisiongroup == "shared" or
                        object.collisiongroup == "blue") or
                        (object.visibleonboth == "true") then
                        object:preDraw()
                        object:draw()
                        object:postDraw()
                    end
                end
            end

        love.graphics.setScissor()

    love.graphics.pop()



    love.graphics.push()
        love.graphics.setScissor(0, love.graphics.getHeight()/2, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.translate(0, love.graphics.getHeight()/4)

        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(map.background, -camera2_x/50, -camera2_y/40, 0, bg_ratio, bg_ratio)

        love.graphics.translate(-camera2_x+offsetx, -camera2_y+offsety)

            if not collisionSwapped then
                map:draw("player2")
            else
                map:draw("player1")
            end

            for i, object in pairs(map.objects) do
                if object.zindex == -1 then
                    object:preDraw()
                    object:draw()
                    object:postDraw()
                end
            end

            player:draw()
            player2:draw()

            for i, object in pairs(map.objects) do
                if (object.zindex == 0 or object.zindex == nil) and object.visible ~= false then
                    if (object.collisiongroup == nil or
                        object.collisiongroup == "shared" or
                        object.collisiongroup == "green") or
                        (object.visibleonboth == "true") then
                        object:preDraw()
                        object:draw()
                        object:postDraw()
                    end
                end
            end

        love.graphics.setScissor()

    love.graphics.pop()

end

function love.draw()

    if singleCamera then
        drawSingleScreen()
    else
        drawSplitScreen()
    end

    if changeMapTime > 0 then
        love.graphics.setColor(255, 255, 255, (1 - changeMapTime)*255)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    if changeMapTimeOut > 0 then
        love.graphics.setColor(255, 255, 255, changeMapTimeOut*255)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    if pausing then
        love.graphics.setColor(0, 0, 0, 100)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        local timer = 9 - math.floor((afkTimer - timeToPause) / timeToReset * 10)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("Continue?\n" .. timer, 0, love.graphics.getHeight()/2-50, love.graphics.getWidth()/4, "center", 0, 4, 4)
    end

end
