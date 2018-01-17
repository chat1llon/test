local Context = GMethod.loadScript("game.GameLogic.Context")
local const = GMethod.loadScript("game.GameLogic.Const")
local SData = GMethod.loadScript("data.StaticData")
local GameLogic = {}

function GameLogic.newContext(uid)
    local context = Context.new(uid)
    return context
end

function GameLogic.newBattleData(scene)
    local bd = BattleData.new(scene)
    return bd
end

local _userContext = nil
local _currentContext = nil
function GameLogic.setUserContext(context)
    if _userContext then
        _userContext:destroy()
    end
    _userContext = context
end
function GameLogic.getUserContext()
    return _userContext
end
function GameLogic.setCurrentContext(context)
    _currentContext = context
end
function GameLogic.getCurrentContext()
    return _currentContext
end

function GameLogic.getGameName()
    return "COZ II TEST"
end

function GameLogic.feedback(otherSetting)
    local title = StringManager.getString("feedbackTitle")
    local feedbackMail = "21024851@qq.com"
    if otherSetting then
        if otherSetting.title then
            title = otherSetting.title
        end
        if otherSetting.mail then
            feedbackMail = otherSetting.mail
        end
    end
    display.closeDialog()
    local t = os.time() .. " " .. os.date("%Y-%m-%d %H:%M:%S")
    local language = General.language
    local gengine = GEngine
    local gameName = GameLogic.getGameName()
    local version = "Inner Test"
    local context = GameLogic.getUserContext()
    --default:getStringForKey("localVersion") .. "(" .. default:getIntegerForKey("siversion") .. ")"
    --version = version .. "(" .. StringManager.getString("labelServerName" .. network.curServerId) .. ")"
    if feedbackMail==nil or feedbackMail=="" then
        feedbackMail = "feedback@caesarsgame.com"
    end
    if version=="" then version="1" end
    local content = "\n\n------" .. StringManager.getString("feedbackNotice") .. "------\n" .. StringManager.getString("feedbackTime") .. t
    content = content .. "\n" .. StringManager.getString("feedbackName") .. gameName
    content = content .. "\n" .. StringManager.getString("feedbackVersion") .. version
    content = content .. "\n" .. StringManager.getString("feedbackUId") .. (8000000+context:getValue("id"))
    local uname = context:getValue("name")
    if uname and uname~="" then
        content = content .. "\n" .. StringManager.getString("feedbackUName") .. uname
    end
    local upurchase = context:getValue("purchase")
    if upurchase and upurchase>0 then
        content = content .. "\n" .. StringManager.getString("feedbackUCrystal") .. upurchase
    end
    content = content .. "\n" .. StringManager.getString("feedbackLanguage") .. GEngine.lanConfig.languages[language][4]
    content = content .. "\n" .. StringManager.getString("feedbackModel") .. (gengine.getConfig("deviceModel") or "windows asus")
    content = content .. "\n" .. StringManager.getString("feedbackSys") .. (gengine.getConfig("sysVersion") or "win8")
    content = content .. "\n-------------------"
    Native:sendEmail(feedbackMail, title .. gameName, content)
end

function GameLogic.openUrl(url)
    if not url then
        url = "http://www.baidu.com"
    end
    Native:openURL(url)
end

--这里用于处理服务器时间和当前时间

local _offTime = 0
function GameLogic.setSTime(stime)
    _offTime = stime-socket.gettime()
end

function GameLogic.getSFloatTime()
    return socket.gettime()+_offTime
end

function GameLogic.getSTime()
    return math.floor(GameLogic.getSFloatTime())
end

local _todayTime = const.InitTime
function GameLogic.getToday()
    while _todayTime+86400<=GameLogic.getSTime() do
        _todayTime = _todayTime+86400
    end
    return _todayTime
end

