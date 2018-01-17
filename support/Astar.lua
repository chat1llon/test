--[[
    AstarNode:A* 寻路的辅助类，主要用于存储每个寻路格子的位置，g和h值以及上一步信息
    @dnt
]]

local AstarNode = class2("AstarNode",function ()
    return ui.node()
end)

function AstarNode:ctor()
    self._point = nil
    self._gScore = 0
    self._hScore = 0
    self._parent = nil
end

function AstarNode:create(point)
    local pob = self.new()
    if pob then
        pob:Init(point)
        return pob
    end
    return nil
end

function AstarNode:Init(point)
    self._point = point
end
function AstarNode:setPoint(x,y) self._point = {x,y} end

function AstarNode:getPoint() return self._point end

function AstarNode:setParent(parent) self._parent = parent end

function AstarNode:getParent() return self._parent end

function AstarNode:getFScore() return self._gScore + self._hScore end

function AstarNode:setGScore(score) self._gScore = score end

function AstarNode:getGScore() return self._gScore end

function AstarNode:setHScore(score) self._hScore = score end

function AstarNode:getHScore() return self._hScore end

function AstarNode:isEqual(step)
    return PosEqual(self._point,step:getPoint())
end

function AstarNode:getDesc()
    print("pos=",self._point[1],self._point[2],"g=",self._gScore,"h=",self._hScore,"f=",self:getFScore())
end


local Astar = class()


function Astar:ctor()
    self._blockRectList = {}
    self._pathRectList = {}

    self._openStepList = {}
    self._closedStepList = {}
end

function Astar:setGridData(rect,cellWidth,cellHeight)
    self._mapRect = rect
    self._cellWidth = cellWidth
    self._cellHeight = cellHeight
end

function Astar:addBlockRect(key,rect)
    self._blockRectList[key] = rect
end

function Astar:deleteBlockRect(key)
    self._blockRectList[key] = nil
end

function Astar:getBlockList(key)
    return self._blockRectList[key]
end

--获取所在网格index
function Astar:getGridPointIndex(x,y)
    local xGridIndex = math.ceil(x/self._cellWidth)
    local yGridIndex = math.ceil(y/self._cellHeight)
    return {xGridIndex,yGridIndex}
end

--根据实际坐标计算相应网格的坐标
function Astar:convertToGridPoint(x,y)
    local grid = self:getGridPointIndex(x,y)

    local gridPointX = (grid[1]-0.5)*self._cellWidth
    local gridPointY = (grid[2]-0.5)*self._cellHeight

    return {gridPointX,gridPointY}
end

--验证是否为不可过点
function Astar:isValidPathGrid(point)
    if point[1]>cc.rectGetMaxX(self._mapRect) or point[1]<cc.rectGetMinX(self._mapRect) or 
        point[2]>cc.rectGetMaxY(self._mapRect) or point[2]<cc.rectGetMinY(self._mapRect) then
        return false
    end

    for k,v in pairs(self._blockRectList) do
        if cc.rectContainsPoint(v,ccp(point[1],point[2])) then
            return false,k
        end
    end

    return true
end

--获取当前点的周围可以加入openlist的网格点
function Astar:getWalkAbleGridPointArray(point)
    local pointArray = {}
    local gPt = self:convertToGridPoint(point[1],point[2])

    --初始化上下左右都不可以走
    local u = false
    local l = false
    local d = false
    local r = false
    --上
    local upPoint = {gPt[1],gPt[2]+self._cellHeight}
    if self:isValidPathGrid(upPoint) then
        table.insert(pointArray,upPoint)
        u = true
    end

    --左
    local leftPoint = {gPt[1]-self._cellWidth,gPt[2]}
    if self:isValidPathGrid(leftPoint) then
        table.insert(pointArray,leftPoint)
        l = true
    end

    --下
    local downPoint = {gPt[1],gPt[2]-self._cellHeight}
    if self:isValidPathGrid(downPoint) then
        table.insert(pointArray,downPoint)
        d = true
    end

    --右
    local rightPoint = {gPt[1]+self._cellWidth,gPt[2]}
    if self:isValidPathGrid(rightPoint) then
        table.insert(pointArray,rightPoint)
        r = true
    end

    --斜着走必须是在没有障碍物阻挡的情况下才可以
    --左上
    local ulPoint = {gPt[1]-self._cellWidth,gPt[2]+self._cellHeight}
    if u and l and self:isValidPathGrid(ulPoint) then
        table.insert(pointArray,ulPoint)
    end

    --左下
    local dlPoint = {gPt[1]-self._cellWidth,gPt[2]-self._cellHeight}
    if d and l and self:isValidPathGrid(dlPoint) then
        table.insert(pointArray,dlPoint)
    end

    --右下
    local drPoint = {gPt[1]+self._cellWidth,gPt[2]-self._cellHeight}
    if d and r and self:isValidPathGrid(drPoint) then
        table.insert(pointArray,drPoint)
    end

    --右上
    local urPoint = {gPt[1]+self._cellWidth,gPt[2]+self._cellHeight}
    if u and r and self:isValidPathGrid(urPoint) then
        table.insert(pointArray,urPoint)
    end
    return pointArray
