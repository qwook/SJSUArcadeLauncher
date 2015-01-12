-------------------------------
-- Cache, load, and play sounds

local soundLibrary = {}

function cacheSound(name)
    soundLibrary[name] = soundLibrary[name] or love.audio.newSource("assets/sounds/" .. name)
end

function playSound(name, volume)
    soundLibrary[name] = soundLibrary[name] or love.audio.newSource("assets/sounds/" .. name)
    soundLibrary[name]:setVolume(volume or 1)
    soundLibrary[name]:play()
end

------------------------------
-- Cache, load, and play music

local musicLibrary = {}

function cacheMusic(name)
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource("assets/music/" .. name)
end

function playMusic(name, volume)
    for name, source in pairs(musicLibrary) do source:stop() end
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource("assets/music/" .. name)
    musicLibrary[name]:setVolume(volume)
    musicLibrary[name]:setLooping(true)
    musicLibrary[name]:play()
end
