local DemoSprite = class(DialogViewLayout)

function DemoSprite:onInitDialog()
    self:setLayout("demoSprite.json")
    self.btn_close:setScriptCallback(ButtonHandler(display.closeDialog, self.priority))
    local node=ui.sprite("images/sprites/cm_icon_cash.png",{80,80})
    display.adapt(node,300,500)
    local action=cc.MoveBy:create(4,cc.p(800,0))
    node:runAction(cc.EaseSineOut:create(action))
    self:addChild(node,1)
end
return DemoSprite
