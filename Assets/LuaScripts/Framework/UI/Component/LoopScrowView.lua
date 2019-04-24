local Vector2 = Vector2
local Vector3 = Vector3
local GameUtility = CS.GameUtility
local table_insert = table.insert
local math_floor = math.floor
local round = Mathf.Round
local math_ceil = math.ceil
local math_abs = math.abs
local tostring = tostring

local Type_ScrollRect = typeof(CS.UnityEngine.UI.ScrollRect)
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local Type_RectMask2D = typeof(CS.UnityEngine.UI.RectMask2D)
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)

local LoopScrowView = BaseClass("LoopScrowView", UIBaseContainer)
local base = UIBaseContainer

local FarPos = Vector3.New(50000, 50000, 0)

function LoopScrowView:OnCreate(onInitializeItem, isAutoDir)

    base.OnCreate(self)

    self.onInitializeItem = onInitializeItem
    if isAutoDir == nil then
        self.m_isAutoDir = true
    end

    --self tramform , content
    --暂时不需要 sizeFitter, 
    self.m_scrollRect = self.transform:GetComponentInParent(Type_ScrollRect)
    self.m_grid = self.transform:GetComponent(Type_GridLayoutGroup)
    self.m_grid.enabled = false

    -- item大小、item间隔、Grid边框
    local cellSize = self.m_grid.cellSize
    local spacing = self.m_grid.spacing
    local padding = self.m_grid.padding
    
    self.m_cellSize = Vector2.New(cellSize.x + spacing.x, cellSize.y + spacing.y)
    self.m_topLeftOffset = Vector3.New(padding.left, -padding.top, 0)

    -- 行/列数限制
    self.m_constraintCount = self.m_grid.constraintCount  
    -- 是否为水平拖动
    self.m_horizontal = self.m_scrollRect.horizontal
    
     -- 其它成员数据
    -- 缓存用
    self.m_tmpVec3 = Vector3.zero
    self:ResetPosition()

    --中心点坐标
	self.m_center = Vector2.zero
    self.m_centerOriginal = Vector2.zero

    --找到Mask节点
    local mask = self.transform:GetComponentInParent(Type_RectMask2D)
    self.m_maskRectTrans = mask.rectTransform

    --裁剪区域大小
    local scrollRectTrans = self.m_scrollRect.transform:GetComponent(Type_RectTransform)
    self.m_scrollSizeDelta = scrollRectTrans.sizeDelta

    self.__onmove = function(vec2)
		self:WrapContent()
    end
    
    self.m_scrollRect.onValueChanged:AddListener(self.__onmove)
end

--[[ function LoopScrowView:SetTempCenterPos(pos)
    if self.m_centerTran then
        self.m_centerTran.anchoredPosition = pos
    end
end ]]

function LoopScrowView:SetCenterOriginal()
    if self.m_maskRectTrans then
        local worldCorners = GameUtility.GetWorldCorners(self.m_maskRectTrans)
        if worldCorners then
            local bottom_left = self.transform:InverseTransformPoint(worldCorners[0])
            local top_right = self.transform:InverseTransformPoint(worldCorners[2])
            self.m_centerOriginal.x = (bottom_left.x + top_right.x) / 2
            self.m_centerOriginal.y = (bottom_left.y + top_right.y) / 2
            
        end 
    end
end

function LoopScrowView:OnDisable()
    self.m_itemList = {}

    self:StopMove()

    base.OnDisable(self)
end

function LoopScrowView:OnDestroy()
    self.onInitializeItem = nil

    if self.__onmove ~= nil then
        self.m_scrollRect.onValueChanged:RemoveListener(self.__onmove)
        self.__onmove = nil
	end
   
    self.m_scrollRect = nil
    self.m_grid = nil
    self.m_maskRectTrans = nil

    base.OnDestroy(self)
end

function LoopScrowView:InitChildren(itemList, showCount)
    if not itemList then
        return
    end

    self.m_showCount = showCount
    self.m_minIndex = 1
    self.m_maxIndex = showCount
    self.m_itemList = {}

    local len = #itemList
    self.m_needToWrap = showCount > len

    local item
    for i = 1, len do
        item = itemList[i]
        if item then
            if showCount > 0 then
             
                showCount = showCount - 1
            else
             
                item:SetLocalPosition(FarPos)
            end
            table_insert(self.m_itemList, item)
        end
    end

    -- 计算孩子布局宽度/高度
    local count = math_floor(((len - 1) / self.m_constraintCount) + 1)
    if self.m_horizontal then
        self.m_extents = self.m_cellSize.x * count
    else
        self.m_extents = self.m_cellSize.y * count
    end
    
    self.m_halfExtents = self.m_extents / 2
end

