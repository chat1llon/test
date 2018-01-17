
--[[
    实现思路
    1，创建一个可触摸层捕获触摸事件 touchNode
    2，创建容器node 装所有的cell节点
    3，根据配置参数【缩放目标格子】【缩放比例】【间隔宽度】【是否循环】【...】对各节点遍历处理
    4，添加接口可对任意格子做缩放处理（线性关系），渐变处理，位置偏移设定
    5，
]]
-- local SlideElastic = SlideElastic or class2("SlideElastic",function()
--     return ui.node()
-- end)

-- function SlideElastic:ctor()
--     self.schId = 0
-- end

-- function SlideElastic:stop()
--     if self.schId then
--         self.schId = GMethod.unschedule(self.schId)
--     end
-- end

-- function SlideElastic:run(callFunc, durtime)
--     callFunc = callFunc or function() print("default frameCallFunc") end

--     local curTime = os.time()
--     local diffTime = math.max(curTime - self.time, 1)
--     local stepX = (x - self.mark.x) / diffTime
--     local stepY = (y - self.mark.y) / diffTime
--     local function call()
--         frameCallFunc(stepX, stepY)
--         stepX = stepX * 0.8
--         stepY = stepY * 0.8
--         if math.abs(stepX) < 1 and math.abs(stepY) < 1 then
--             endCallFunc()
--             self.schId = GMethod.unschedule(self.schId)
--         end
--     end
--     if math.abs(stepX) > 0 or math.abs(stepY) > 0 then
--         self:destroy()
--         self.schId = GMethod.schedule(call, 0.01)
--     end
-- end

--
--    滑动惯性.
--
local SlideInertia = class2("SlideInertia", function()
        return ui.node()
    end )

function SlideInertia:ctor()
    self.schId = 0
end

function SlideInertia:destroy()
    if self.schId then
        self.schId = GMethod.unschedule(self.schId)
    end
end

function SlideInertia:setMark(x, y)
    self.time = os.time()
    self.mark = ccp(x, y)
    self:destroy()
end

function SlideInertia:run(x, y, frameCallFunc, endCallFunc)
    frameCallFunc = frameCallFunc or function() print("default frameCallFunc") end
    endCallFunc = endCallFunc or function() print("default endCallFunc") end

    local curTime = os.time()
    local diffTime = math.max(curTime - self.time, 1)
    local stepX = (x - self.mark.x) / diffTime
    local stepY = (y - self.mark.y) / diffTime
    local function call()
        frameCallFunc(stepX, stepY)
        stepX = stepX * 0.8
        stepY = stepY * 0.8
        if math.abs(stepX) < 1 and math.abs(stepY) < 1 then
            endCallFunc()
            self.schId = GMethod.unschedule(self.schId)
        end
    end
    if math.abs(stepX) > 0 or math.abs(stepY) > 0 then
        self:destroy()
        self.schId = GMethod.schedule(call, 0.01)
    end
end

--
--    滚动层.node 上面加一个touchNode，通过回调函数处理触摸事件
--
local scrollDirVertical = 1
local scrollDirHorizon = 2
local DirUp = 1
local DirDown = 2
local DirRight = 3
local DirLeft = 4
local anchor = {ccp(0.5,1),ccp(0.5,0),ccp(1,0.5),ccp(0,0.5)}

local ScaleScroll = class2("ScaleScroll", function()
        return ui.node();
    end );
