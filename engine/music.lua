local music = {}

local engine = nil
local useSimple = false
if ccexp and ccexp.AudioEngine then
    print("use AudioEngine")
    engine = ccexp.AudioEngine
else
    print("use SimpleAudioEngine")
    useSimple = true
    engine = cc.SimpleAudioEngine:getInstance()
end
local musicOn = true
local soundOn = true
local curMusic = nil
local curMusicId = nil
local soundEffectConfig = GMethod.loadConfig("configs/sounds.json")

function music.setBgm(music)
    if music==0 or curMusic==music then return end
    curMusic = music
    if musicOn then
        if curMusic then
            if useSimple then
                engine:playMusic(curMusic, true)
            else
                if curMusicId then
                    engine:stop(curMusicId)
                    curMusicId = nil
                end
                curMusicId = engine:play2d(curMusic, true, GEngine.getConfig("musicVol") or 1)
            end
        else
            if useSimple then
                engine:stopMusic(true)
            else
                if curMusicId then
                    engine:stop(curMusicId)
                    curMusicId = nil
                end
            end
        end
    end
end

function music.pauseBgm()
    if musicOn then
        if useSimple then
            engine:pauseMusic()
        elseif curMusicId then
            engine:pause(curMusicId)
        end
    end
end

function music.resumeBgm()
    if musicOn then
        if useSimple then
            engine:resumeMusic()
        elseif curMusicId then
            engine:resume(curMusicId)
        end
    end
end

local _shouldPreload = {}
local _effectCache = {}
function music.play(effect,isLoop)
    if soundOn then
        local ctime = socket.gettime()
        local bitem = _effectCache[effect]
        local bconf = soundEffectConfig[effect] or {0.1, 0, 0}
        if bitem then
            if ctime<bitem[1] or ctime<bitem[2] and bitem[3]>=bconf[3] then
                --print("pause play", effect, ctime, bitem[1], bitem[2], bitem[3], bconf[3])
                return
            elseif ctime>bitem[2] then
                bitem[2] = ctime+bconf[2]
                bitem[3] = 0
            end
        else
            bitem = {0, ctime+bconf[2], 0}
            _effectCache[effect] = bitem
        end
        bitem[1] = ctime+bconf[1]
        bitem[3] = bitem[3]+1
        if bconf[4] then
            effect = bconf[4][math.random(#bconf[4])]
        end
        if effect ~= "" then
            local effectID
            --wav格式转化为mp3
            local newEffect = string.sub(effect, 1, string.len(effect)-3).."mp3"
            effect = newEffect
            if useSimple then
                effectID = engine:playEffect(effect, isLoop or false)
            else
                if not _shouldPreload[effect] then
                    _shouldPreload[effect] = 2
                end
                effectID = engine:play2d(effect, isLoop or false, GEngine.getConfig("soundVol") or 1)
            end
            return effectID
        end
    end
end
function music.stop(effectID)
    if soundOn then
        if useSimple then
            engine:stopEffect(effectID)
        else
            engine:stop(effectID)
        end
    end
end
    
function music.changeBgmState(on)
    on = not (not on)
    if musicOn~=on then
        musicOn = on
        GEngine.setConfig("musicOn", on, true)
        if curMusic~=nil then
            if musicOn then
                if useSimple then
                    engine:playMusic(curMusic, true)
                else
                    if curMusicId then
                        engine:stop(curMusicId)
                        curMusicId = nil
                    end
                    curMusicId = engine:play2d(curMusic, true, GEngine.getConfig("musicVol") or 1)
                end
            else
                if useSimple then
                    engine:stopMusic(true)
                elseif curMusicId then
                    engine:stop(curMusicId)
                    curMusicId = nil
                end
            end
        end
    end
end
    
function music.changeSoundState(on)
    on = not (not on)
    if soundOn~=on then
        soundOn = on
        ButtonNode:setSoundEnable(soundOn)
        GEngine.setConfig("soundOn", on, true)
        if not soundOn then
            if useSimple then
                engine:stopAllEffects()
            else
                engine:pauseAll()
                if curMusicId then
                    engine:resume(curMusicId)
                end
            end
        end
    end
end
    
function music.getBgmState()
    return musicOn
end
    
function music.getSoundState()
    return soundOn
end

function music.preload(effect)
    if soundOn then
        if type(effect)=="string" then
            if useSimple then
                engine:preloadEffect(effect)
            else
                _shouldPreload[effect] = 1
                engine:preload(effect)
            end
        end
    end
end

function music.uncache(effect)
    engine:uncache(effect)
    _shouldPreload[effect] = nil
end

function music.uncacheAll()
    for effect, v in pairs(_shouldPreload) do
        if v == 2 then
            engine:uncache(effect)
        end
    end
end

function music.setBgmVol(vol)
    if musicOn then
        if useSimple then
            engine:setMusicVolume(vol or 1)
        end
        GEngine.setConfig("musicVol", vol or 1, true)
    end
end

function music.getBgmVol()
    if musicOn then
        if useSimple then
            return engine:getMusicVolume()
        else
            return GEngine.getConfig("musicVol") or 1
        end
    else
        return 0
    end
end

function music.setVol(vol)
    if soundOn then
        if useSimple then
            engine:setEffectsVolume(vol or 1)
        end
        GEngine.setConfig("soundVol", vol or 1, true)
    end
end

function music.getVol()
    if soundOn then
        if useSimple then
            return engine:getEffectsVolume()
        else
            return GEngine.getConfig("soundVol" or 1)
        end
    else
        return 0
    end
end

function music.init()
    music.changeBgmState(GEngine.getConfig("musicOn"))
    music.changeSoundState(GEngine.getConfig("soundOn"))
    music.setBgmVol(GEngine.getConfig("musicVol"))
    music.setVol(GEngine.getConfig("soundVol"))
end

return music