function LoopScrowView:SetContentSize()
    -- 设置滑动范围
    local sizeDelta = nil

    if self.m_horizontal then
        sizeDelta = Vector2.New(math_ceil(self.m_showCount / self.m_constraintCount) * self.m_cellSize.x, 
            self.m_constraintCount * self.m_cellSize.y)

        if self.m_isAutoDir then
            self.m_scrollRect.horizontal = self.m_scrollSizeDelta.x < sizeDelta.x
        end

        sizeDelta.x = sizeDelta.x + self.m_topLeftOffset.x
    else
        sizeDelta = Vector2.New(self.m_constraintCount * self.m_cellSize.x, 
            math_ceil(self.m_showCount / self.m_constraintCount) * self.m_cellSize.y)

        if self.m_isAutoDir then
            self.m_scrollRect.vertical = self.m_scrollSizeDelta.y < sizeDelta.y
        end

        sizeDelta.y = sizeDelta.y - self.m_topLeftOffset.y
    end

    self.rectTransform.sizeDelta = sizeDelta
    self.m_sizeDelta = sizeDelta
end

function LoopScrowView:ResetToBeginning()
    -- 复位

    self.m_scrollRect:StopMovement()
    self:ResetScrollView()
    self:SetCenterOriginal()
    self:ResetItemListPosition()

    self.m_forceReset = true
    self:WrapContent()
    self.m_forceReset = false
end

function LoopScrowView:ResetItemListPosition()
    local len = #self.m_itemList

    self.m_tmpVec3.z = 0
    for i = 1, len do
        local item = self.m_itemList[i]
        if item then
            if self.m_minIndex <= i and i <= self.m_maxIndex then
                item:SetGameObjectName(tostring(i))
                self:GetLocalPosition(i, self.m_tmpVec3)
                item:SetLocalPosition(self.m_tmpVec3)
            else
                item:SetGameObjectName(tostring(i))
                item:SetLocalPosition(FarPos)
            end
        end
    end
end

function LoopScrowView:ResetScrollView()
    if self.m_scrollRect then
        if self.__onmove then
            self.m_scrollRect.onValueChanged:RemoveListener(self.__onmove)
            self.m_scrollRect.onValueChanged:AddListener(self.__onmove)
        end

        self:ResetPosition()
    end
end

function LoopScrowView:ResetPosition()
	self.rectTransform.anchoredPosition = Vector2.zero
end

function LoopScrowView:GetRealIndex(pos)
    -- 索引从1开始
    pos = pos - self.m_topLeftOffset
    local x = pos.x - (self.m_cellSize.x / 2)
    local y =  pos.y + (self.m_cellSize.y / 2)

    if self.m_horizontal then
        if self.m_constraintCount > 1 then
            return round(x / self.m_cellSize.x) * self.m_constraintCount + round(-y / self.m_cellSize.y) + 1
        else
            return round(x / self.m_cellSize.x) + 1
        end
    else
        if self.m_constraintCount > 1 then
            return round(-y / self.m_cellSize.y) * self.m_constraintCount + round(x / self.m_cellSize.x) + 1
        else
            return round(-y / self.m_cellSize.y) + 1
        end
    end
end

function LoopScrowView:GetLocalPosition(realIndex, pos)
    --pos.z = 0
    local index = realIndex - 1
    if self.m_horizontal then
        if self.m_constraintCount > 1 then
            pos.x = math_floor(index / self.m_constraintCount) * self.m_cellSize.x
            pos.y = - (index % self.m_constraintCount * self.m_cellSize.y)
        else
            pos.x = index * self.m_cellSize.x
            pos.y = 0
        end
    else
        if self.m_constraintCount > 1 then
            pos.x = index % self.m_constraintCount * self.m_cellSize.x
            pos.y = - math_floor(index / self.m_constraintCount) * self.m_cellSize.y
        else
            pos.x = 0
            pos.y = -index * self.m_cellSize.y
        end
    end

    pos.x  = pos.x + (self.m_cellSize.x / 2) + self.m_topLeftOffset.x
    pos.y =  pos.y - (self.m_cellSize.y / 2) + self.m_topLeftOffset.y
    
end