--[[
params = {
    ["size"]              = {0,0}
    ["priority"]          = 0,
    ["scrollDir"]         = scrollDirHorizon,
    ["cellWidth"]         = 0,
    ["cellHeight"]        = 0,
    ["cellNum"]           = 0,
    ["align"]             = DirUp,
    ["triggerLen"]        = 0,
    ["scaleXY"]           = 0,
    ["maxOffset"]         = 0,
    ["isCircle"]          = false,
    ["selCallFunc"]       = nil,    =>    selCallFunc(cell)
    ["enterCallFunc"]     = nil,    =>    enterCallFunc(cell)
    ["leaveCallFunc"]     = nil,    =>     leaveCallFunc(cell)
    ["cellShowFunc"]      = nil,    =>    cellShowFunc(cell)
    ["cellHideFunc"]     = nil,    =>    cellHideFunc(cell)
    ["rankCellFunc"]      = nil,    =>   rankCellFunc(x) return y
    ["initCellFunc"]      = nil,   =>    initCellFunc(cell)
    ["calPosFunc"]        = nil,       --=>   calPosFunc(x,center)
    ["calScaleFunc"]      = nil,     --=>   calScaleFunc(dis,center,scalexy,basescale) 
}
]]
function ScaleScroll:ctor(params)
    self:initParams(params)

    self:loadAllCell()

    self.view = ui.touchNode({self.size[1],self.size[2]}, self.priority-1, false)
    self:addChild(self.view)

    --辅助显示范围的
    local colorNode = ui.colorNode({self.size[1],self.size[2]},{0,0,0})
    self:addChild(colorNode)

    --    回弹.
    --self.bound = Utils:createCocos2dObject(ScheduleObject);
    --self:addChild(self.bound);
    --    惯性.
    self.slide = SlideInertia.new();
    self:addChild(self.slide);

    --self:setAnchorPoint(ccp(0.5,0))

    RegLife(self, Handler(self.lifeCycle, self))
end

function ScaleScroll:initParams(params)
    self.size = params.size;            --可视区域大小
    self.priority = -params.priority;   --触摸优先级
    self.scrollDir = params.scrollDir or scrollDirHorizon
    self.align     = params.align or DirUp
    self.isDirX = self.scrollDir == scrollDirHorizon
    self.cellWidth = params.cellWidth;  --cell宽度
    self.cellHeight = params.cellHeight;--cell高度
    self.cellLen = self.isDirX and self.cellWidth or self.cellHeight
    self.cellNum = params.cellNum
    self.triggerLen = params.triggerLen;--放大区域两个cell间隔 一般要大于cell宽度 否则会出现遮挡
    self.triggerIdx = params.triggerIdx;--关键格子idx
    self.scaleXY = params.scaleXY;      --放大倍数
    self.maxOffset = params.maxOffset or 0; --放大区域cell上移长度
    self.isCircle = params.isCircle;    --是否循环
    self.selCallFunc = params.selCallFunc or function(cell) print("sel cell: ", cell); end; --选中cell执行操作
    self.enterCallFunc = params.enterCallFunc or function(cell) print("enter cell: ", cell); end; --即将放大回调
    self.leaveCallFunc = params.leaveCallFunc or function(cell) print("leave cell: ", cell); end; --放大结束回调
    self.cellShowFunc = params.cellShowFunc or function(cell) print("show cell: ", cell); end; --即将显示回调
    self.cellHideFunc = params.cellHideFunc or function(cell) print("hide cell: ", cell); end; --即将隐藏回调
    self.initCell = params.initCellFunc or function(cell) print("init cell: ", cell); end; --初始化
    self.calPosFunc = params.calPosFunc or function(x,center) return params.size[2] end; --计算偏移量
    self.calScaleFunc = params.calScaleFunc or function(dis,center,scalexy,basescale) print("callate scale: ", dis,center,scalexy,basescale); end; --计算缩放比例
    self.selCell = nil;                 --当前选择cell
    self.curCell = nil;                 --当先显示cell
    self.isTouch = false;               --是否点击
    self.triggerScale = self.triggerLen / self.cellLen;
    self.cellScale = 1;                 --基准缩放倍率
    self.nodePos = 0;--self.triggerLen - 0.5 * self.cellWidth cell容器的起始坐标值
    self.elements = {};                 --cell列表容器
    self.isDrag = true;                 --是否拖拽
end

function ScaleScroll:lifeCycle(event)
    print("ScaleScroll:lifeCycle:",event)
    if event=="enter" then
        self:enterOrExit(true)
    elseif event=="exit" then
        self:enterOrExit(false)
    elseif event=="cleanup" then
    end
end

function ScaleScroll:in2Value(value, minValue, maxValue)
    return value >= minValue and value <= maxValue;
end

function ScaleScroll:isTouchRect(touchPoint)
    local worldPoint = self:convertToWorldSpace(cc.p(0, 0));
    local yok = self:in2Value(touchPoint.y, worldPoint.y, worldPoint.y + self.size[2]);
    local xok = self:in2Value(touchPoint.x, worldPoint.x, worldPoint.x + self.size[1]);
    return xok and yok;
