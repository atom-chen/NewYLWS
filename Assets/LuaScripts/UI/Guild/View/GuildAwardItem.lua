local math_ceil = math.ceil

local GuildAwardItem = BaseClass("GuildAwardItem", UIBaseItem)
local base = UIBaseItem

local ConfigUtil = ConfigUtil

function GuildAwardItem:OnCreate()
    self.m_iocnImage = UIUtil.AddComponent(UIImage, self, "Resouce2Image", AtlasConfig.DynamicLoad)
    self.m_itemCountText = UIUtil.GetChildTexts(self.transform, { "Resouce2CostCountText" })
end

function GuildAwardItem:UpdateData(itemID, itemCount)
    local itemCfg = ConfigUtil.GetItemCfgByID(itemID)
    if not itemCfg then
        return
    end

    self.m_itemCfg = itemCfg

    local icon = itemCfg.sIcon
    local atlasConfig = AtlasConfig[itemCfg.sAtlas]
    if icon and atlasConfig then
        self.m_iocnImage:SetAtlasSprite(icon, false, atlasConfig)
    end

    itemCount = itemCount or 0
    self.m_itemCountText.text = math_ceil(itemCount)
end


function GuildAwardItem:OnDestroy()
    if self.m_iocnImage then
        self.m_iocnImage:Delete()
        self.m_iocnImage = nil
    end

    base.OnDestroy(self)
end

return GuildAwardItem