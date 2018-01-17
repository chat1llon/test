local TestController = {}

GEngine.lockG(false)
GMethod.loadScript("game.GameLogic")
GMethod.loadScript("game.GameUI")
GMethod.loadScript("game.UI.Dialog.Dialog")
GMethod.setConfigMode(true)
GEngine.lockG(true)

function TestController:initTest()
    local testBack = ui.node({1920, 1080})
    display.adapt(testBack, 0, 0, GConst.Anchor.Center, {scaleType=GConst.Scale.Height})
    display.addLayer(testBack, 0, 0)

    local infos = {}
    table.insert(infos, {name="Dialog.DemoSprite",nameMenu="for test"})
    -- table.insert(infos, {name="Dialog.DemoLabel"})
    -- table.insert(infos, {name="Dialog.DemoLabel2"})
    -- table.insert(infos, {name="Dialog.DemoButton"})
    -- table.insert(infos, {name="Dialog.DemoLayout"})
    -- table.insert(infos, {name="Dialog.DemoScroll"})
    -- table.insert(infos, {name="Dialog.DemoWidget"})
    -- table.insert(infos, {name="Dialog.DemoTest"})
    local updateFunc = Handler(self.updateTestCell, self)
    local scrollView = ui.createTableView({1920, 1080}, false, {cellActionType=1, size=cc.size(1900, 100), offx=10, oy=24, disx=20, disy=20, rowmax=1, infos=infos, cellUpdate=updateFunc})
    display.adapt(scrollView.view, 0, 0, GConst.Anchor.LeftBottom)
    testBack:addChild(scrollView.view)
end

function TestController:updateTestCell(cell, tableView, info)
    if not info.label then
        info.label = ui.label("", General.font1, 50)
        display.adapt(info.label, 1000, 50, GConst.Anchor.Center)
        cell:getDrawNode():addChild(info.label)
        cell:setScriptCallback(ButtonHandler(self.onCellAction, self, info))
    end
    info.label:setString(info.nameMenu or info.name)
end

function TestController:onCellAction(info)
    display.sendIntent({class="game.UI." .. info.name})
end

return TestController
