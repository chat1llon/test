GEngine = {engine=GameEngine:getInstance(), MVC={M={},V={},C={}}}
GConst = {}
GMethod = {}
local _General = {}
General = {}
local valuesonlyMeta = {}
function valuesonlyMeta.__index(t, key)
    return _General[key]
end
function valuesonlyMeta.__newindex(t, key, value)
    local vtype = type(value)
    if vtype=="table" or vtype=="userdata" or vtype=="function" then
        log.d("set valueonly table with type:\"%s\", key:\"%s\"", vtype, key)
        return
    end
    _General[key] = value
    return value
end
setmetatable(General, GConst.valuesonlyMeta)
local weaksMeta = {k={__mode="k"},v={__mode="v"},kv={__mode="kv"}}
function GMethod.getWeakTable(weakType)
    local t = {}
    setmetatable(t, weaksMeta[weakType])
    return t
end

--设置常量
GConst.Color = {Black={0,0,0},White={255,255,255},Red={255,57,57},Green={0,255,0},Blue={0,0,255}, GOrange={242,183,19}, Brown={57,17,12}, OkGreen={42,126,4}}
GConst.Align = {Left=0, Center=1, Right=2}
GConst.Anchor = {
    LeftTop={0,1},Top={0.5,1},RightTop={1,1},
    Left={0,0.5},Center={0.5,0.5},Right={1,0.5},
    LeftBottom={0,0},Bottom={0.5,0},RightBottom={1,0}
}
GConst.Scale = {Height=1, Width=2, Big=3, Small=4, Dialog=5}

--Lee添加的一些方法

--树形打印table
function print_r(root)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            
            if type(v) == "table" then
                if cache[v] then
                    table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
                    log.e("circle print",k)
                else
                    local new_key = name .. "." .. key
                    cache[v] = new_key

                    table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
                end
            elseif type(v) ~= "userdata" then
                table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return table.concat(temp,"\n"..space)
    end
    log.d('\n'.._dump(root, "",""))
end
--分割字符串
function string.split(szFullString, szSeparator)  
local nFindStartIndex = 1  
local nSplitIndex = 1  
local nSplitArray = {}  
while true do  
   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
   if not nFindLastIndex then  
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
    break  
   end  
   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
   nSplitIndex = nSplitIndex + 1  
end  
return nSplitArray  
end 

function equalTable(m1,m2)
    local t = true
    for k,v in pairs(m1) do
        if m2[k] == v then

        else
            t = false
        end
    end
    for k,v in pairs(m2) do
        if m1[k] == v then
        else
            t = false
        end
    end
    return t
end


--一个什么都不做的方法；
GMethod.doNothing = function()
end

--因为execute不调用require的寻址功能，所以通过require伪造一个execute
function GMethod.execute(scriptName)
    package.loaded[scriptName] = nil
    return require(scriptName)
end

--保护执行json的decode; 原则上，所有来自外部的json字符串都必须在保护模式下执行
--发现多此一举了，因为json本身就是保护模式的
--另外json文件大部分格式不对
function GMethod.safeJsonDecode(jstr)
    if type(jstr) ~= "string" or jstr=="" then
        return nil
    end
    local suc, jdata = pcall(json.decode, jstr)
    if suc then
        return jdata
    end
    return nil
end

local _cfg_cache = {}
local _debug_cfg_mode = false

function GMethod.setConfigMode(debug)
    _debug_cfg_mode = debug
    if debug then
        _cfg_cache = {}
    end
end

function GMethod.loadConfig(configName)
    if not _debug_cfg_mode and _cfg_cache[configName] then
        return _cfg_cache[configName]
    end
    local ccstr = cc.FileUtils:getInstance():getStringFromFile(configName)
    if not ccstr then
        return
    end
    local ret = GMethod.safeJsonDecode(ccstr)
    if not _debug_cfg_mode then
        _cfg_cache[configName] = ret
    end
    return ret
end

--使用自己的require，主要是用于区分哪些是引擎层修改，哪些是脚本层修改
--便于动态重启游戏
local _scriptCache = {}
function GMethod.loadScript(scriptName)
    if _scriptCache[scriptName] then
        return _scriptCache[scriptName]
    end
    local rt = require(scriptName)
    _scriptCache[scriptName] = rt
    return rt
end
function GMethod.unloadAllScript()
    local pl = package.loaded
    for k, v in pairs(_scriptCache) do
        _scriptCache[k] = nil
        pl[k] = nil
    end
end

