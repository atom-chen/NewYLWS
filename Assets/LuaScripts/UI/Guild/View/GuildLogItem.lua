
local UIUtil = UIUtil

local GuildLogItem = BaseClass("GuildLogItem", UIBaseItem)
local base = UIBaseItem

function GuildLogItem:OnCreate()
    base.OnCreate(self)

    self.m_myText = UIUtil.FindText(self.transform, self)

end

function GuildLogItem:UpdateText(text)

    if self.m_myText.text == "" then
        self.m_myText.text = string.format("<color=#c7c2aa>%s</color>", text)
    else
        self.m_myText.text = self.m_myText.text.."\n"..text
    end

end

return GuildLogItem