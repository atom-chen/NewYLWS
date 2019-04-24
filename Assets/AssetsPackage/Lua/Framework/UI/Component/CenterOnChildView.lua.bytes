local Vector2 = Vector2
local Vector3 = Vector3
local GameUtility = CS.GameUtility
local table_insert = table.insert
local math_abs = math.abs
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local Type_ScrollRect = typeof(CS.UnityEngine.UI.ScrollRect)
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local CenterOnChildView = BaseClass("CenterOnChildView", UIBaseContainer)
local base = UIBaseContainer

function CenterOnChildView:OnCreate(onConterItemCallBack)

    base.OnCreate(self)
    self.m_onConterItemCallBack = onConterItemCallBack
    self.m_childrenPos = {}
    self.m_showCount = 0

    --暂时不需要 sizeFitter, 
    self.m_scrollRect = self.transform:GetComponent(Type_ScrollRect)
    self.m_grid = self.transform:GetComponentInChildren(Type_GridLayoutGroup)
    self.m_grid.enabled = false
    self.m_contentTrans = self.m_grid:GetComponent(Type_RectTransform)

    -- item大小、item间隔、Grid边框
    local cellSize = self.m_grid.cellSize
    local spacing = self.m_grid.spacing
    local padding = self.m_grid.padding
    
    self.m_cellSize = Vector2.New(cellSize.x + spacing.x, cellSize.y + spacing.y)
    --self.m_topLeftOffset = Vector3.New(padding.left - spacing.x / 2, padding.top - spacing.y / 2, 0)
    -- 行/列数限制
    self.m_constraintCount = self.m_grid.constraintCount  
    -- 是否为水平拖动
    self.m_horizontal = self.m_scrollRect.horizontal
    
    --裁剪区域大小
    local scrollRectTrans = self.m_scrollRect.transform:GetComponent(Type_RectTransform)
    self.m_scrollSizeDelta = scrollRectTrans.sizeDelta
    self.m_centering = false
end

function CenterOnChildView:OnInitialize(showCount)
    local childPosX = 0
    local childPosY = 0
    self.m_showCount = showCount
    if self.m_horizontal then
        childPosX = self.m_cellSize.x * 0.5 - self.m_scrollSizeDelta.x * 0.5
        table_insert(self.m_childrenPos, childPosX)
        --缓存所有子物体位于中心时的位置        
        if self.m_showCount then
            for i = 1, self.m_showCount-1 do
                childPosX = childPosX + self.m_cellSize.x
                table_insert(self.m_childrenPos, childPosX)
            end
        end
    else
        childPosY = self.m_cellSize.y * 0.5 - self.m_scrollSizeDelta.y * 0.5
        table_insert(self.m_childrenPos, childPosY)
        --缓存所有子物体位于中心时的位置        
        if self.m_showCount then
            for i = 1, self.m_showCount-1 do
                childPosY = childPosY + self.m_cellSize.y
                table_insert(self.m_childrenPos, childPosY)
            end
        end
    end
    
    local function DragEnd(go, x, y, eventData)
        self:OnDragEnd(go, x, y, eventData)
    end
    UIUtil.AddDragEndEvent(self.m_scrollRect.gameObject, DragEnd)
end

function CenterOnChildView:OnDragEnd(go, x, y, eventData)
    if not self.m_centering then
        self.m_centering = true
        local targetPos = self:FindClosestPos(self.m_contentTrans.localPosition.y);
        self:OnMoveToTargetPos(targetPos)
    end
end

function CenterOnChildView:OnMoveToTargetPos(targetPos)
    if targetPos then
        local tweenner = DOTweenShortcut.DOLocalMoveY(self.m_contentTrans, targetPos, 0.2)
        DOTweenSettings.OnComplete(tweenner, function()
            self.m_contentTrans.localPosition.y = targetPos
            self.m_centering = false
        end)
    end
end

function CenterOnChildView:FindClosestPos(currentPos)
    if #self.m_childrenPos > 0 then
        local childIndex = 1
        local closest = self.m_childrenPos[1]
        local distance = math_abs(self.m_childrenPos[1] - currentPos)
        for i=1,self.m_showCount do   
            local midPos = self.m_childrenPos[i]
            local midDis = math_abs(midPos - currentPos) 
            if midDis < distance then
                distance = midDis
                closest = midPos
                childIndex = i
            end
        end
        if self.m_onConterItemCallBack then
            self.m_onConterItemCallBack(childIndex)
        end
        return closest
    end
end

function CenterOnChildView:OnCenterItemIndex(index)
    if index and index < #self.m_childrenPos then
        self:OnMoveToTargetPos(self.m_childrenPos[index])
        if self.m_onConterItemCallBack then
            self.m_onConterItemCallBack(index)
        end
    end
end

function CenterOnChildView:OnDisable()
    self.m_childrenPos = {}
    self.m_showCount = 0
    UIUtil.RemoveDragEvent(self.m_scrollRect.gameObject)
    base.OnDisable(self)
end

function CenterOnChildView:OnDestroy()
    self.m_childrenPos = {}
    self.m_showCount = 0
    self.m_onConterItemCallBack = nil
   
    self.m_scrollRect = nil
    self.m_grid = nil

    base.OnDestroy(self)
end

return CenterOnChildView