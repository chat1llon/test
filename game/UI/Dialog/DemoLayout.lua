local DemoLayout = class(DialogViewLayout)
local ViewTemplates = GMethod.loadScript("game.UI.Dialog.ViewTemplates.Init")

function DemoLayout:onInitDialog()
    self:setLayout("demoLayout.json")

    self.buttonTest:setScriptCallback(ButtonHandler(self.onChangeTest, self))
    self.layout2:lazyload()

    ViewTemplates.setImplements(self.layout3, "LayoutImplement", {callback=Handler(self.onUpdateItemsCell, self), withIdx=false})
    self.layout3:setLayoutDatas({1,2,3,4})
end

function DemoLayout:onUpdateItemsCell(reuseCell, layout, item)
    if not reuseCell then
        reuseCell = layout:createItem(1)
        reuseCell:loadViewsTo()
    end
    reuseCell.label_test:setString("Test" .. item)
    return reuseCell
end

function DemoLayout:onChangeTest()
    self.mode = (self.mode or 0) % 3 + 1
    if self.mode == 1 then
        self.label_test:setString("1个字")
        self.icon_test:setVisible(true)
    elseif self.mode == 2 then
        self.label_test:setString("9999999")
        self.icon_test:setVisible(true)
    else
        self.label_test:setString("1个字")
        self.icon_test:setVisible(false)
    end
end

return DemoLayout