function GameLogic.computeCostByRes(ctype, value)
    if ctype==const.ResGold then
        if value>10000000 then
            return math.floor(value/10000000*3000)
        elseif value>1000000 then
            return math.floor(600+(3000-600)/9000000*(value-1000000))
        elseif value>100000 then
            return math.floor(125+(600-125)/900000*(value-100000))
        elseif value>10000 then
            return math.floor(25+(125-25)/90000*(value-10000))
        elseif value>1000 then
            return math.floor(5+(25-5)/9000*(value-1000))
        elseif value>100 then
            return math.floor(1+(5-1)/900*(value-100))
        else
            return 1
        end
    else
        return 10
    end
end

function GameLogic.computeCostByTime(timeInSecond)
    if timeInSecond<60 then
        return 1
    elseif timeInSecond<3600 then
        return 1+math.floor((20-1)*(timeInSecond-60)/(3600-60))
    elseif timeInSecond<86400 then
        return 20+math.floor((260-20)*(timeInSecond-3600)/(86400-3600))
    else
        return 260+math.floor((1000-260)*(timeInSecond-86400)/(604800-86400))
    end
end

function GameLogic.buyRes(ctype, cvalue)
    local cost = GameLogic.computeCostByRes(ctype, cvalue)
    local cctype = const.ResCrystal
    local context = GameLogic.getUserContext()
    if context:getRes(cctype)<cost then
        display.showDialog(AlertDialog.new({ctype=cctype, cvalue=cost}))
        return false
    else
        context:buyRes(ctype, cvalue, cost)
        return true
    end
end

function GameLogic.buyResAndCallback(ctype, cvalue, callback)
    if GameLogic.buyRes(ctype, cvalue) then
        callback()
    end
end

local _dumpLock = false
function GameLogic.onSendCmdsOver(suc, data)
    _dumpLock = false
end

function GameLogic.getDumpCmds()
    local context = _userContext
    if not context then
        return
    end
    local cmds = context:dumpCmds()
    return cmds
end

function GameLogic.dumpCmds(force)
    if not _dumpLock or force then
        local cmds = GameLogic.getDumpCmds()
        if cmds then
            _dumpLock = true
            GameNetwork.request("cmds", {cmds=cmds}, GameLogic.onSendCmdsOver)
        end
    end
end

function GameLogic.sortExpHero(hero1, hero2)
    local isExp1 = (hero1.hid%1000==0)
    local isExp2 = (hero2.hid%1000==0)
    if isExp1~=isExp2 then
        return isExp1
    elseif hero1.info.color~=hero2.info.color then
        return hero1.info.color>hero2.info.color
    elseif hero1.level~=hero2.level then
        return hero1.level>hero2.level
    elseif hero1.exp~=hero2.exp then
        return hero1.exp>hero2.exp
    else
        return hero1.hid<hero2.hid
    end
end

function GameLogic.sortExpHero2(hero1, hero2)
    local isExp1 = (hero1.hid%1000==0)
    local isExp2 = (hero2.hid%1000==0)
    if isExp1~=isExp2 then
        return isExp2
    elseif hero1.info.color~=hero2.info.color then
        return hero1.info.color>hero2.info.color
    elseif hero1.level~=hero2.level then
        return hero1.level>hero2.level
    elseif hero1.exp~=hero2.exp then
        return hero1.exp>hero2.exp
    else
        return hero1.hid<hero2.hid
    end
end

function GameLogic.addRewards(rewards)
    if not rewards or #rewards==0 then
        return
    end
    log.d(json.encode(rewards))
    local context = GameLogic.getUserContext()
    local isOverflow = false
    for _, reward in ipairs(rewards) do
        if reward[1]==const.ItemRes then
            context:changeResWithMax(reward[2], reward[3])
        elseif reward[1]==const.ItemHero then
            if reward[3]>0 then
                context.heroData:addNewHero(reward[3], reward[2])
            else --溢出
                isOverflow = true
            end
        elseif reward[1]==const.ItemEquip then
            if reward[3]>0 then
                context.equipData:addNewEquip(reward[3], reward[2])
            else   --溢出
                isOverflow = true
            end
        else
            context:changeItem(reward[1], reward[2], reward[3])
        end
    end
    if isOverflow then
        GameLogic.getUserContext().logData:getEmailDatas()
    end
    context.heroData:checkHeroNum()
