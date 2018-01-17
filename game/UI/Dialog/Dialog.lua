
--这个用于实现标准对话框的常规逻辑
DialogViewLayout = class(ViewLayout)

function DialogViewLayout:onCreate()
    local setting = self._setting
    if setting then
        for k, v in pairs(setting) do
            if not self[k] then
                self[k] = v
            end
        end
    else
        self._setting = {}
    end
    if not self.context then
        self.context = GameLogic.getUserContext()
    end
    if self.parent then
        if self.parent.priority then
            self.priority = self.parent.priority+1
        else
            self.priority = (self.parent.getDialog and self.parent:getDialog().priority or display.getDialogPri())+1
        end
    else
        self.priority=display.getDialogPri()+1
    end
    self:onInitDialog()
end

function DialogViewLayout:onQuestion()
    if self.questionTag then
        HelpDialog.new(self.questionTag)
        return
    end
    display.pushNotice(Localize("noticeNotSupport"))
end
