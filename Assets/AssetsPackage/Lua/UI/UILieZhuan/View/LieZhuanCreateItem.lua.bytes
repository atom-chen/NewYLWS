local LieZhuanCreateItem = BaseClass("LieZhuanCreateItem", UIBaseItem)
local base = UIBaseItem

function LieZhuanCreateItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function LieZhuanCreateItem:InitView()
    self.m_contentText = UIUtil.GetChildTexts(self.transform, { "contentText" })
end

function LieZhuanCreateItem:UpdateData(content_str)
    if self.m_contentText then
        self.m_contentText.text = content_str
    end
end

function LieZhuanCreateItem:OnDestroy()
    base.OnDestroy(self)
end

return LieZhuanCreateItem