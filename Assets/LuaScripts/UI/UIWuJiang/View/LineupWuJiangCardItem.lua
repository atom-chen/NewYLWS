local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local base = UIWuJiangCardItem
local Vector3 = Vector3

local LineupWuJiangCardItem = BaseClass("LineupWuJiangCardItem", UIWuJiangCardItem)

function LineupWuJiangCardItem:OnCreate()
    base.OnCreate(self)
    self.m_isHide = false

    self.transform.localScale = Vector3.New(0.96, 0.94, 1)
    self:HideName()
end

function LineupWuJiangCardItem:SetData(wujiangBriefData, showWinTime)
    showWinTime = showWinTime or false
    base.SetData(self, wujiangBriefData, false, false, nil, false, false, showWinTime)

    self:ShowAll()
end

function LineupWuJiangCardItem:HideAll()
    self.m_other:SetActive(false)
    self.m_iconGo:SetActive(false)
    self.m_frameGo:SetActive(false)
    self.m_isHide = true
end

function LineupWuJiangCardItem:ShowAll()
    self.m_other:SetActive(true)
    self.m_iconGo:SetActive(true)
    self.m_frameGo:SetActive(true)
    self.m_isHide = false
end

function LineupWuJiangCardItem:OnClick(go, x, y)
    if go == self.m_frameImage.gameObject then
        -- print("LineupWuJiangCardItem:OnClick")
        UIManagerInst:Broadcast(UIMessageNames.MN_LINEUP_ITEM_SELECT, self.transform:GetSiblingIndex() + 1)
    end
end

function LineupWuJiangCardItem:IsHide()
    return self.m_isHide
end

function LineupWuJiangCardItem:OnDestroy()
    self:ShowAll()
    base.OnDestroy(self)
end

return LineupWuJiangCardItem

