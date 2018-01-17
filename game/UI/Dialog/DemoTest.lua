local DemoTest = class(DialogViewLayout)
local ViewTemplates = GMethod.loadScript("game.UI.Dialog.ViewTemplates.Init")
local _icons = {"images/sprites/cm_icon_cash.png", "images/sprites/cm_icon_crystal.png", "images/sprites/cm_icon_jade.png"}
math.randomseed(os.time())

local shopList = {}
local bagList = {}
local infos = {}
local infob={}
local means=0

function DemoTest:onInitDialog()
	infos = {{id=1},{id=2},{id=3},{id=4},{id=5},{id=6}}
    self:setLayout("demoTest.json")
    self:randomShop()
    self:displayShop()
    self.button_refresh:setScriptCallback(ButtonHandler(self.onShopRefresh,self))
    self.button_sell:setScriptCallback(ButtonHandler(self.onSell,self))
    self.totalCoin:setColor(0,0,0)
end

function DemoTest:randomShop()
	for i=1,#infos do
	    local para={}
	    para.pic=math.random(1,3)
        para.num=math.random(1,999)
        table.insert(shopList,para)
    end
end

function DemoTest:insertBag(sid)
	local para_b
	para_b=shopList[sid]
	para_b.mode=1
	table.insert(bagList,para_b)
	if para_b.pic==1 then
		means=means+para_b.num
	end
end

function DemoTest:displayShop()
	for i=1, #shopList do
        infos[i] = {id=i}
    end
	ViewTemplates.setImplements(self.list,"LayoutImplement",{callback=Handler(self.onInitShop,self),withIdx=false})
    self.list:setLayoutDatas(infos)
    
end
function DemoTest:displayBag()
    for i=1, #bagList do
        infob[i] = {id=i}
    end
    
    self.scroll:setLazyTableData(infob, Handler(self.onBagRf, self), 0)
end
--callback start
function DemoTest:onSell()
	local dls = {}
	for k,v in pairs(bagList) do
		if bagList[k].mode==2 then
			dls[k]=true
			if bagList[k].pic==1 then
				means=means-bagList[k].num
			end
		end
	end

	for i=#bagList,1,-1 do
		if dls[i] then
			table.remove(bagList,i)
			table.remove(infob,i)
		end
	end
    self:displayShop()
	self:displayBag()
end
function DemoTest:onBagRf(reuseCell, scrollView, data)
    if not reuseCell then
        reuseCell = scrollView:createItem(1)
        reuseCell:loadViewsTo()
        reuseCell:setScriptCallback(ButtonHandler(self.onBagClick,self,data,reuseCell))
    end
    print("test", bagList[data.id].pic, tostring(data))
    local flag=bagList[data.id].mode

    if flag==1 then
        reuseCell.tick:setOpacity(0)
    else
    	reuseCell.tick:setOpacity(255)
    end

    self.totalCoin:setString(means)

    reuseCell.image:setImage(_icons[bagList[data.id].pic], 0, nil, nil, true)
	reuseCell.num:setString("x"..bagList[data.id].num)

    return reuseCell
end

function DemoTest:onShopClick(item)
	self:insertBag(item.id)
	table.remove(infos,item.id)
	table.remove(shopList,item.id)
	self:displayShop()
	self:displayBag()
end

function DemoTest:onInitShop(reuseCell,layout,item)
	if not reuseCell then
        reuseCell = layout:createItem(1)
        reuseCell:loadViewsTo()
        reuseCell:setScriptCallback(ButtonHandler(self.onShopClick,self,item))
    end
    
    reuseCell.displayId = item.id
    reuseCell.image:setImage(_icons[shopList[item.id].pic], 0, nil, nil, true)
    reuseCell.num:setString("x"..shopList[item.id].num)
    
    return reuseCell
end

function DemoTest:onShopRefresh()
	shopList={}
	infos = {{id=1},{id=2},{id=3},{id=4},{id=5},{id=6}}
	self:randomShop()
	self.list:removeAllChildren(true)
	self:displayShop()
	
end

function DemoTest:onBagClick(item,reuseCell)
	bagList[item.id].mode=(bagList[item.id].mode or 0) % 2 + 1
	local flag=bagList[item.id].mode
	if flag==1 then
        reuseCell.tick:setOpacity(0)
    else
    	reuseCell.tick:setOpacity(255)
    end
end
--callback end

return DemoTest


