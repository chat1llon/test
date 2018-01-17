local const = GMethod.loadScript("game.GameLogic.Const")
local SData = GMethod.loadScript("data.StaticData")

local ResSetting = {}
ResSetting[const.ResGold] = {1, const.ProGold, const.ProGoldMax}
ResSetting[const.ResBuilder] = {1, const.ProBuilder, const.ProBuilderMax}
ResSetting[const.ResCrystal] = {1, const.ProCrystal}
ResSetting[const.ResSpecial] = {1, const.ProSpecial}
ResSetting[const.ResExp] = {0, const.InfoExp}
ResSetting[const.ResScore] = {0, const.InfoScore}
ResSetting[const.ResZhanhun] = {1, const.ProZhanhun}
ResSetting[const.ResMagic] = {1, const.ProMagic}
ResSetting[const.ResMedicine] = {1, const.ProMedicine}
ResSetting[const.ResBeercup] = {1, const.ProBeercup}
ResSetting[const.ResEventMoney] = {1, const.ProEventMoney}
ResSetting[const.ResMicCrystal] = {1, const.ProMicCrystal}
ResSetting[const.ResTrials] = {1, const.ProTrials}
ResSetting[const.ResPBead] = {1, const.ProPBead}
ResSetting[const.ResGXun] = {1, const.ProGXun}
ResSetting[const.ResGaStone] = {1, const.ProGaStone}

--context用来做所有用户有关的数值逻辑
local UContext = class()

function UContext:ctor(uid)
    self.uid = uid
end

function UContext:loadContext(data)
    self.cmds = {}
    self.info = data.info or {}
    for i=1,20 do
        if not self.info[i] then
            self.info[i] = 0
        end
    end
    local pd = {}
    data.properties = data.properties or {}
    for _, pair in ipairs(data.properties) do
        pd[pair[1]] = pair[2]
    end
    self.ps = pd
end

--时间跨日，刷新数据
function UContext:refreshContext(data)

end

function UContext:destroy()
    self.uid = nil
    self.info = nil
    self.properties = nil
end

function UContext:getInfoItem(k)
    return self.info[k+1] or 0
end

function UContext:setInfoItem(k, v)
    self.info[k+1] = v
    return v
end

function UContext:changeInfoItem(k, v)
    self.info[k+1] = self.info[k+1]+v
    return self.info[k+1]
end

function UContext:nextRandom(mod)
    local seed = self:getInfoItem(const.InfoRandom)
    seed = (seed*const.RdA+const.RdB)%const.RdM
    self:setInfoItem(const.InfoRandom, seed)
    return seed%mod
end

function UContext:getProperty(k)
    return self.ps[k] or 0
end

function UContext:setProperty(k, v)
    self.ps[k] = v
    return v
end

function UContext:changeProperty(k, v)
    local r = (self.ps[k] or 0)+v
    self.ps[k] = r
    return r
end

function UContext:getRes(resId)
    local rs = ResSetting[resId]
    if rs[1]==0 then
        return self:getInfoItem(rs[2])
    else
        return self:getProperty(rs[2])
    end
end

function UContext:setRes(resId, value)
    local rs = ResSetting[resId]
    if rs[1]==0 then
        return self:setInfoItem(rs[2], value)
    else
        local ret = self:setProperty(rs[2], value)
        if rs[3] and self.resData then
            local r2 = self.resData:getNum(resId)
            self.resData:changeNum(resId, ret-r2)
        end
        return ret
    end
end

function UContext:changeRes(resId, value)
    --消耗宝石 寻宝数值增加
    if resId == const.ResCrystal and value<0 then
        local tresure = self.activeData.limitActive[101]
        if tresure then
            tresure[5] = tresure[5]-value
        end
    end

    local rs = ResSetting[resId]
    if resId == const.ResExp then
        self:addExp(value)
    elseif rs[1]==0 then
        return self:changeInfoItem(rs[2], value)
    else
        local ret = self:changeProperty(rs[2], value)
        if rs[3] and self.resData then
            local r2 = self.resData:getNum(resId)
            self.resData:changeNum(resId, ret-r2)
        end
        return ret
    end
