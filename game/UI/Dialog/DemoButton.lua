local DemoButton = class(DialogViewLayout)

function DemoButton:onInitDialog()
    self:setLayout("demoButton.json")
end

return DemoButton
