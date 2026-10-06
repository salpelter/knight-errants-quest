AudioManager = {}
AudioManager.__index = AudioManager

function AudioManager.new()
    local self = {}
    setmetatable(self, AudioManager)
    
    self.sounds = {}
    self.music = nil
    self.musicVolume = 0.5
    self.sfxVolume = 0.7
    
    self:loadSounds()
    self:loadMusic()
    
    return self
end

function AudioManager:loadSounds()
    -- optional - the game will work without them
    local soundFiles = {
        "collect",
        "damage", 
        "victory",
        "menu_select"
    }
    
    for _, soundName in ipairs(soundFiles) do
        local path = "Audio/" .. soundName .. ".ogg"
        if love.filesystem.getInfo(path) then
            self.sounds[soundName] = love.audio.newSource(path, "static")
            self.sounds[soundName]:setVolume(self.sfxVolume)
        end
    end
end

function AudioManager:loadMusic()
    local musicPath = "Audio/background_music.ogg"
    if love.filesystem.getInfo(musicPath) then
        self.music = love.audio.newSource(musicPath, "stream")
        self.music:setVolume(self.musicVolume)
        self.music:setLooping(true)
        self.music:play()
    end
end

function AudioManager:playSound(soundName)
    if self.sounds[soundName] then
        self.sounds[soundName]:stop()
        self.sounds[soundName]:play()
    else
        -- sound not found
    end
end

function AudioManager:playCollectSound()
    self:playSound("collect")
end

function AudioManager:playDamageSound()
    self:playSound("damage")
end

function AudioManager:playVictorySound()
    self:playSound("victory")
end

function AudioManager:playMenuSelect()
    self:playSound("menu_select")
end

function AudioManager:setVolume(volume)
    self.sfxVolume = volume
    for _, sound in pairs(self.sounds) do
        if sound then
            sound:setVolume(volume)
        end
    end
end

return AudioManager
