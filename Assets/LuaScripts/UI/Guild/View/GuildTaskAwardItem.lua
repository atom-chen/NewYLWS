
local ItemDefine = ItemDefine

local GuildTaskAwardItem = BaseClass("GuildTaskAwardItem", UIBaseItem)
local base = UIBaseItem

function GuildTaskAwardItem:OnCreate()
    base.OnCreate(self)
    
    self.m_count = UIUtil.GetChildTexts(self.transform, {
        "awardCountText"
    })

    self.m_itemImg = UIUtil.AddComponent(UIImage, self, "")
end

function GuildTaskAwardItem:UpdateData(itemId, count)
    if itemId == ItemDefine.TongQian_ID then
        self.m_itemImg:SetAtlasSprite("10001.png", false, AtlasConfig.ItemIcon)
    elseif itemId == ItemDefine.YuanBao_ID then
        self.m_itemImg:SetAtlasSprite("10002.png", false, AtlasConfig.ItemIcon)
    elseif itemId == ItemDefine.GuildCoin_ID then
        --军团币图标还没出，随便用一个
        self.m_itemImg:SetAtlasSprite("10012.png", false, AtlasConfig.ItemIcon)
    end
    self.m_count.text = count
end


return GuildTaskAwardItem