local _scheduler = cc.Director:getInstance():getScheduler()
local _schedulerCache = {}

function GMethod.schedule(func, interval, pause)
    local ret = _scheduler:scheduleScriptFunc(func, interval, pause)
    _schedulerCache[ret] = true
    return ret
end

function GMethod.unschedule(entryId)
    _schedulerCache[entryId] = nil
    return _scheduler:unscheduleScriptEntry(entryId)
end

function GMethod.clearSchedule()
    for k, v in pairs(_schedulerCache) do
        _scheduler:unscheduleScriptEntry(k)
    end
    _schedulerCache = {}
end

local _gtime = 0
local _atime = 0
function GMethod.getGTime()
    return _gtime
end
function GMethod.getGATime()
    return _atime
end
local function _gUpdate(diff)
    _atime = _atime + diff
    _gtime = _gtime + diff/_scheduler:getTimeScale()
end

function GMethod.getSortFunction(setting)
    if type(setting)~="table" then
        setting = {{setting,false}}
    elseif setting.key then
        setting = {{setting.key, setting.desc or false}}
    end
    return function(v1, v2)
        local ret = false
        for _, si in ipairs(setting) do
            if v1[si[1]]~=v2[si[1]] then
                ret = (v1[si[1]]<v2[si[1]]) ~= si[2]
                break
            end
        end
        return ret
    end
end
--配置加载sdk
function GMethod.loadPlugins()
    Plugins:init()
end

GConst.readonlyMeta = {}
function GConst.readonlyMeta.__newindex(table, key, value)
    log.d("set readonly table with key:\"%s\"", key)
    return
end
setmetatable(GConst.readonlyMeta,GConst.readonlyMeta)

--加载各个引擎模块，并以小写的形式放入全局变量
require("support.Class2")
_G.shellNode = require("engine.ShellNode")
_G.log = require("engine.log")
_G.json = require("engine.dkjson")
_G.socket = require("socket")
_G.memory = require("engine.memory")
_G.ui = require("engine.ui")
_G.music = require("engine.music")
_G.display = require("engine.display")
require("support.String")
require("support.Script")
require("support.Event")
require("support.Class")
require("support.Update")
require("support.GDefs")
require("support.GFunc")
require("engine.Alias")
require("engine.View")
require("engine.Plugins")
require("engine.Socket")

--注意，UserDefault是一个客户端的数据持久化的类，有可能会被篡改或被删除；重要的数据一定要放在服务端储存。
local cdefault = cc.UserDefault:getInstance()
local clientConfigs = {}
local configChanged = false

GEngine.platforms={
    cc.PLATFORM_OS_WINDOWS,
    cc.PLATFORM_OS_LINUX,
    cc.PLATFORM_OS_MAC,
    cc.PLATFORM_OS_ANDROID,
    cc.PLATFORM_OS_IPHONE,
    cc.PLATFORM_OS_IPAD
}

function GEngine.getPlatform()
    return cc.Application:getInstance():getTargetPlatform()
end

function GEngine.getConfig(key)
    if clientConfigs[key] then
        return clientConfigs[key]
    else
        local value = cdefault:getStringForKey(key)
        if value=="" then
            value = nil
        elseif value=="true" or value=="false" then
            value = (value=="true")
        else
            local nvalue = tonumber(value)
            if nvalue then
                value = nvalue
            end
        end
        clientConfigs[key] = value
        return value
    end
end

local _settingConfFile = "configs/settings.json"
function GEngine.getSetting(key)
    return GMethod.loadConfig(_settingConfFile)[key]
end

--注意，如果不设置store，则默认不需要持久化；用于设置不需要持久化的数值
function GEngine.setConfig(key, value, store)
    if GEngine.getConfig(key)==value then
        return
    end
    clientConfigs[key] = value
    if store then
        if value then
            cdefault:setStringForKey(key,tostring(value))
        else
            cdefault:setStringForKey(key,"")
        end
        configChanged = true
    end
end

function GEngine.saveConfig()
    if configChanged then
        cdefault:flush()
        configChanged = false
    end
end

function GEngine.quitGame()
    GEngine.saveConfig()
    GameEngine:destroyInstance()
end

local _Gkey = {}
function GEngine.stop()
    display.clear()
    GMethod.unloadAllScript()
    GMethod.clearSchedule()
    local network = GMethod.loadScript("engine.network")
    network.cancelAll()
    for i=1, 5 do
        GEngine.engine:getPackageManager():unloadPackage("data" .. i .. ".pkg")
    end
    for k,v in pairs(_G) do
        if not _Gkey[k] then
            _G[k] = nil
        end
    end
