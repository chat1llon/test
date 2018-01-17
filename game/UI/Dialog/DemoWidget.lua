local DemoWidget = class(DialogViewLayout)
local ViewTemplates = GMethod.loadScript("game.UI.Dialog.ViewTemplates.Init")

function DemoWidget:onInitDialog()
    self:setLayout("demoWidget.json")

    self.btn_close:setScriptCallback(ButtonHandler(display.closeDialog, self.priority))

    ViewTemplates.setImplements(self.bottom, "LayoutImplement", {callback=Handler(self.onUpdateItemsCell1, self), withIdx=false})
    ViewTemplates.setImplements(self.bottom2, "LayoutImplement", {callback=Handler(self.onUpdateItemsCell2, self), withIdx=false})
    
    local infos = {{id=1}, {id=2}, {id=3}}
    self.bottom:setLayoutDatas(infos)
    self.bottom2:setLayoutDatas(infos)
end

local _icons = {"images/sprites/cm_icon_cash.png", "images/sprites/cm_icon_crystal.png", "images/sprites/cm_icon_jade.png"}
function DemoWidget:onUpdateItemsCell1(reuseCell, layout, item)
    if not reuseCell then
        reuseCell = layout:createItem(1)
        reuseCell:loadViewsTo()
    end
    if item.id ~= reuseCell.displayId then
        reuseCell.displayId = item.id
        reuseCell.image:setImage(_icons[item.id], 0, nil, nil, true)
    end
    return reuseCell
end

function DemoWidget:onUpdateItemsCell2(reuseCell, layout, item)
    if not reuseCell then
        reuseCell = layout:createItem(1)
        reuseCell:loadViewsTo()
    end
    if item.id ~= reuseCell.displayId then
        reuseCell.displayId = item.id
        reuseCell.image_back:removeAllChildren(true)
        local image = ui.sprite(_icons[item.id], reuseCell.image_back.size, true)
        --display.adapt(image, reuseCell.image_back.size[1]/2, reuseCell.image_back.size[2]/2, GConst.Anchor.Center)
        reuseCell.image_back:addChild(image)
    end
    return reuseCell
end

function DemoWidget:enterAnimate()
    return 0
end

function DemoWidget:exitAnimate()
    return 0
end

return DemoWidget
