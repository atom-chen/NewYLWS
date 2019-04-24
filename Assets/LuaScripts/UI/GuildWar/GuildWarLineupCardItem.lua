
local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local GuildWarLineupCardItem = BaseClass("GuildWarLineupCardItem", UIWuJiangCardItem)

function GuildWarLineupCardItem:OnCreate()
    UIWuJiangCardItem.OnCreate(self)

    self.m_lineupNameText = UIUtil.GetChildTexts(self.transform, {
        "Other/LineupNameText",
    })

    self.m_lineupNameText.text = ''
end

function GuildWarLineupCardItem:SetZhenRongName(name)
    if self.m_lineupNameText then
        self.m_lineupNameText.text = name
    end
end

function GuildWarLineupCardItem:OnDestroy()
    self.m_lineupNameText.text = ''
    self.m_lineupNameText = nil

    UIWuJiangCardItem.OnDestroy(self)
end

return GuildWarLineupCardItem