end

function GameLogic.getTime()
    return GameLogic.getSTime()
end

function GameLogic.getAdjustTime()
    return 1451577600
end

function GameLogic.getRtime()
    return (GameLogic.getSTime()-GameLogic.getAdjustTime()-3600*8)%86400
end

function GameLogic.getTimeFormat(value)
    return StringManager.getTimeString(value)
end

--整型时间与字符型比较
function GameLogic.compareTime(intTime,strTime)
    local time=string.split(strTime," ")
    local time1=string.split(time[1],"-")
    local time2=string.split(time[2],":")
    local year=tonumber(time1[1])
    local month=tonumber(time1[2])
    local day=tonumber(time1[3])
    local hour=tonumber(time2[1])
    local min=tonumber(time2[2])
    local sec=tonumber(time2[3])
    local tab=os.date("*t",intTime)
    if tab.year>year then
        return 1
    elseif tab.year<year then
        return -1
    end
    if tab.month>month then
        return 1
    elseif tab.month<month then
        return -1
    end
    if tab.day>day then
        return 1
    elseif tab.day<day then
        return -1
    end
    if tab.hour>hour then
        return 1
    elseif tab.hour<hour then
        return -1
    end
    if tab.min>min then
        return 1
    elseif tab.min<min then
        return -1
    end
    if tab.sec>sec then
        return 1
    elseif tab.sec<sec then
        return -1
    end
    return 0
end

--排序
function GameLogic.mySort(tb,key,down)
    for i=1,#tb do
        for j=1,#tb-i do
            local b
            if key then
                b = down and tb[j][key]<tb[j+1][key] or not down and tb[j][key]>tb[j+1][key]
            else
                b = down and tb[j]<tb[j+1] or not down and tb[j]>tb[j+1]
            end
            if b then
                tb[j],tb[j+1] = tb[j+1],tb[j]
            end
        end
    end
    return tb
end
--最大
function GameLogic.getMax(tb,key)
    local temp = -10000000
    local rt
    for k,v in pairs(tb) do
        if v[key]>temp then
            rt = v
            temp = v[key]
        end
    end
    return rt
end
--最小
function GameLogic.getMin(tb,key)
    local temp = 10000000
    local rt
    for k,v in pairs(tb) do
        if v[key]<temp then
            rt = v
            temp = v[key]
        end
    end
    return rt
end

function GameLogic.getItemName(resMode,resID)
    local name
    if not resID then           --是资源
        name = Localize("dataResName" .. resMode)
    elseif resMode==const.ItemRes then
        --是资源
        name = Localize("dataResName" .. resID)
    elseif resMode==const.ItemHero then
        name = Localize("dataHeroName" .. resID)
    elseif resMode==const.ItemEquip then
        name = Localize("dataEquipName" .. resID)
    elseif resMode==const.ItemFragment then
        name = Localizef("dataFragFormat",{name=GameLogic.getItemName(const.ItemHero, resID)})
    elseif resMode==const.ItemEquipFrag then
        name = Localizef("dataFragFormat",{name=GameLogic.getItemName(const.ItemEquip, resID)})
    elseif resMode == const.ItemOther then
        if resID == const.ProMonthCard then
            return Localize("storeItemContract2")
        end
    else
        name = Localize("dataItemName" .. resMode .. "_" .. resID)
    end
    return name
end

