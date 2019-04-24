

local UIWuJiangSkillDescItem = BaseClass("UIWuJiangSkillDescItem", UIBaseItem)
local base = UIBaseItem

function UIWuJiangSkillDescItem:OnCreate()
    self.m_descText = UIUtil.FindText(self.transform)
end

function UIWuJiangSkillDescItem:SetData(desc)
    
    if self.m_descText then
        self.m_descText.text = desc
    end
end

return UIWuJiangSkillDescItem