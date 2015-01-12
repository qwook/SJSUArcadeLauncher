------------------------
-- Cache and load images

local imageLibrary = {}

function cacheImage(name)
    imageLibrary[name] = imageLibrary[name] or love.graphics.newImage("assets/" .. name)
    imageLibrary[name]:setFilter("nearest", "nearest")
end

function loadImage(name)
    imageLibrary[name] = imageLibrary[name] or love.graphics.newImage("assets/" .. name)
    imageLibrary[name]:setFilter("nearest", "nearest")
    return imageLibrary[name]
end