function GameLogic.getItemDesc(resMode,resID)
    local name
    if not resID then           --是资源
        name = Localize("dataResName" .. resMode)
    elseif resMode==const.ItemRes then
        --是资源
        name = Localize("dataResName" .. resID)
    elseif resMode==const.ItemHero then
        name = Localize("dataHeroName" .. resID)
    elseif resMode==const.ItemEquip then
        name = Localize("dataEquipName" .. resID)
    elseif resMode==const.ItemFragment then
        name = Localizef("dataFragFormat",{name=GameLogic.getItemName(const.ItemHero, resID)})
    elseif resMode==const.ItemEquipFrag then
        name = Localizef("dataFragFormat",{name=GameLogic.getItemName(const.ItemEquip, resID)})
    elseif resMode == const.ItemOther then
        name = ""
    else
        name = Localize("dataItemInfo" .. resMode .. "_" .. resID)
    end
    return name
end

function GameLogic.getStringLen(name)
    local charNum,c = 0,0
    --name = string.gsub(name, "^%s*(.-)%s*$", "%1")
    name = string.gsub(name, "^%s$", "%1")
    local i, l = 1, name:len()
    local cn,wn = 0,0
    while i<=l do
        c = name:byte(i)
        if c<0x80 then
            i = i+1
            wn = wn+1
        elseif c>=192 and c<=223 then
            i = i+2
            wn = wn+1
        else
            wn = wn+2
            if c>=224 and c<=239 then
                i = i+3
            elseif c>=240 and c<=247 then
                i = i+4
             
            elseif c>=248 and c<=251 then
                i = i+5
            elseif c>=252 and c<=253 then
                i = i+6
            else
                break
            end
        end
        cn = cn+1
    end

    return wn,cn,l
end

function GameLogic.getActiveDes(id,anum)
    return Localizef("dataActiveDes" .. id,{a = anum})
end

function GameLogic.getactreward(atype,aid,callback)
    if not GameNetwork.lockRequest() then
        return
    end
    _G["GameNetwork"].request("getactreward",{getactreward = {atype,aid}},function(isSuc, data)
        GameNetwork.unlockRequest()
        if isSuc then
            --print_r(data)
            if atype == 103 then
                local limitActive = GameLogic.getUserContext().activeData.limitActive
                limitActive[103][6] = 1
            else
                local activeData = GameLogic.getUserContext().activeData
                activeData:getReward(atype)
            end
            GameLogic.addRewards(data)
            GameLogic.showGet(data)
            callback()
        end
    end)
end

function GameLogic.dnumber(code,num)
    local tab = {}
    for i=1,num do
        local n = code%10
        code = (code-n)/10
        tab[i] = math.floor(n)
    end
    return tab
end
function GameLogic.enumber(tab)
    local num = 0
    for i,v in ipairs(tab) do
        num = num+v*10^(i-1)
    end
    return math.floor(num)
end

function GameLogic.checkHero(hero)      --出战 助战 锁定
    local louts = hero.layouts
    local isFight = false
    for lid, l in pairs(louts) do
        if l.type>0 then
            isFight = true
            break
        end
    end
    if hero.lock==1 or isFight then
        return false
    else
        return true
    end
end

function GameLogic.checkHeroDv(hero)       --是否养成过
    if hero.starUp>0 or hero.awakeUp>0 or hero.mSkillLevel>1 or hero.soldierLevel>1
        or hero.soldierSkillLevel>0 then
        return false
    else
        return true
    end
end