end

--计算相邻网格点的移动成本（距离）
function Astar:costToMoveFromStepToAdjacentStep(fromStep, toStep)
    local fromPoint = fromStep:getPoint()
    local toPoint = toStep:getPoint()
    if fromPoint[1] == toPoint[1] then --上下方向
        return self._cellHeight 
    elseif fromPoint[2] == toPoint[2] then --佐佑方向
        return self._cellWidth 
    else
        return math.floor(math.sqrt(math.pow(self._cellWidth,2)+math.pow(self._cellHeight,2))) --斜着走
    end
end

function Astar:insertStep(step)
    for i=1,#self._openStepList do
        if step:getFScore() <= self._openStepList[i]:getFScore() then
            table.insert(self._openStepList,i,step)
            return
        end
    end
    table.insert(self._openStepList,step)
end

function Astar:calHScore(fromGrid, toGrid)
    -- 这里使用曼哈顿方法，计算从当前步骤到达目标步骤，在水平和垂直方向总的步数
    -- 忽略了可能在路上的各种障碍
    return math.abs(toGrid[1] - fromGrid[1]) + math.abs(toGrid[2] - fromGrid[2])
end

function Astar:getStepIndex(vecStep,step)
    for i=1,#vecStep do
        if vecStep[i]:isEqual(step) then
            return i
        end
    end
    return -1
end

