local LoopScrollRectHelper = BaseClass("LoopScrollRectHelper")

local LoopScrollRect = CS.UnityEngine.UI.LoopScrollRect
local Type_LoopScrollRect = typeof(LoopScrollRect)

function LoopScrollRectHelper:__init(transform, resPath, onInitializeItem, onDeleteItem)

    assert(resPath ~= '')

    self.m_transform = transform
    self.m_resPath = resPath
    self.m_onDeleteItem = onDeleteItem

    self.m_scrollRect = self.m_transform:GetComponent(Type_LoopScrollRect)
    if self.m_scrollRect then
        local getGameObjectFunc = function()
            local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            local obj = nil
            UIGameObjectLoader:GetInstance():GetGameObject(seq, self.m_resPath, function(go)
                if not IsNull(go) then
                    obj = go
                end
            end)
            
            return obj
        end

        local returnObjectFunc = function(go)
            if not IsNull(go) then
                if self.m_onDeleteItem then
                    self.m_onDeleteItem(go)
                end
                UIGameObjectLoader:GetInstance():RecycleGameObject(self.m_resPath, go)
            end
        end

        self.m_scrollRect.prefabSource:SetCallBack(getGameObjectFunc, returnObjectFunc)
        self.m_scrollRect.dataSource:SetOnInitializeItem(onInitializeItem)
    end
end

function LoopScrollRectHelper:__delete()
    if self.m_scrollRect then
        self.m_scrollRect.prefabSource:SetCallBack(nil, nil)
        self.m_scrollRect.dataSource:SetOnInitializeItem(nil)
        self.m_scrollRect = nil
    end

    self.m_onDeleteItem = nil
    self.m_transform = nil
    self.m_resPath = nil
end

function LoopScrollRectHelper:UpdateData(dataCount, needRefill)
    if self.m_scrollRect then

        if needRefill == nil then
            needRefill = true
        end
        self.m_scrollRect.totalCount = dataCount
        if needRefill then
            self.m_scrollRect:RefillCells()
        end
    end
end

function LoopScrollRectHelper:SrollToCell(index, speed)
    if self.m_scrollRect then
        speed = speed or 1000
        self.m_scrollRect:SrollToCell(index, speed)
    end
end

function LoopScrollRectHelper:ClearCells()
    if self.m_scrollRect then
        self.m_scrollRect:ClearCells()
    end
end

return LoopScrollRectHelper