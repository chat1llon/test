local DemoLabel = class(DialogViewLayout)

function DemoLabel:onInitDialog()
    self:setLayout("demoLabel.json")
end

return DemoLabel
