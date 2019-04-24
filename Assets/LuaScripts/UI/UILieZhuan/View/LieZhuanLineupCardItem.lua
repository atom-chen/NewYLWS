local LineupWuJiangCardItem = require "UI.UIWuJiang.View.LineupWuJiangCardItem"
local base = LineupWuJiangCardItem
local Vector3 = Vector3

local LieZhuanLineupCardItem = BaseClass("LieZhuanLineupCardItem", LineupWuJiangCardItem)

function LieZhuanLineupCardItem:OnCreate()
    base.OnCreate(self)

    self.m_lieZhuanStartList, self.m_lieZhuanLevel = UIUtil.GetChildTransforms(self.transform, {
        "Other/startList",
        "Other/Level",
    })

    self.m_lieZhuanIconImage = UIUtil.AddComponent(UIImage, self, "icon", AtlasConfig.DynamicLoad)
end

function LieZhuanLineupCardItem:OnClick(go, x, y)
    if go == self.m_frameImage.gameObject and not self.m_bSelect then
        UIManagerInst:Broadcast(UIMessageNames.MN_LINEUP_ITEM_SELECT, self.transform:GetSiblingIndex() + 1)
    end
end

function LieZhuanLineupCardItem:SetData(wujiangBriefData, showWinTime)
    base.SetData(self, wujiangBriefData, showWinTime)
    local isShow = wujiangBriefData.id ~= 0
    
    if not isShow then
        self.m_frameImage:SetAtlasSprite("realempty.tga")
        self.m_lieZhuanIconImage:SetAtlasSprite("realempty.tga")
    end

    self.m_lieZhuanStartList.gameObject:SetActive(isShow)
    self.m_lieZhuanLevel.gameObject:SetActive(isShow)
    self.m_countryImage.gameObject:SetActive(isShow)
end

function LieZhuanLineupCardItem:OnDestroy()
    self:ShowAll()
    if self.m_lieZhuanIconImage then
        self.m_lieZhuanIconImage:Delete()
        self.m_lieZhuanIconImage = nil  
    end
    self.m_lieZhuanStartList = nil
    self.m_lieZhuanLevel = nil
    base.OnDestroy(self)
end

return LieZhuanLineupCardItem