function GameLogic.showGet(rewards,delayTime,showResDl,notShowNotice)
    local scene = GMethod.loadScript("game.View.Scene")
    local rewards = clone(rewards)
    local temp = {}
    local temp2 = {}
    local isUpOut = false
    local idx = 1
    for i=1,#rewards do
        local v = rewards[idx]
        if v[1] == const.ItemHero then
            -- if v[3] == 0 then
            --     table.remove(rewards,idx)
            --     isUpOut = true
            -- else
                if not temp[v[2]] then
                    temp[v[2]] = {v[1],v[2],1}
                else
                    temp[v[2]][3] = temp[v[2]][3]+1
                end
                table.remove(rewards,idx)
            -- end
        elseif v[1] == const.ItemEquip then
                if not temp2[v[2]] then
                    temp2[v[2]] = {v[1],v[2],1}
                else
                    temp2[v[2]][3] = temp2[v[2]][3]+1
                end
                table.remove(rewards,idx)
        elseif v[1] == const.ItemRes and v[2] == const.ResExp then
            table.remove(rewards,idx)
        else
            idx = idx+1
        end
    end
    for k,v in pairs(temp) do
        table.insert(rewards,v)
    end
    for k,v in pairs(temp2) do
        table.insert(rewards,v)
    end
    scene.view:runAction(ui.action.sequence({{"delay",delayTime or 0},{"call",function()
        if not notShowNotice then
            for i, reward in ipairs(rewards) do
                scene.view:runAction(ui.action.sequence({{"delay",0.1*i},{"call",function()
                    local str = Localize("labelGet")
                    str = str .. GameLogic.getItemName(reward[1],reward[2])
                    str = str .. "x" .. reward[3]
                    display.pushNotice(str)
                end}}))
            end
        end
        if showResDl then
            if #rewards>1 then
                display.showDialog(RewardListDialog.new({rewards=rewards}))
            else
                display.showDialog(RewardDialog.new({rewards=rewards}),false,true)
            end
        end
    end}}))
end

function GameLogic.addVipExp(topupNum)
    local vippower = SData.getData("vippower")
    local context = GameLogic.getUserContext()
    local topupNum = context:getInfoItem(const.InfoVIPexp)+topupNum
    local vip = 0
    for i,v in ipairs(vippower) do
        if topupNum>=v.crynum then
            vip = i
        end
    end
    context:setInfoItem(const.InfoVIPexp,topupNum)
    context:setInfoItem(const.InfoVIPlv,vip)
end

function GameLogic.getBitSgin(sgin,idx)
    return bit.band(sgin, bit.lshift(1, idx))>0
end

function GameLogic.setBitSgin(sgin,idx)
    local num = bit.bor(sgin, bit.lshift(1, idx))
    return num
end

function GameLogic.getGc()
    return GEngine.rawConfig.testGc
end

function GameLogic.getFb()
    return GEngine.rawConfig.testFb
end

function GameLogic.setServerColor(sp,state)
    if state == 0 then
        ui.setColor(sp,255,64,44)
    elseif state == 1 then
        ui.setColor(sp,59,255,44)
    elseif state == 2 then
        ui.setColor(sp,196,196,196)
    end
end

function GameLogic.getRandom(min,max)
    local scene = GMethod.loadScript("game.View.Scene")
    local rd = scene and scene.replay and scene.replay.rd
    if rd then
        local num = rd:random(min,max)
        scene.replay:addDebugText("random" .. num)
        --print("$$$$$",num,tostring(debug.traceback()))
        return num
    else
        if max then
            return math.random(min,max)
        elseif min then
            return math.random(min)
        else
            return math.random()
        end
    end
end

function GameLogic.getBattleHeroId()
    local scene = GMethod.loadScript("game.View.Scene")
    local herosId = {}
    local haveInsert = {}
    --英雄台 和 联盟建筑上的英雄或者神兽
    for k,build in pairs(scene.builds) do
        local rhero =build.vstate and build.vstate.rhero
        if rhero then
            local id = rhero.sid
            if id>8000 and id<9000 then
                id = math.floor(id/10)*10+3
            end
            haveInsert[id] = true
        end
    end

    --hitems
    for i,group in ipairs(scene.battleData.groups or {}) do
        for j,hitem in pairs(group.hitems or {}) do
            if hitem.hid then
                haveInsert[hitem.hid] = true
            end
        end
    end

    if scene.battleType == const.BattleTypePvj then
        for i,hitems in ipairs(scene.battleData.readyHeros) do
            for j,hitem in ipairs(hitems) do
                local id = hitem.hero.hid
                if id>8000 and id<9000 then
                    id = math.floor(id/10)*10+3
                end
                haveInsert[id] = true
            end
        end
    elseif scene.battleType == const.BattleTypePvt then
        local groups = {scene.battleData.heros,scene.battleData.dheros}
        for i,group in ipairs(groups) do
            for j=1,9 do
                local hitem = group[j]
                if hitem and hitem.hero then
                    haveInsert[hitem.hero.hid] = true
                end
            end
        end
    end

    for k,v in pairs(haveInsert) do
        table.insert(herosId,k)
    end
    table.insert(herosId,4024)
    return herosId
