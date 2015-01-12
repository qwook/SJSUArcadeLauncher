
require("libs.json")
bit = require("bit")

Input = class("Input")

-- This will be checked when keyBindings are loaded in from config.JSON.
-- keyBoardLayout = "arcade" -- todo: figure a way out to load config stuff
keyBoardLayout = "arcade"

timeToPause = 15
timeToReset = 10
afkTimer = 0 -- don't touch this

IN_KEYS = {
    ["attack"] = bit.lshift(1, 1);
    ["jump"]   = bit.lshift(1, 2);
    ["left"]   = bit.lshift(1, 3);
    ["right"]  = bit.lshift(1, 4);
    ["crouch"] = bit.lshift(1, 5);
    [":|"]     = bit.lshift(1, 6);
    [":/"]     = bit.lshift(1, 7);
    ["select"] = bit.lshift(1, 8);
    ["start"]  = bit.lshift(1, 9);
}

function Input:initialize()
    self.binds = {}
    self.keyCodes = 0
    self._keyCodes = 0
    self.lastKeyCodes = 0
end

function Input:loadKeyBindings()
    -- run love . dvorak for dvorak bindings
    bindings_JSON = love.filesystem.read("config.json")
    bindings_o    = json.decode(bindings_JSON)
    
    if keyBoardLayout == "dvorak" then   
        --bind all the dvorak keys for player 1.
        for key,action in pairs(bindings_o.player1.dvorak) do
            input:bind(key, action)
        end
        --bind all the dvorak keys for player 2.
        for key,action in pairs(bindings_o.player2.dvorak) do
            input2:bind(key, action)
        end
    elseif keyBoardLayout == "arcade" then
        --bind all the arcade keys for player 1.
        for key,action in pairs(bindings_o.player1.arcade) do
            input:bind(key, action)
        end
        --bind all the arcade keys for player 2.
        for key,action in pairs(bindings_o.player2.arcade) do
            input2:bind(key, action)
        end
    else
        --bind all the qwerty keys for player 1.
        for key,action in pairs(bindings_o.player1.qwerty) do
            input:bind(key, action)
        end
        --bind all the qwerty keys for player 2.
        for key,action in pairs(bindings_o.player2.qwerty) do
            input2:bind(key, action)
        end
    end
    --bind all the joystick buttons for player 1.
    for key,action in pairs(bindings_o.player1.joystick) do
        input:bind(key, action)
    end
    --bind all the joystick buttons for player 2.
    for key,action in pairs(bindings_o.player2.joystick) do
        input2:bind(key, action)
    end
end

-- usage: input:isKeyDown("attack") == true
function Input:isKeyDown(in_key)
    local key_enum = IN_KEYS[in_key]
    if key_enum == nil then return end
    return bit.band(self.keyCodes, key_enum) ~= 0
end

-- Only true for the first frame key is down. Use for jumping, etc.
function Input:wasKeyPressed(in_key)
    local key_enum = IN_KEYS[in_key]
    if key_enum == nil then return end

    return  (bit.band(self._keyCodes, key_enum) ~= 0) and
            (bit.band(self.lastKeyCodes, key_enum) == 0)
end

function Input:update()
    self.lastKeyCodes = self._keyCodes
    self._keyCodes = self.keyCodes
end

function Input:keyPress(in_key)
    if IN_KEYS[in_key] == nil then return end
    local key_enum = IN_KEYS[in_key]

    if bit.band(self.keyCodes, key_enum) == 0 then
        self.keyCodes = self.keyCodes + key_enum
    end
end

function Input:keyRelease(in_key)
    if IN_KEYS[in_key] == nil then return end
    local key_enum = IN_KEYS[in_key]

    if bit.band(self.keyCodes, key_enum) ~= 0 then
        self.lastKeyCodes = self.keyCodes
        self.keyCodes = self.keyCodes - key_enum
    end
end

function Input:eventKeyPressed(key)
    local in_key = self.binds[key]

    -- this isn't bound to anything valid. exit
    if in_key == nil then return end

    self:keyPress(in_key)