function Astar:makeAstarPath(curStep)
    local path = {}
    while(curStep)
    do
        -- 起始位置不要进行添加
        if (curStep:getParent()) then
            --curStep:getDesc()
            -- 总是插入到索引1的位置，以便反转路径
            table.insert(path,1,curStep:getPoint())
        end
        curStep = curStep:getParent()  -- 倒退
    end
    path = self:SmoothingPath(path)
    --print("Astar:makeAstarPath",#path)
    return path
end

function Astar:findPath(srcPoint,tarPoint)
    local srcGridPoint = self:convertToGridPoint(srcPoint[1],srcPoint[2])
    local tarGridPoint = self:convertToGridPoint(tarPoint[1],tarPoint[2])

    --如果已经在终点则返回
    if PosEqual(tarGridPoint,srcGridPoint) then
        print("Astar:findPath: you are in targetPoint~")
        return false,{}
    end
    --目标点特殊处理一下
    local invalid,tRectKey = self:isValidPathGrid(tarGridPoint)
    if false == invalid and tRectKey ~= nil then
        self:deleteBlockRect(tRectKey)
    end

    table_clear(self._openStepList)
    table_clear(self._closedStepList)

    --print("Astar:findPath srcGridPoint=",srcGridPoint[1],srcGridPoint[2],"tarGridPoint=",tarGridPoint[1],tarGridPoint[2])
    --插入当前点
    local step = AstarNode:create(srcGridPoint)
    self:insertStep(step)

    while(#self._openStepList>0)
    do
        local curStep = self._openStepList[1]
        local curStepPoint = curStep:getPoint()
        -- 添加当前步骤到closed列表
        table.insert(self._closedStepList,curStep)
        -- 将它从open列表里面移除
        -- 需要注意的是，如果想要先从open列表里面移除，应小心对象的内存
        table.remove(self._openStepList,1)

        --print("curStep point=",curStepPoint[1],curStepPoint[2],"g=",curStep:getGScore(),"h=",curStep:getHScore(),"f=",curStep:getFScore())

        -- 如果当前步骤是目标方块坐标，说明寻到了目标
        local rect = cc.rect(curStepPoint[1]-self._cellWidth/2,curStepPoint[2]-self._cellHeight/2,self._cellWidth,self._cellHeight)
        if cc.rectContainsPoint(rect,ccp(tarGridPoint[1],tarGridPoint[2])) then
            
            local path = self:makeAstarPath(curStep)

            table_clear(self._openStepList)
            table_clear(self._closedStepList)

            return true,path
        end

        -- 得到当前步骤的相邻方块坐标
        local adjSteps = self:getWalkAbleGridPointArray(curStepPoint)
        for i = 1, #adjSteps do
            while(true)
            do
                step = AstarNode:create(adjSteps[i])

                -- 检查步骤是不是已经在closed列表
                if self:getStepIndex(self._closedStepList, step) ~= -1 then
                    break
                end

                -- 计算从当前步骤到此步骤的成本
                local moveCost = self:costToMoveFromStepToAdjacentStep(curStep, step)

                -- 检查此步骤是否已经在open列表
                local index = self:getStepIndex(self._openStepList, step)

                -- 不在open列表，添加它
                if index == -1 then                
                    -- 设置当前步骤作为上一步操作
                    step:setParent(curStep)

                    -- G值等同于上一步的G值 + 从上一步到这里的成本
                    step:setGScore(curStep:getGScore() + moveCost)

                    -- H值即是从此步骤到目标方块坐标的移动量估算值
                    step:setHScore(self:calHScore(step:getPoint(), tarGridPoint))

                    -- 按序添加到open列表
                    self:insertStep(step)
                else
                    -- 获取旧的步骤，其值已经计算过
                    step = self._openStepList[index]

                    -- 检查G值是否低于当前步骤到此步骤的值
                    if ((curStep:getGScore() + moveCost) < step:getGScore()) then
                        -- 设置当前步骤作为上一步操作
                        step:setParent(curStep)                   
                        -- G值等同于上一步的G值 + 从上一步到这里的成本
                        step:setGScore(curStep:getGScore() + moveCost)

                        -- 因为G值改变了，F值也会跟着改变
                        -- 所以为了保持open列表有序，需要将此步骤移除，再重新按序插入

                        -- 在移除之前，需要先保持引用
                        step:retain()

                        -- 现在可以放心移除，不用担心被释放
                        table.remove(self._openStepList,index)

                        -- 重新按序插入
                        self:insertStep(step)

                        -- 现在可以释放它了，因为open列表应该持有它
                        step:release()
                    end
                end
                break
            end
        end
    end

    --寻路完毕把障碍物添加回去
    if tRectKey then
       self:addBlockRect(tRectKey,self._blockRectList[tRectKey])
    end

    return false,{}
end

function Astar:Walkable(pa,pb)
    local m_tileSize = math.max(self._cellWidth,self._cellHeight)

    if false == self:isValidPathGrid(pa) then
        return false
    end
    if false == self:isValidPathGrid(pb) then
        return false
    end
    local sPos = cc.p(pa[1],pa[2])
    local tPos = cc.p(pb[1],pb[2])
    --计算两点之间距离
    local distanseLen = cc.pGetDistance(sPos,tPos)
    --每次移动0.1单位，计算移动次数
    local totalStep = distanseLen/(m_tileSize*0.1)
    --x y 方向每一步移动的距离
    local stepXlen = (pb[1]-pa[1])/totalStep
    local stepYlen = (pb[2]-pa[2])/totalStep

    local blocksize = m_tileSize
    for i=1,totalStep do
        --中心点
        local ctPos = {pa[1]+stepXlen*i,pa[2]+stepYlen*i}
        --左上
        local lhPos = {ctPos[1]-blocksize/2,ctPos[2]+blocksize/2}
        --左下
        local llPos = {ctPos[1]-blocksize/2,ctPos[2]-blocksize/2}
        --右上
        local rhPos = {ctPos[1]+blocksize/2,ctPos[2]+blocksize/2}
        --右下
        local rlPos = {ctPos[1]+blocksize/2,ctPos[2]-blocksize/2}

        if false == self:isValidPathGrid(ctPos) or 
           false == self:isValidPathGrid(lhPos) or
           false == self:isValidPathGrid(llPos) or
           false == self:isValidPathGrid(rhPos) or
           false == self:isValidPathGrid(rlPos) then
            return false
        end
    end

    return true
end

function Astar:SmoothingPath(path)
    if #path<3 then
        return path
    end

    local A = path[1]
    local B = path[2]
    local i = 3
    while (#path>=i)
    do
        if self:Walkable(A,path[i]) then
            B = path[i]
            table.remove(path,i-1)
        else
            A = B
            B = path[i]
            i = i+1
        end
    end

    return path
end

return Astar
