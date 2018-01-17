
--sdk一些功能的包装

Plugins = {}

local staticShareUrl = "http://ec2-23-21-135-42.compute-1.amazonaws.com/share.html"
local staticImgPrefix = "http://d2pkf9xf7unp5y.cloudfront.net/"
local sharePosImgs = {pve="pvp.png", pvp="pvp.png",arena="arena2.png",lbattle="lwar.png",invite="invite.png",pvh="pvh.png"
    
}

function Plugins:init()
	local configs = GMethod.loadConfig("configs/plugins.json")
    local pluginSlot = GEngine.engine:getPluginSlot()
    Plugins.slot=pluginSlot
    local splugin
    if configs then
        for _, plugin in ipairs(configs) do
            splugin = pluginSlot:getPlugin(plugin.name)
            if splugin then
                Plugins[plugin.ptype] = splugin
                if plugin.config then
                    splugin:changeConfigs(json.encode(plugin.config))
                end
            end
        end
    else
        print("not plugins.json")
    end
    local pm=GEngine.getPlatform()
    if pm==GEngine.platforms[5] or pm==GEngine.platforms[6] then
        Plugins.gamecenter = GameEngine:getInstance():getPluginSlot():getPlugin("PluginGamecenter")
    elseif pm==GEngine.platforms[4] then
        Plugins.gamecenter = GameEngine:getInstance():getPluginSlot():getPlugin("PluginGooglePlus")
        if Plugins.gamecenter then
            Plugins.gamecenter:changeConfigs(json.encode({SenderId="400842627705"}))
        end
    end
end
--登录
function Plugins:loginWithSdk(loginType,params)
	local function initAccount(code, jsonStr)
        if code==0 and params.callback then
            local ps=json.decode(jsonStr)
            params.callback(ps.id)
        end
    end
	if loginType==1 then--设备登录
        local id=Plugins:getDeviceId()
        if GEngine.getPlatform()==GEngine.platforms[1] then
            id=GEngine.getDevice()
        end
        if params.callback then
            params.callback(id)
        end
    elseif loginType==2 then--gamecenter
		if Plugins.gamecenter then
            Plugins.gamecenter:sendCommand(Plugins.slot:getPluginRequestCode(Script.createCallbackHandler(initAccount)), 4, json.encode({params=true}))
        end
	elseif loginType==3 then--facebook
		if Plugins.social then
            Plugins.social:sendCommand(Plugins.slot:getPluginRequestCode(Script.createCallbackHandler(initAccount)), 4, json.encode({rtype=1}))
        end
	end
end

--登出
function Plugins:logoutWithSdk(loginType,params)
    if Plugins.gamecenter then
        Plugins.gamecenter:sendCommand(-1, 4, json.encode({logout=true}))
    end
    if Plugins.social then
        Plugins.social:sendCommand(-1, 4, json.encode({logout=true}))
    end
end

--获取设备id
function Plugins:getDeviceId()
    if not Plugins.deviceId then
        Plugins.deviceId=Native:getDeviceId()
    end
    return Plugins.deviceId
end

--支付
function Plugins:purchase(params)
    local context = GameLogic.getUserContext()
    local rparams = {}
    rparams.product = params.product
    rparams.uid = context.uid
    rparams.sid = context.sid

	if Plugins.iap then
        local function buyOver(code, result)
            GameUI.setLoadingShow("loading", false, 0)
            print("$$$$$$$$$$buyOver",code)
            if code==0 then
                print("成功")
            elseif code==1 then
                print("不支持")
            elseif code==2 then
                print("取消")
            elseif code==3 then
                print("超时")
            elseif code==4 then
                print("失败")
            end
            params.callback(code)
        end
        GameUI.setLoadingShow("loading", true, 0)
        Plugins.iap:sendCommand(Plugins.slot:getPluginRequestCode(Script.createCallbackHandler(buyOver)), 0, json.encode(rparams))
    else
        print("支付sdk不存在:'ads'")
    end
end

--反馈
function Plugins:feedback()
    local title = Localize("feedbackTitle")
    local feedbackMail = "feedback@moyuplay.com"
    local content=""
    local lastLoginMsg = GEngine.getConfig("lastLoginMsg")
    if lastLoginMsg and lastLoginMsg~="" then
        content=lastLoginMsg[1]
    else
        content=Plugins:getDeviceId()
    end
    Native:sendEmail(feedbackMail, title, content)
end

function Plugins:openUrl(url)
    Native:openURL(url)
end
--分享
function Plugins:share(params)
    if Plugins.social then
        local function shareOver(code, fbid)
            self.shareDialog = false
            print("$$$$$$$$$$$$code:",code)
            if code==0 then
                print("$$$$$$$$$$$$code=0")
                display.pushNotice(Localize("labelShareSucceed"))
            else
                display.pushNotice(Localize("labelShareFail"))
            end
        end

        if not self.shareDialog then
            self.shareDialog = true
            local rparam = {}
            rparam.text = Localize("fbShareText" .. params.stype)
            rparam.image = sharePosImgs[params.stype]
            rparam.url = staticShareUrl
            rparam.caption = "Share Game"
            print("$$$$$$$$$share Game")
            Plugins.social:sendCommand(Plugins.slot:getPluginRequestCode(Script.createCallbackHandler(shareOver)), 1, json.encode(rparam))
        end
    end
end

--广告
function Plugins:goAds(params)
    if Plugins.ads then
        GameLogic.openAds = true
        Plugins.ads:sendCommand(-1,2,json.encode({uid=tostring(GameLogic.getUserContext().uid)}))
        GameLogic.needReloadRewards = true
    end
end

--邀请
function Plugins:invite()
   
end

function Plugins:initFriends(callback)
    local function initAccount(code, jsonStr)
        if code==0 then
            local fbfriends=json.decode(jsonStr)
            Plugins.facebookFriends=fbfriends

            local rp = cc.FileUtils:getInstance():getWritablePath()
            if rp:find(":") then
                rp = "./"
            end
            Plugins.fbHead={}
            for i,info in ipairs(fbfriends) do
                local url=info["picture"]["data"]["url"]
                local fname
                local ss=string.split(url,"/")
                for i,s in ipairs(ss) do
                    local _,b=string.find(s,".jpg",1)
                    if b then
                        fname=string.sub(s, 1, b)
                        print("fname",fname)
                        break
                    end
                end

                fname = rp .. fname
                Plugins.fbHead[info.id]=fname
                if not cc.FileUtils:getInstance():isFileExist(fname) then
                    GameNetwork.download(url, fname, nil, nil)
                end 
            end
            if callback then
                callback(Plugins.facebookFriends)
            end
        end
    end
    if Plugins.social then
        Plugins.social:sendCommand(Plugins.slot:getPluginRequestCode(Script.createCallbackHandler(initAccount)), 4, json.encode({getFriends=true}))
    end
end

function Plugins:getFriends(callback)
    if Plugins.facebookFriends then
        if callback then
            callback(Plugins.facebookFriends)
        end
    else
        Plugins:initFriends(callback)
    end
end

--统计
function Plugins:onStat(params)
    if Plugins.stat then
        Plugins.stat:sendCommand(-1, 3, json.encode(params))
    end
end