end

function Input:eventKeyReleased(key)
    local in_key = self.binds[key]

    -- this isn't bound to anything valid. exit
    if in_key == nil then return end

    self:keyRelease(in_key)
end

function Input:eventJoyPressed(key)
    local in_key = self.binds["joy_" .. key]

    if in_key == nil then return end

    self:keyPress(in_key)
end

function Input:eventJoyReleased(key)
    local in_key = self.binds["joy_" .. key]

    if in_key == nil then return end

    self:keyRelease(in_key)
end

function Input:bind(key, in_key)
    self.binds[key] = in_key
end


function love.keypressed(key, isrepeat)
    if afkTimer >= timeToPause then
        pausing = false
    end
    afkTimer = 0

    if key == "escape" then
        love.event.quit()
    end

    if not isrepeat then
        input:eventKeyPressed(key)
        input2:eventKeyPressed(key)
    end
end

function love.keyreleased(key)
    if afkTimer >= timeToPause then
        pausing = false
    end
    afkTimer = 0

    input:eventKeyReleased(key)
    input2:eventKeyReleased(key)
end

function love.joystickpressed( joystick, button )
    if afkTimer >= timeToPause then
        pausing = false
    end
    afkTimer = 0

    input:eventJoyPressed(joystick:getID() .. "_" .. button)
    input2:eventJoyPressed(joystick:getID() .. "_" .. button)
end

function love.joystickreleased( joystick, button )
    if afkTimer >= timeToPause then
        pausing = false
    end
    afkTimer = 0

    input:eventJoyReleased(joystick:getID() .. "_" .. button)
    input2:eventJoyReleased(joystick:getID() .. "_" .. button)
end

lastAxes = {}

function inputUpdate(dt)

	if love.keyboard.isDown("1") and love.keyboard.isDown("2") then
        love.event.quit()
	end

    if map.mapname ~= "assets/maps/title" then
        afkTimer = afkTimer + dt
    end

    if afkTimer >= timeToPause and map.mapname ~= "assets/maps/title" then
        pausing = true
    end

    if afkTimer >= timeToPause + timeToReset and map.mapname ~= "assets/maps/title" then
        changeMap("title")
        afkTimer = 0
        pausing = false
    end

    local joysticks = love.joystick.getJoysticks()

    -- ipairs is like pairs but for arrays
    for _, joystick in ipairs(joysticks) do
        for i = 1, joystick:getAxisCount() do
            local axis = joystick:getAxis(i)
            local lastAxis = lastAxes[joystick:getID() .. "_" .. i] or 0
            if (axis > 0) and (lastAxis <= 0) then
                input:eventJoyPressed(joystick:getID() .. "_axisup_" .. i)
                input:eventJoyReleased(joystick:getID() .. "_axisdown_" .. i)
                input2:eventJoyPressed(joystick:getID() .. "_axisup_" .. i)
                input2:eventJoyReleased(joystick:getID() .. "_axisdown_" .. i)
            elseif (axis < 0) and (lastAxis >= 0) then
                input:eventJoyPressed(joystick:getID() .. "_axisdown_" .. i)
                input:eventJoyReleased(joystick:getID() .. "_axisup_" .. i)
                input2:eventJoyPressed(joystick:getID() .. "_axisdown_" .. i)
                input2:eventJoyReleased(joystick:getID() .. "_axisup_" .. i)
            elseif (axis == 0) and (lastAxis ~= 0) then
                input:eventJoyReleased(joystick:getID() .. "_axisdown_" .. i)
                input:eventJoyReleased(joystick:getID() .. "_axisup_" .. i)
                input2:eventJoyReleased(joystick:getID() .. "_axisdown_" .. i)
                input2:eventJoyReleased(joystick:getID() .. "_axisup_" .. i)
            end
            lastAxes[joystick:getID() .. "_" .. i] = axis
        end
    end

end

return Input
