local DemoScroll = class(DialogViewLayout)

function DemoScroll:onInitDialog()
    self:setLayout("demoScroll.json")

    local infos = {}
    for i=1, 40 do
        infos[i] = {id=i}
    end
    self.scrollview:setLazyTableData(infos, Handler(self.onUpdateItemCell, self), 0)
    self.scrollview2:setLazyTableData(infos, Handler(self.onUpdateItemCell, self), 0)
    self.scrollview3:setLazyTableData(infos, Handler(self.onUpdateItemCell, self), 0)
end

function DemoScroll:onUpdateItemCell(reuseCell, scrollView, info)
    if not reuseCell then
        reuseCell = scrollView:createItem(1)
        reuseCell:loadViewsTo()
    end
    reuseCell.label_test:setString("!LTEST" .. info.id)
    return reuseCell
end

return DemoScroll
