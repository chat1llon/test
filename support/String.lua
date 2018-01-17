StringManager = nil
do
    local stringCache = {}
    --用于服务器传过来的string
    local userDefaultStringCache = {}

    local function init(language)
        GEngine.lockG(false)
        function Entry(key, ...)
            stringCache[key] = select(language, ...)
        end
        if GEngine.rawConfig.DEBUG_STRING then
            require "data.mstrings"
            package.loaded["data.mstrings"] = nil
        else
            require "data.strings"
            package.loaded["data.strings"] = nil
        end
        userDefaultStringCache=GEngine.getConfig("strings") or {}
        Entry = nil
        GEngine.lockG(true)
    end
    local function init2(lpath)
        GEngine.lockG(false)
        function Entry(key, value)
            stringCache[key] = value
        end
        if GEngine.rawConfig.DEBUG_STRING then
            require "data.mstrings"
            package.loaded["data.mstrings"] = nil
        else
            require(lpath)
            package.loaded[lpath] = nil
        end
        Entry = nil
        GEngine.lockG(true)
    end
    
    local function getString(key)
        return userDefaultStringCache[key] or stringCache[key] or key
    end
    
    local function formatString(s, param)
        local function stringFormat(k)
            local pk = string.sub(k, 2, -2)
            return param[pk] or k
        end
        local ret = string.gsub(s, "%[[a-zA-Z]+%]", stringFormat)
        return ret
    end
    
    local function getFormatString(key, param)
        return formatString(getString(key), param)
    end
    
    local timeSeq = {"tmSec", "tmMin", "tmHr", "tmDay"}
    local timeSeq1 = {"", ":", ":", ":"}
    local timeMod = {60, 60, 24, 100000000}
    --accuracy 精度 1秒2分3时4天
    local function getTimeString(timeInSeconds,accuracy,fmt2,full,en,maxAcc)
        if not accuracy then
            accuracy = 1
        end
        -- 用于规定最大显示单位
        if not maxAcc then
            maxAcc = 4
        end
        if not timeInSeconds or timeInSeconds<0 then
            return getString("wordNone")
        else
            local ret, retSeq, retIndex, retTime,time = "0", {}, 0, {}, math.floor(timeInSeconds)
            for i=1, 4 do
                local temp
                if i == maxAcc then
                    temp = time % timeMod[4]
                    time = math.floor(time/timeMod[4])
                else
                    temp = time % timeMod[i]
                    time = math.floor(time/timeMod[i])
                end
                retTime[i] = temp
                retIndex = i
                if fmt2 then
                    retSeq[i] = string.format("%02d",temp) .. getString(en and timeSeq1[i] or timeSeq[i])
                else
                    retSeq[i] = string.format("%d",temp) .. getString(en and timeSeq1[i] or timeSeq[i])
                end
                --print(i,temp,time,retSeq[i])
                if time==0 then break end
            end

            ret = retSeq[retIndex]
            if full then
                local maxLen = 4
                if type(full) == "number" then
                    maxLen = full - 1
                end
                while(retSeq[retIndex-1])
                do
                    if retIndex-1 < accuracy then
                        break
                    end
                    if maxLen <= 0 then
                        break
                    end
                    maxLen = maxLen - 1
                    ret = ret .. " " .. retSeq[retIndex-1]
                    retIndex = retIndex - 1
                end
            else
                while(retSeq[retIndex-1] and retTime[retIndex-1] and retTime[retIndex-1] > 0 )
                do
                    if retIndex-1 < accuracy then
                        break
                    end
                    ret = ret .. " " .. retSeq[retIndex-1]
                    retIndex = retIndex - 1
                end
            end
            return ret
        end
    end

    --保留两个时间单位
    local function getFixTimeString(time,accuracy,fmt2)
        if not accuracy then accuracy = 1 end
        if not fmt2 then fmt2 = true end
        if time > 24*60*60 then
            accuracy = 3
        elseif time>60*60 then
            accuracy = 2
        else
            accuracy = 1
        end
        return getTimeString(time,accuracy,fmt2)
    end

    --保留一个时间单位
    local function getFixTimeString2(time,accuracy,fmt2)
        if not accuracy then accuracy = 1 end
        if not fmt2 then fmt2 = false end
        if time > 24*60*60 then
            accuracy = 4
        elseif time>60*60 then
            accuracy = 3
        elseif time>60 then
            accuracy = 2
        end
        return getTimeString(time,accuracy,fmt2)
    end
    
    local function getNumberString(num)
        return tostring(num)
        -- local s = ""
        -- local prefix = ""
        -- if num<0 then
        --     num = -num
        --     prefix = "-"
        -- end
        -- if num<1000 then
        --     s = tostring(num)
        -- else
        --     local num2
        --     while num>=1000 do
        --         num2 = num%1000
        --         s = " " .. string.format("%03d", num2) .. s
        --         num = (num-num2)/1000
        --     end
        --     s = tostring(num) .. s
        -- end
        -- return prefix .. s
    end
    
    StringManager = {init=init, init2=init2,getString=getString, formatString=formatString, getFormatString = getFormatString, getTimeString=getTimeString, getFixTimeString=getFixTimeString,getFixTimeString2=getFixTimeString2,getNumberString=getNumberString}

    function StringManager.getFormatTime(t)
        if t<0 then
            t = 0
        end
        return string.format("%02d:%02d:%02d", math.floor(t/3600), math.floor((t%3600)/60), math.floor(t%60))
    end

    function StringManager.addStrings()
        if GEngine.getConfig("strings") then
            userDefaultStringCache=json.decode(GEngine.getConfig("strings"))
        end
    end
end
