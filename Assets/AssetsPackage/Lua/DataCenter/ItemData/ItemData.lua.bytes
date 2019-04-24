local ItemData = BaseClass("ItemData")

function ItemData:__init(_itemID, _itemCount, _locked)
    assert(itemID ~= 0)
    self.m_itemID = _itemID or 0
    self.m_itemCount = _itemCount or 0
    self.m_isLocked = _locked or false
    self.m_stage = nil
end

function ItemData:UpdateInfo(count, locked)
    self.m_itemCount = count
    self.m_isLocked = locked
end

function ItemData:GetItemID()
    return self.m_itemID or 0
end

function ItemData:GetItemCount()
    return self.m_itemCount or 0
end

function ItemData:GetItemCfg()
    return ConfigUtil.GetItemCfgByID(self.m_itemID)
end

function ItemData:GetStage()
    if not self.m_stage then
        local itemCfg = self:GetItemCfg()
        if itemCfg then
            self.m_stage = itemCfg.nColor
        end
    end
    return self.m_stage or 1
end

function ItemData:GetIndex()
    return 0
end

function ItemData:GetLockState()
    return self.m_isLocked or false
end

--用于区别物品的字段
function ItemData:GetUniqueID()
    return self.m_itemID or 0
end

function ItemData:GetMainType()
    local itemCfg = self:GetItemCfg()
    return itemCfg and itemCfg.sMainType or 0
end

return ItemData