function LoopScrowView:WrapContent()
    if self.m_needToWrap or self.m_forceReset then
        -- 更新中心点的局部坐标
        local anchored_position = self.rectTransform.anchoredPosition--self.m_scrollRectTrans.anchoredPosition --
        self.m_center.x =  self.m_centerOriginal.x - anchored_position.x
        self.m_center.y =  self.m_centerOriginal.y - anchored_position.y

        --self:SetTempCenterPos(self.m_center)

        local len = #self.m_itemList
        for i = 1, len do
            local item = self.m_itemList[i]
            local localPosition = item:GetLocalPosition()
            self.m_tmpVec3:Set(localPosition.x, localPosition.y, 0)
            
            --[[ local distance = self.m_horizontal and self.m_tmpVec3.x + self.m_cellSize.x / 2 - self.m_center.x 
                or self.m_tmpVec3.y - self.m_cellSize.y / 2 -  self.m_center.y ]]

            local distance = self.m_horizontal and self.m_tmpVec3.x - self.m_center.x 
                or self.m_tmpVec3.y -  self.m_center.y

            
            
            if self.m_forceReset then
                self:CheckAndUpdateItemIfNeeded(item, self.m_tmpVec3)

            elseif math_abs(distance) > self.m_halfExtents then
                if self.m_horizontal then
                    self.m_tmpVec3.x = distance < 0 and (self.m_tmpVec3.x + self.m_extents) or (self.m_tmpVec3.x - self.m_extents)
                else
                    self.m_tmpVec3.y = distance < 0 and (self.m_tmpVec3.y + self.m_extents) or (self.m_tmpVec3.y - self.m_extents)
                end
                self:CheckAndUpdateItemIfNeeded(item, self.m_tmpVec3)
            end
        end
    end
end

function LoopScrowView:CheckAndUpdateItemIfNeeded(item, localPosition)
    local realIndex = self:GetRealIndex(localPosition)
    if self.m_minIndex <= realIndex and realIndex <= self.m_maxIndex then
        item:SetGameObjectName(tostring(realIndex))
        item:SetLocalPosition(localPosition)
        self:UpdateItem(item, realIndex)
    end
end

function LoopScrowView:UpdateItem(item, realIndex)
    if self.onInitializeItem then
        self.onInitializeItem(item, realIndex)
    end
end

function LoopScrowView:ForceUpdateCurrentItems()

    --itemContent 位置可能需要更新
    local anchored_position = self.rectTransform.anchoredPosition
    if self.m_horizontal then
        local posX = -self.m_sizeDelta.x + self.m_maskRectTrans.sizeDelta.x
        if posX  < anchored_position.x then
            self.rectTransform.anchoredPosition = Vector2.New(posX, self.m_sizeDelta.y)
        end
    else
        local posY = self.m_sizeDelta.y - self.m_maskRectTrans.sizeDelta.y
        if anchored_position.y > posY then
            self.rectTransform.anchoredPosition = Vector2.New(self.m_sizeDelta.x, posY)
        end
    end
    
    --calc minIndex
    local minIndex = 999999
    local len = #self.m_itemList
    for i = 1, len do 
        local item = self.m_itemList[i]
        local localPosition = item:GetLocalPosition()
        local realIndex = self:GetRealIndex(localPosition)
        if minIndex > realIndex and realIndex > 0 then
            minIndex = realIndex
        end
    end

    --calc startIndex/endIndex
    local startIndex = minIndex < self.m_minIndex and self.m_minIndex or minIndex
    local endIndex = minIndex + len - 1
    local needResetPos = false

    if endIndex > self.m_maxIndex then
        endIndex = self.m_maxIndex
        startIndex = endIndex - (len - 1)
        needResetPos = true
    end

    if startIndex < 1 then
        startIndex = 1
    end
   -- Logger.Log("ForceUpdateCurrentItems startIndex endIndex : "..startIndex.." "..endIndex)
   -- print("needResetPos ", needResetPos)

    self.m_tmpVec3.z = 0
    for i = 1, len do 
        local item = self.m_itemList[i]
        if startIndex <= endIndex then
            if needResetPos then
                self:GetLocalPosition(startIndex, self.m_tmpVec3)
                item:SetLocalPosition(self.m_tmpVec3)
                item:SetGameObjectName(tostring(startIndex))
            end
            self:UpdateItem(item, startIndex)
        else
        
           item:SetLocalPosition(FarPos)
        end
        startIndex = startIndex + 1
    end
end

--第一次初始化数据时（包括切Tab）,bReset得传true
--第二次刷新item，可随意传
function LoopScrowView:UpdateView(bReset, itemList, dataList)
    if itemList and  dataList then
        if bReset then
            self:InitChildren(itemList, #dataList)
            self:ResetToBeginning()
            self:SetContentSize()
        else
            self:InitChildren(itemList, #dataList)
            self:SetContentSize()
            self:ForceUpdateCurrentItems()
        end
    end
end

function LoopScrowView:StopMove()
    self.m_scrollRect:StopMovement()
end

function LoopScrowView:GetScrollRect()
    return self.m_scrollRect
end

function LoopScrowView:GetScrollRectSize()
    return self.m_scrollSizeDelta
end

function LoopScrowView:UpdateOneItem(item, realIndex, showCount)
    if item then
        self.m_showCount = showCount
        self.m_minIndex = 1
        self.m_maxIndex = showCount

        if realIndex <= showCount then
        
            self:GetLocalPosition(realIndex, self.m_tmpVec3)
            self:CheckAndUpdateItemIfNeeded(item, self.m_tmpVec3)
        else
            item:SetLocalPosition(FarPos)
         
        end
    end
end

return LoopScrowView