end

function ScaleScroll:checkMoveDir(offset)
    self.moveDir = self.moveDir or nil
    if offset<=0 then
        self.moveDir = self.isDirX and DirLeft or DirDown
    else
        self.moveDir = self.isDirX and DirRight or DirUp
    end
end

--边界检测
function ScaleScroll:checkBord(offset)
    local tmpNodePos = self.nodePos + offset
    if self.moveDir == DirLeft or self.moveDir == DirDown then
        local maxLen = self:getCellCount()*self.cellLen - (self.triggerIdx - 1)*self.cellLen - self.triggerLen/2
        return math.abs(tmpNodePos)<maxLen
    else
        local maxLen = (self.triggerIdx-1)*self.cellLen + self.triggerLen/2
        return tmpNodePos<maxLen
    end
end

local downPosX;
local downPosY;
function ScaleScroll:onTouch(nEventType, touchId, x, y)
    --print("ScaleScroll:onTouch nEventType",nEventType,"touchId",touchId,"x,y",x,y)
    if nEventType == cc.EventCode.BEGAN then
        return self:onTouchBegan(touchId, x, y)
    elseif nEventType == cc.EventCode.MOVED then
        self:onTouchMoved(touchId, x, y)
    elseif nEventType == cc.EventCode.ENDED then
        self:onTouchEnded(touchId, x, y)
    end
end

function ScaleScroll:onTouchBegan(touchId, x, y)
    if not self:isDragEnabeled() then
        return ;
    end
    local result = self:isTouchRect(ccp(x,y));
    self.curCell = nil;
    downPosX = x;
    downPosY = y;
    if result then
        self.slide:setMark(downPosX, downPosY);
        --self.bound:stop();
    end
    return self:isVisible() and result;
end

function ScaleScroll:onTouchMoved(touchId, x, y)
    --print("ScaleScroll:onTouchMoved nodePos",self.nodePos,x,y)
    local moveLen = self.isDirX and x-downPosX or y-downPosY
    self:checkMoveDir(moveLen)

    --调整拖动灵敏度.
    if math.abs(moveLen) > 5 then
        self.isTouch = false;
    end

    --检测移动边界
    if not self:checkBord(moveLen) then
        return
    end

    self.slide:setMark(downPosX, downPosY);
    self:moveCells(moveLen);
    downPosX = x;
    downPosY = y;
end

function ScaleScroll:onTouchEnded(touchId, x, y)
    local moveLen = self.isDirX and x-downPosX or y-downPosY
    self:checkMoveDir(moveLen)
    if not self:checkBord(moveLen) then
        return
    end
    self.slide:run(
        x, y, 
        function(stepX, stepY) self:moveCells(self.isDirX and stepX or stepY); end, 
        function() self:adjustCell(); end);
end

function ScaleScroll:enterOrExit(isEnter)
    if isEnter then
        self.view:registerScriptTouchHandler(ButtonHandler(self.onTouch, self))
    else
        self.view:unregisterScriptHandler()
        Event.unregisterAllEvents(self)
    end
end 

