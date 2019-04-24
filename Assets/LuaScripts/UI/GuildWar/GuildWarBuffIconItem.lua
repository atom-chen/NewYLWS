local ConfigUtil = ConfigUtil
local UIUtil = UIUtil

local GuildWarBuffIconItem = BaseClass("GuildWarBuffIconItem", UIBaseItem)
local base = UIBaseItem

function GuildWarBuffIconItem:OnCreate()
    base.OnCreate(self)

    self.m_buffIconImage = UIUtil.AddComponent(UIImage, self, "ItemIconSpt")
end

function GuildWarBuffIconItem:SetData(buffID)
    local guildWarCraftShopCfg = ConfigUtil.GetGuildWarCraftShopCfgByID(buffID)
    if guildWarCraftShopCfg then
       self.m_buffIconImage:SetAtlasSprite(guildWarCraftShopCfg.sIcon, false, ImageConfig.GuildWar)
    end
end

function GuildWarBuffIconItem:OnDestroy()
    if self.m_buffIconImage then
        self.m_buffIconImage:Delete()
        self.m_buffIconImage = nil
    end
    
    base.OnDestroy(self)
end

return GuildWarBuffIconItem