end

function GameLogic.checkLayout(lid)
    for i=1,5 do
        local hero = GameLogic.getUserContext().heroData:getHeroByLayout(lid,i,1)
        if hero then
            return true
        end
    end
end

function GameLogic.getRebirthCost(lid)
    local cost = 0
    local stime = GameLogic.getSTime()
    local allDie = true
    local heroTab = {}
    for i=1,5 do
        local hero = GameLogic.getUserContext().heroData:getHeroByLayout(lid,i,1)
        if hero then
            if not hero:isAlive(stime) then
                local c = GameLogic.computeCostByTime(hero.recoverTime-stime)
                cost = cost+c
                table.insert(heroTab,hero)
            else
                allDie = false
            end
        end
    end
    return cost,allDie,heroTab
end

function GameLogic._realGo(allDie, callback)
    if allDie then
        display.pushNotice(Localize("stringAllDieCantGoWar"))
    else
        callback()
    end 
end

function GameLogic._checkCanGoBattle(lid,aliveCheck,callback)
    if GameLogic.checkLayout(lid) then
        if aliveCheck then
            local cost,allDie,heroTab= GameLogic.getRebirthCost(lid)
            local ncall = Handler(GameLogic._realGo, allDie, callback)
            if cost>0 then
                local otherSettings = {ctype = const.ResCrystal, cvalue = cost, noCallback = ncall, callback = function()
                    local stime = GameLogic.getSTime()
                    for i,hero in ipairs(heroTab) do
                        if hero and hero.recoverTime>stime then
                            local cost = GameLogic.computeCostByTime(hero.recoverTime-stime)
                            hero.recoverTime = 0
                            GameLogic.getUserContext().heroData:healHero(hero, stime, cost)
                        end
                    end
                    callback()
                end}
                local alert = AlertDialog.new(5,Localize("alertTitleNormal"),Localize("stringIsRebirthAllHero"),otherSettings)
                display.showDialog(alert)
            else
                ncall()
            end
        else
            callback()
        end
    else
        display.pushNotice(Localize("stringNoHeroCantWar"))
    end
end

function GameLogic.checkCanGoBattle(battleType,callback)
    local sign = GameLogic.getUserContext():getProperty(const.ProUseLayout)
    sign = GameLogic.dnumber(sign,3)
    local lid = const.LayoutPvp
    local aliveCheck = false
    if battleType == const.BattleTypePvp or battleType == const.BattleTypePve or battleType == const.BattleTypeUPvp then
        if sign[1]>0 then
            lid = const.LayoutPve
        end
        if battleType ~= const.BattleTypeUPvp then
            aliveCheck = true
        end
    elseif battleType == const.BattleTypePvc then
        if sign[2]>0 then
            lid = const.LayoutPvc
        end
    elseif battleType == const.BattleTypeUPve then
        if sign[3]>0 then
            lid = const.LayoutUPve
        end
    end
    GameLogic._checkCanGoBattle(lid,aliveCheck,callback)
end

function GameLogic.lockInGuide()
    display.pushNotice(Localize("stringPleaseGuideFirst"))
end

function GameLogic.sendChat(params)
    local scene = GMethod.loadScript("game.View.Scene")
    local chatRoom = scene.menu.chatRoom
    local msg = {}
    local ucontext = GameLogic.getUserContext()
    if params.mtype == 4 then
        if params.mode then
            if params.mode == 3 then
                local ug = {lv=ucontext:getInfoItem(const.InfoLevel), job=ucontext.union.job, mode=3}
                msg = {mtype=4, uid=ucontext.uid, cid=ucontext.union.id, name=ucontext:getInfoItem(const.InfoName)
                ,ug=json.encode(ug), text=Localize("labelUnionChat3")}
            else
                local ug = {lv=params.lv, job=params.job, mode=params.mode}
                msg = {mtype=params.mtype, uid=params.uid, cid=params.cid, name=params.name, ug=json.encode(ug), 
                text = Localizef("labelUnionChat" .. params.mode, {a=ucontext:getInfoItem(const.InfoName)})}
            end
        end
    end
    chatRoom:send(msg)