end

function GEngine.start()
    GMethod.loadPlugins()
    for k,v in pairs(_G) do
        _Gkey[k] = true
    end
    for i=1,5 do
        GEngine.engine:getPackageManager():loadPackage("data" .. i .. ".pkg")
    end
    GEngine.engine:getPackageManager():loadPackage("effects.pkg")
    GEngine.reloadScriptConfig()
    GMethod.schedule(_gUpdate, 0, false)
    GMethod.schedule(UpdateEntry, 0, false)
    --GMethod.schedule(ui.updateReuses, 1, false)
    local entry = GEngine.scrConfig.entry
    local controller = GMethod.loadScript(entry[1])

    controller[entry[2]](controller)
end

function GEngine.restart(isNeedSetRestart)
    GEngine.setConfig("isRestart",1)
    GEngine.stop()
    GEngine.start()
end

function GEngine.getDevice()
    return GEngine.rawConfig.testDevice
end

function GEngine.changeLanguage(language, isInit)
    if language==General.language and not isInit then
        return
    end
    General.language = language
    local lconf = GEngine.lanConfig.languages[language]
    if not lconf then
        language = "CN"
        lconf = GEngine.lanConfig.languages["CN"]
        General.language = language
    end
    if StringManager.init2 then
        local lan=language
        if not cc.FileUtils:getInstance():isFileExist("data/"..lan..".lua") then
            lan="strings"
        end
        StringManager.init2("data." .. lan)
    else
        StringManager.init(lconf[1])
    end
    --CaeCharacterConfiguration:destroyAllConfiguration()
    --不同字体
    local f1 = lconf[2]--数字字体
    local f3 = lconf[3]--汉字字体
    local f2 = lconf[4]--中国风字体

    local fontCache = CaeLabelFont
    local allfonts = {  {1, f1, true},
                        {2, f1, false}, 
                        {3, f2, true},
                        {4, f2, false},
                        {5, f3, true}, 
                        {6, f3, false}, 
                     }
    for _, font in ipairs(allfonts) do
        local i = font[1]
        local fname = font[2]
        local hasEdge = font[3]

        --做数字混编用的，ftype==0 需要混编，混编字体可自定义
        local ftype = 1
        if fname:find(".ttf") then
            ftype = 0
        end
        local cfont = fontCache:createFont(ftype, fname)
        fontCache:setFont(i, cfont)
        if ftype == 0 then
            if font[2] == f3 then
                cfont:setFontCharSetting(1, f1, 0.8, 0, 0)   -- 数字字体改为黑体(隶书)
                cfont:setFontOffset(0, -0.05)
            else 
                cfont:setFontCharSetting(1, f1, 1, 0, 0)   -- 数字字体改为黑体(正常黑体)
                cfont:setFontOffset(0, -0.05)
            end   
        end
        --fontSizeBegin, fontSizeEnd, fontSizeUse, int outline, shadowX, shadowY, shadowBlur
        --font[4]自定义描边和阴影设置
        if font[4] then
            cfont:setFontSuitable(0, 999.9, font[4][1], font[4][2], 0, font[4][3], 0)
        --如果有描边则按以下规则进行
        elseif hasEdge then
            cfont:setFontSuitable(0, 19.9, 14, 1, 0, -1, 0)
            cfont:setFontSuitable(20, 29.9, 20, 1, 0, -2, 0)
            cfont:setFontSuitable(30, 59.9, 30, 2, 0, -4, 0)
            cfont:setFontSuitable(60, 999.9, 60, 2, 0, -5, 0)
        --没有描边自适应字号
        else
            cfont:setFontSuitable(0, 19.9, 14, 0, 0, 0, 0)
            cfont:setFontSuitable(20, 29.9, 20, 0, 0, 0, 0)
            cfont:setFontSuitable(30, 59.9, 30, 0, 0, 0, 0)
            cfont:setFontSuitable(60, 999.9, 60, 0, 0, 0, 0)
        end
        if (i == 1 or i == 2) then 
           cfont:setFontOffset(0, -0.45) -- 打手机包的时候要设置字体偏移
        end
    end
    --字体枚举，通过setFont/getFont 与字体建立对应关系
    General.font1 = 1
    General.font2 = 2
    General.font3 = 3
    General.font4 = 4 
    General.font5 = 5
    General.font6 = 6
    if not isInit then
        GEngine.setConfig("language",language,true)
        GEngine.setConfig("lversion",GEngine.lanConfig.lversion or 1,true)
    end
