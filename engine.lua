--设置lua的垃圾回收参数；暂时引擎不考虑这方面的配置。

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
local startCheck = package.path:find(";")
if not startCheck or startCheck>1 then
    package.path = ";" .. package.path
end
for i=1, 10 do
    GameEngine:getInstance():getPackageManager():loadPackage("data" .. i .. ".pkg")
end
require "cocos.Cocos2d"
require "cocos.Cocos2dConstants"
require "cocos.functions"
-- require "cocos.luaj"
-- require "cocos.luaoc"
require "cocos.Opengl"
require "cocos.OpenglConstants"
require "engine.GEngine"