end

function UContext:getResMax(resId)
    local rs = ResSetting[resId]
    if rs[3] then
        return self:getProperty(rs[3])
    elseif resId==const.ResExp then
        local lv = self:getInfoItem(const.InfoLevel)
        local exp = SData.getData("ulevels", lv)
        if exp then
            return exp
        end
    end
    return 0
end

function UContext:changeResMax(resId, value)
    local rs = ResSetting[resId]
    if rs[3] then
        return self:changeProperty(rs[3], value)
    end
end

function UContext:changeResWithMax(resId, value)
    if resId==const.ResGold then
        local max = self:getResMax(resId)
        local res = self:getRes(resId)
        if res+value>max then
            self:setRes(resId, max)
            return max-res
        else
            self:setRes(resId, res+value)
            return value
        end
    else
        return self:changeRes(resId, value)
    end
end

function UContext:getItemPid(itemType, itemId)
    local pid = SData.getData("property", itemType, itemId)
    if not pid then
        if itemType==const.ItemFragment then
            pid = itemId-4000+200
        elseif itemType==const.ItemEquipFrag then
            pid = itemId-2000+300
        else
            pid = itemId
        end
    else
        pid = pid.pid
    end
    return pid
end

function UContext:getItem(itemType, itemId)
    return self:getProperty(self:getItemPid(itemType, itemId))
end

function UContext:setItem(itemType, itemId, value)
    return self:setProperty(self:getItemPid(itemType, itemId), value)
end

function UContext:changeItem(itemType, itemId, value)
    return self:changeProperty(self:getItemPid(itemType, itemId), value)
end

local canMerge = {
    [const.CmdUpgradeUlv] = 0,
    [const.CmdChangeLayout] = 0,
    [const.CmdBuyHeroPlace] = 1,
    [const.CmdHeroMic] = 1,
    [const.CmdEquipUpgrade] = 1,
    [const.CmdUseOrSellItem] = 1
}
function UContext:addCmd(cmd)
    local cmds = self.cmds
    local cl = #cmds
    local ms = canMerge[cmd[1]]
    if ms then
        if cl>0 then
            local lcmd = cmds[cl]
            if lcmd[1]==cmd[1] then
                if ms==0 then
                    cmds[cl] = cmd
                elseif ms==1 then
                    local idx = #lcmd
                    for j=2, idx-1 do
                        if lcmd[j]~=cmd[j] then
                            cmds[cl+1] = cmd
                            return
                        end
                    end
                    lcmd[idx] = lcmd[idx]+cmd[idx]
                end
                return
            end
        end
    end
    cmds[cl+1]  = cmd
end

function UContext:dumpCmds()
    self.buildData:dumpLayoutChanges()
    self.resData:dumpExtChanges()
    local rcmds = self.cmds
    if #rcmds>0 then
        self.cmds = {}
        return rcmds
    end
    return nil
end

function UContext:addExp(exp)
    local exp = self:changeInfoItem(const.InfoExp, exp)
    local nextExp = self:getResMax(const.ResExp)
    local upgraded = false
    while nextExp>0 and exp>=nextExp do
        upgraded = true
        exp = self:changeInfoItem(const.InfoExp, -nextExp)
        self:changeInfoItem(const.InfoLevel, 1)
        nextExp = self:getResMax(const.ResExp)
    end
    if upgraded then
        self:addCmd({const.CmdUpgradeUlv})
    end
end

function UContext:buyRes(ctype, cvalue, cost)
    self:changeRes(const.ResCrystal, -cost)
    self:changeResWithMax(ctype, cvalue)
    self:addCmd({const.CmdBuyRes, ctype, cvalue})
end

return UContext