end

function GEngine.reloadScriptConfig()
    GEngine.sureEffectVersion()
    local deviceInfo = json.decode(Native:getDeviceInfo())
    local deviceType = deviceInfo.platform or "win32"
    local cconfig = GMethod.loadConfig("configs/language_" .. deviceType .. ".json")
    local curLan = GEngine.getConfig("language")
    if not curLan or (GEngine.getConfig("lversion") or 0)<(cconfig.lversion or 1) then
        local country = (deviceInfo.country or "CN"):upper()
        local slanguage = (deviceInfo.language or "ZH_CN"):upper()
        if slanguage:len()>1 then
            if cconfig.lanfix2[slanguage] then
                curLan = cconfig.lanfix2[slanguage]
            else
                curLan = cconfig.lanfix2.default
            end
        else
            if cconfig.languages[country] then
                curLan = country
            elseif cconfig.lanfix[country] then
                curLan = cconfig.lanfix[country]
            else
                curLan = cconfig.lanfix.default
            end
        end
    end
    GEngine.lanConfig = cconfig
    GEngine.changeLanguage(curLan, true)
    cconfig = GMethod.loadConfig("configs/script.json")
    GEngine.scrConfig = cconfig
    if cconfig.views then
        for _, view in ipairs(cconfig.views) do
            GEngine.registerView(view[1], view[2], view[3])
        end
    end
end

--根据机器配置确定特效高低效果
function GEngine.sureEffectVersion()
    local deviceInfo = json.decode(Native:getDeviceInfo())
    local needMemory = 160*1024*1000
    local memory = deviceInfo.Memory or needMemory
    --1：全特效，2：不显示在佣兵和城墙建筑身上的BUFF特效，战斗伤害数字特效处理：限制最大显示数量，目前暂定20个。
    local effectVersion = 1
    if memory < needMemory then
        effectVersion = 2
    end
    if not GEngine.getConfig("effectVersion") then
        GEngine.effectVersion = effectVersion
        GEngine.setConfig("effectVersion",effectVersion,true)
    else
        GEngine.effectVersion = GEngine.getConfig("effectVersion")
    end
    
end

local function init()
    local cconfig = GMethod.loadConfig("configs/client.json")
    if cconfig then
        local logLevel = cconfig.logLevel
        if type(logLevel)=="string" then
            logLevel = log[logLevel]
        end
        log.setLogLevel(logLevel or log.CLOSE)
        if not GEngine.getConfig("defaultInited") then
            GEngine.setConfig("defaultInited",true,true)
            GEngine.setConfig("musicOn", cconfig.music or true, true)
            GEngine.setConfig("soundOn", cconfig.sound or true, true)
            GEngine.saveConfig()
        end
        music.init()
        Script.init()
        display.init(cconfig.designSize)
        HttpModule:getInstance():setTimeoutForConnect(15)
        HttpModule:getInstance():setTimeoutForRead(30)
        GEngine.rawConfig = cconfig
        GEngine.export("DEBUG", cconfig)
        --在开始前移除旧包
        local innerVersion = cconfig.innerScriptVersion or 1
        local fu = cc.FileUtils:getInstance()
        local rp = fu:getWritablePath()
        fu:createDirectory(rp .. "data")
        if (GEngine.getConfig("scriptVersion") or 0)<innerVersion then
            fu:removeFile(rp .. "data4.pkg")
            GEngine.setConfig("scriptVersion",innerVersion,true)
            log.d("Now use the inner script version:%d", innerVersion)
        end
        GEngine.start()
        Plugins:init()
    else
        log.e("Quit Game Exception:%s","The \"configs/client.json\" is not exist or not json format!")
        GEngine.quitGame()
    end
end

local lsynTime = 0
local function engineTrack(msg)
    if os.time()-lsynTime<=5 then
        return
    end
    lsynTime = os.time()
    log.e("----------------------------------------")
    log.e("LUA ERROR: " .. tostring(msg) .. "\n")
    log.e(debug.traceback())
    log.e("----------------------------------------")

    local alertTable = {title="Error", msg=debug.traceback(), buttons={"Ok"}}
    NativeAlert:createAlert(ButtonHandler(GMethod.doNothing), json.encode(alertTable)):show()
end
_G.__G__TRACKBACK__ = engineTrack

--锁住全局变量表；禁止无意义的使用全局变量表；暂时禁止全部的，之后要改成通过某种规则来设置
--lock状态下加载全局表会警告