function ScaleScroll:moveCells(offset)
    --print("ScaleScroll:moveCells--------------- ",offset)
    self.nodePos = self.nodePos + offset;
    local curCount = self:getCellCount();
    local toDelIdx = {}
    local showIndex = 0
    --遍历所有的cell，更新每个cell的大小和位置
    for i = 1, curCount do
        local cell = self:getCellByIndex(i);
        cell:setVisible(false);

        local curPos = self.nodePos + (i-1) * self.cellLen
        local minPos = -self.cellLen/2
        local maxPos = self.size[1] + self.cellLen/2

        local cellPos = self.nodePos + (i-1) * self.cellLen--self.isDirX and cell:getPositionX() or cell:getPositionY()

        --可视范围内做处理
        if self:isCellVisible(i) then
            showIndex = showIndex + 1

            --如果未加载先加载cell
            if not cell.isInit then
                self.initCell(cell)
            end

            --从不可见到可见给一个回调出去
            if not cell.isVisible then
                cell.isVisible = true;
                self.cellShowFunc(cell,i);
                print("cellShowFunc---------i = "..i,"cell.index = "..cell.index,"count="..curCount)
                if self.isCircle then
                    --待优化
                    --[[
                        循环的滚动条实现逻辑，右划或者上划的时候，则当列表中第二个cell
                        显示出来说明就要到头则此时要删掉末尾的cell不到头部去。反之亦然，
                        若是左划或者上划那么倒数第二个出现则说明马上要到尾则删掉第一个
                        补到尾部去
                    ]]
                    if i >= curCount-1 and self.moveDir == DirLeft or self.moveDir == DirDown then
                       table.insert(toDelIdx,1,1)
                    end

                    if i <= 2 and self.moveDir == DirRight or self.moveDir == DirUp then
                       table.insert(toDelIdx,curCount)
                    end
                end
            end
            --  移动.
            local movetoX = self.isDirX and cellPos or anchor[self.align].x*self.cellWidth;
            local movetoY = self.isDirX and anchor[self.align].y*self.cellHeight or cellPos;

            local maxTriggerLen = (self.triggerIdx-1)*self.cellLen+self.triggerLen
            local minTriggerLen = (self.triggerIdx-1)*self.cellLen
            --关键触发点区域，两个回调通知方法供外部使用
            if self:in2Value(cellPos,minTriggerLen,maxTriggerLen) then
                if not cell.isEnter then
                    self.leaveCallFunc(self.selCell);
                    self.selCell.isEnter = false;
                    self.selCell = cell;
                    self.selCell.isEnter = true;
                    self.enterCallFunc(self.selCell);
                end
            end

            --关键的地方 算法待优化
            local tmpLen = maxTriggerLen - self.triggerLen / 2
            local distance = math.abs(tmpLen - cellPos);
            local maxViewPos = self.isDirX and self.size[1] or self.size[2]
            local centerPos = tmpLen
            
            local offset = (maxTriggerLen - minTriggerLen) / 2;
            local tmp1 = cellPos + (cellPos - maxTriggerLen) * (self.triggerScale - 1);
            local tmp2 = (1 - math.abs(curPos - centerPos) / offset) * self.maxOffset;
            movetoX = self.isDirX and tmp1 or movetoX + tmp2
            movetoY = self.isDirX and movetoY + tmp2 or tmp1

            cell:setPosition(movetoX, self.calPosFunc(movetoX,centerPos));
            -- if self.isDirX then
            --     cell:setPosition(tmp1, calpos(tmp1));
            -- else
            --     cell:setPosition(calpos(tmp1), tmp1);
            -- end

            --    缩放.
            --local cellPos = self.isDirX and cell:getPositionX() or cell:getPositionY()
            --local distance = math.abs(centerPos -cellPos);
            -- local scale = 0;
            -- if distance <= centerPos then
            --     scale = (1 - distance / centerPos) * (self.scaleXY - self.cellScale);
            -- end
            centerPos = math.max(tmpLen,maxViewPos-tmpLen)
            cell:setScale(self.cellScale + self.calScaleFunc(distance,centerPos,self.scaleXY,self.cellScale));
            cell:setVisible(true);
        else
            if cell.isVisible then
                cell.isVisible = false;
                self.cellHideFunc(cell);
                cell:setScale(self.cellScale)
            end
        end -- if.
    end -- for.
    if #toDelIdx>0 then
        for i=1,#toDelIdx do
            local head = toDelIdx[i] ~= 1
            local cell = self:removeCell(toDelIdx[i])
            self.nodePos = self.nodePos + (head and -self.cellLen or self.cellLen)
            self:appendCell(cell,toDelIdx[i] ~= 1)
        end
    end
end

function ScaleScroll:loadAllCell()
    self.cellNum = self.cellNum or 0
    if self.cellNum == 0 then
        return
    end
    
    --默认加载空的cell
    for i=1,self.cellNum do
        local cell = ui.node({self.cellWidth,self.cellHeight})

        local label = ui.label(""..i, General.font1, 60, {color={255,255,255}})
        label:setPosition(self.cellWidth/2,self.cellHeight/2)
        cell:addChild(label,2)
        cell.test = label

        self:appendCell(cell)
    end    
end

function ScaleScroll:isCellVisible(i)
    local cell = self:getCellByIndex(i)
    if not cell then
        return false
    end
    local x,y = cell:getPosition()
    local cellPos = self.nodePos + (i-1)*self.cellLen
    local maxViewPos = self.isDirX and self.size[1] or self.size[2]
    return self:in2Value(cellPos,0,maxViewPos)
