local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig

local SimpleAwardItem = BaseClass("SimpleAwardItem", UIBaseItem)
local base = UIBaseItem

function SimpleAwardItem:__init()
    self.m_itemIcon = UIUtil.AddComponent(UIImage, self, "itemIcon", AtlasConfig.DynamicLoad)
    
    self.m_itemCountText = UIUtil.GetChildTexts(self.transform, {"itemCountText"})
end

function SimpleAwardItem:OnDestroy()
    base.OnDestroy(self)

    if self.m_itemIcon then
        self.m_itemIcon:Delete()
        self.m_itemIcon = nil
    end
    self.m_itemCountText = nil
end

function SimpleAwardItem:UpdateData(award_id, count_str)
    local itemCfg = ConfigUtil.GetItemCfgByID(award_id)
    if not itemCfg then
        return
    end

    self.m_itemIcon:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
    self.m_itemCountText.text = count_str
end

return SimpleAwardItem