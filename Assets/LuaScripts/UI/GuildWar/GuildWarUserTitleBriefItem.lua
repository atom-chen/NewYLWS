local base = UIBaseItem
local GuildWarUserTitleBriefItem = BaseClass("GuildWarUserTitleBriefItem", UIBaseItem)

local math_ceil = math.ceil

function GuildWarUserTitleBriefItem:OnCreate()
    base.OnCreate(self)

    self.m_userTitleIconImage = UIUtil.AddComponent(UIImage, self, "TitleIconImage", AtlasConfig.DynamicLoad)
    self.m_countText = UIUtil.FindText(self.transform, "")
    self.m_userTitle = 0
end

function GuildWarUserTitleBriefItem:UpdateData(user_title, count)
    self.m_userTitle = user_title
    local guildWarCraftDefTitleCfg = ConfigUtil.GetGuildWarCraftDefTitleCfgByID(user_title)
    if guildWarCraftDefTitleCfg then
        self.m_userTitleIconImage:SetAtlasSprite(guildWarCraftDefTitleCfg.icon..".png")
        self.m_countText.text = math_ceil(count)
    end
end

function GuildWarUserTitleBriefItem:OnDestroy()
    if self.m_userTitleIconImage then
        self.m_userTitleIconImage:Delete()
        self.m_userTitleIconImage = nil
    end

    base.OnDestroy(self)
end

function GuildWarUserTitleBriefItem:GetUserTitle()
    return self.m_userTitle
end

return GuildWarUserTitleBriefItem