end

function ScaleScroll:appendCell(cell,head)
    print("ScaleScroll appendCell index",cell.index,cell)
    if not head then head = false end
    --从前往后层级依次降低
    local minZorder,maxZorder = self:getMinAndMaxCellZorder();
    local zorder = head and maxZorder+1 or minZorder-1;
    local curCount = self:getCellCount();
    self.cellScale = cell:getScale();
    self.selCell = self.selCell or cell;
    self:addChild(cell,zorder);
    cell:retain();
    cell:setVisible(false)
    
    --根据添加位置（头尾）判定坐标
    cell:setAnchorPoint(anchor[self.align]);
    local factor = head and -self.cellLen or curCount * self.cellLen
    if self.isDirX then
        cell:setPosition(self.nodePos + factor, self.align == DirUp and self.cellHeight or 0);
    else
        cell:setPosition(anchor[self.align].x * self.cellWidth,self.nodePos + factor);
    end
    
    --只有新增cell才会累加index
    local isNew = not cell.index
    cell.index = isNew and curCount+1 or cell.index

    local visible = self:isCellVisible(cell.index)
    cell.isVisible = visible;
    cell.isEnter = false;

    --添加点击事件
    local cellBut = ButtonNode:create(cell:getContentSize(), self.priority or 0, 1)
    cell:addChild(cellBut, 1)
    cellBut:registerScriptTouchHandler(ButtonHandler(self.onCellTouch, self,cell))

    --加入cell列表
    if head then
        table.insert(self.elements, 1, cell);
    else
        table.insert(self.elements, cell);
    end

    --如果新增加cell 则适配
    if isNew then
        self:adjustCell();
    end
end

function ScaleScroll:onCellTouch(cell,nEventType, touchId, x, y)
    if nEventType == cc.EventCode.BEGAN then
        self.isTouch = true;
        return true
    elseif nEventType == cc.EventCode.MOVED then
    elseif nEventType == cc.EventCode.ENDED then
        if self.isTouch then 
            self:gotoCell(cell); 
        end
    end
end

function ScaleScroll:removeCell(idx, isCleanup)
    local cell = self:getCellByIndex(idx);
    cell:removeFromParent(isCleanup);
    table.remove(self.elements, idx);
    print("ScaleScroll removeCell index",cell.index,cell)

    -- if self:getCellCount() ~= 0 then
    --     self:adjustCell();
    -- end

    return cell
end

function ScaleScroll:adjustCell()
    local function call()
        local cell = self.curCell or self.selCell;
        local maxLen = self.triggerLen + (self.triggerIdx-1)*self.cellLen;
        local centerPos = (maxLen - self.triggerLen / 2);
        local pointLen = self.isDirX and cell:getPositionX() or cell:getPositionY()
        local step = centerPos - pointLen;---pointLen * 0.1;
        if math.abs(step) < 0.1 then
            self.curCell = nil;
            self.selCallFunc(cell);
        end
        self:moveCells(step);
    end
    if self:getCellCount() ~= 0 then
        call();
        --self.bound:run(call, 0.01);
    end
end

function ScaleScroll:getCellCount()
    return #(self.elements);
end

function ScaleScroll:gotoCell(cell)
    if cell:getParent() == self then
        self.curCell = cell;
        self:adjustCell();
    end
end

function ScaleScroll:getSelCell()
    return self.selCell;
end

function ScaleScroll:getMinAndMaxCellZorder()
    local min
    local max
    if self:getCellCount() == 0 then
        return 1000,1000
    else
        for i,v in ipairs(self.elements) do
            local tmp = v:getLocalZOrder()
            if not min or min > tmp then
                min = tmp
            end
            if not max or max < tmp then
                max = tmp
            end
        end
        return min,max
    end
end

function ScaleScroll:getCellByTag(tag)
    return self:getChildByTag(tag);
end

function ScaleScroll:getCellByIndex(idx)
    return self.elements[idx];
end

function ScaleScroll:setDragEnabeled(isDrag)
    self.isDrag = isDrag;
end

function ScaleScroll:isDragEnabeled()
    return self.isDrag;
end

return ScaleScroll