end

function GameLogic.checkVipSheild()
    local remainCD = GameLogic.getUserContext().enterData.ustate[3]-GameLogic.getSTime()
    local lock = GameLogic.getUserContext():getVipPermission("propect")[1]
    return (remainCD<0 and lock == 0) and 1 or 0
end

function GameLogic.transEquipData(eq)
    local ret = {}
    if eq then
        for _, edata in ipairs(eq) do
            ret[edata[1]] = {edata[2],edata[10],edata[3],0,edata[4],edata[5],edata[6],edata[7],edata[8],edata[9]}
        end
    end
    return ret
end

function GameLogic.dtransEquipData(eq)
    local ret = {}
    if eq then
        for k,v in pairs(eq) do
            local ed = {}
            local a
            ed[1],ed[2],ed[10],ed[3],a,ed[4],ed[5],ed[6],ed[7],ed[8],ed[9]=
            k,v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
            table.insert(ret,ed)
        end
    end
    return ret
end

function GameLogic.saveReplay(name,data)
    local context = GameLogic.getUserContext()
    local uid = context.uid
    local sid = context.sid
    local key = sid .. "_" .. uid .."allRp"
    local allRp = GEngine.getConfig(key) or "[]"
    allRp = json.decode(allRp)
    if #allRp>50 then
        table.remove(allRp,1)
        os.remove(name)
    end
    table.insert(allRp,name)
    local file = io.open(name,"w")
    file:write(data)
    file:close()
end

function GameLogic.getReplay(name)
    local file = io.open(name)
    if not file then
        print("$$$no file")
        return false
    end
    local data = file:read("*a")
    file:close()
    return data
end

function GameLogic.setSchedulerScale(sc)
    cc.Director:getInstance():getScheduler():setTimeScale(sc)
end

function GameLogic.checkWrong(name)
    local str,code = string.trim(name)
    if code == 1 then
        return true
    end
    return filterSensitiveWords(name,true)
end

local signLimit = {
    {33,47},
}
function GameLogic.checkSign(name)
    --获取每一个字符
    local wordlist = {} 
    for w in string.gmatch(name, ".[\128-\191]*") do   
        local code = string.byte(w)
        for i,v in ipairs(signLimit) do
            if v[1]<=code and code<=v[2] then
                return true
            end
        end
    end
end

function GameLogic.checkName(name,ntype)
    local wn,cn,l = GameLogic.getStringLen(name)
    local limit
    local context = GameLogic.getUserContext()
    if ntype == const.InfoName then
        limit = 10
        local curName = context:getInfoItem(const.InfoName)
        if name==curName then
            return -3
        end
    else
        limit = 14
    end
    if wn>limit then
        return -1
    end
    if GameLogic.checkWrong(name) then
        return -2
    end
    if GameLogic.checkSign(name) then
        return - 2
    end
    return 1
end

function GameLogic.unionBattle()
    if not GameNetwork.lockRequest() then
        return
    end
    _G["GameNetwork"].request("getpvlinfo",{},function(isSuc,data)
        GameNetwork.unlockRequest()
        if isSuc then
            if data.state >1 then
                UnionBattleLineupInterface.new(data)
            else
                UnionBattleOpenDialog.new(data)
            end       
        end
    end)
end

function GameLogic.fnum(num,n)
    num = tonumber(string.format("%." .. n .. "f",num))
    return num
end

GEngine.export("const",const)
GEngine.export("GameLogic",GameLogic)
GEngine.export("LG",GameLogic)

return GameLogic