local wrCheckMeta = {}
function wrCheckMeta.__index(table, key)
    log.e("set readCheck table with key:\"%s\"", key)
    log.e(debug.traceback())
    return nil
end

function wrCheckMeta.__newindex(table, key, value)
    if wrCheckMeta.lockWriteGlobal then
        log.e("set writeCheck table with key:\"%s\"", key)
        log.e(debug.traceback())
    end
    rawset(_G, key, value)
end

function GEngine.lockG(lock)
    wrCheckMeta.lockWriteGlobal = lock
end

function GEngine.export(k, v)
    rawset(_G, k, v)
end

local RdUtil = class()

function RdUtil:ctor(seed)
    self.a = 36001
    self.b = 23451
    self.m = 87241
    self.seed = math.floor(seed%self.m)
    
end

function RdUtil:nextSeed()
    self.seed = (self.seed * self.a + self.b)%self.m
end

function RdUtil:random2()
    self:nextSeed()
    return self.seed/(self.m-1)
end

function RdUtil:randomInt(max)
    self:nextSeed()
    return math.ceil((self.seed+1)*max/self.m)
end
function RdUtil:random(min,max)
    if not max and not min then
        return self:random2()
    elseif min and not max then
        return self:randomInt(min)
    end
    self:nextSeed()
    return math.ceil((self.seed+1)*(max-min)/self.m+min)
end

--过滤敏感词（如果onlyKnowHas为true，表示只想知道是否存在敏感词，不会返回过滤后的敏感词，
--比如用户注册的时候，我们程序是只想知道用户取的姓名是否包含敏感词的(这样也能提高效率，检测到有一个敏感词就直接返回)，
--而聊天模块是要返回过滤之后的内容的，那么onlyKnowHas可以不设，但这需要遍历所有可能）
local mgcMap = {}
local count = 0
for i,v in ipairs({}) do
    count = count+1
    mgcMap[v] = true
end

function filterSensitiveWords( content , onlyKnowHas)
    if content == nil or content == '' then
        return ''
    end
  
    --获取每一个字符
    local wordlist = {} 
    local q = 1
    for w in string.gmatch(content, ".[\128-\191]*") do   
        wordlist[q]= w
        q=q+1
    end

    --获取字符串中从起始位置到结束位置的字符
    local function findWord( wordTable, startpos,endpos )
        local result = ''
        for i=startpos,endpos do
            result = result..wordTable[i]
        end
        return result
    end

    local length = #(string.gsub(content, "[\128-\191]", ""))  --计算字符串的字符数（而不是字节数）
    local i,j = 1,1
    local replaceList={}
    local mgc = mgcMap
    local function check(  )
        local v = findWord(wordlist,i,j)
        local item = mgc[v]
        if item == true then
            if onlyKnowHas == true then
                return true
            end
            table.insert(replaceList,v)
            j = j+1
            i = j
        else
            j = j+1
        end
        local limit = (j-i) >= 15 and true or (j > length and true or false) 
        if limit == true then --因为一个敏感词最多15个字，不会太长，目的提高效率
            i = i +1
            j = i 
        end
        if i <= length then
            return check()
        end
    end
    if check() then
        return true
    end


    if onlyKnowHas == true then
       return false
    end

   --模式串中的特殊字符   ( ) . % + - * ? [ ^ $
    --  % 用作特殊字符的转义字符，比如%%匹配字符%     %[匹配字符[
    local specialChar = {['(']=true,[')']=true,['.']=true,['%']=true,['+']=true,['-']=true,['*']=true,['?']=true,['[']=true,['^']=true,['$']=true}
    --检测是否有特殊字符
    local function checkSpecialChar( msg )
        local tArray = string.gmatch(msg, ".[\128-\191]*")
        local contentArray = {}
        for w in tArray do  
           table.insert(contentArray,w)
        end
        local ck = {}
        for i=1,#contentArray do
            local v = contentArray[i]
            if specialChar[v] == true then
                table.insert(ck,'%')
            end
            table.insert(ck,v)
        end
        local result=''
        for i,v in ipairs(ck) do
            result = result..v
        end
        return result
    end
    
    for i,v in ipairs(replaceList) do
        v = checkSpecialChar(v)
        content = string.gsub( content , v , '*' )
    end
    return content
end

GEngine.export("RdUtil", RdUtil)

setmetatable(_G, wrCheckMeta)
GEngine.lockG(true)
xpcall(init, engineTrack)
