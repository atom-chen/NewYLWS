
local table_insert = table.insert
local Vector2 = Vector2
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local GameUtility = CS.GameUtility
local UITipsHelper = require "UI.Common.UITipsHelper"

local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local UIAwardTipsView = BaseClass("UIAwardTipsView", UIBaseView)
local base = UIBaseView

function UIAwardTipsView:OnCreate()
    base.OnCreate(self)

    self.m_closeBtn, self.m_bgTr, self.m_contentTr = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
        "bg",
        "bg/awardScrollView/Viewport/Content",
    })

    self.m_tips = self:AddComponent(UITipsHelper, "bg")
    self.m_awardItemList = {}
    self.m_seq = 0

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIAwardTipsView:OnClick(go)
    if go.name == "closeBtn" then
        self:CloseSelf()
    end
end

function UIAwardTipsView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, awardList  = ...

    if self.m_tips then
        self.m_tips:Init(Vector2.New(0, 40))
    end
    
    if not awardList then
        return
    end

    if #self.m_awardItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, CommonAwardItemPrefab, #awardList, function(objs)
            self.m_seq = 0
            
            if objs then
                for i = 1, #objs do
                    local awardItem = CommonAwardItem.New(objs[i], self.m_contentTr, CommonAwardItemPrefab)
                    awardItem:SetLocalScale(Vector3.one * 0.8)
                    table_insert(self.m_awardItemList, awardItem)
                    
                    local awardIconParam = PBUtil.CreateAwardParamFromAwardData(awardList[i])
                    awardItem:UpdateData(awardIconParam)
                end
            end
        end)
    else
        for i, v in ipairs(self.m_awardItemList) do
            local awardIconParam = PBUtil.CreateAwardParamFromAwardData(awardList[i])
            v:UpdateData(awardIconParam)
        end
    end

    self.m_bgTr.sizeDelta = Vector2.New(#awardList * 135, self.m_bgTr.sizeDelta.y)

end

function UIAwardTipsView:OnDisable()
    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0

    if #self.m_awardItemList > 0 then
        for _,item in pairs(self.m_awardItemList) do
            item:Delete()
        end
    end
    self.m_awardItemList = {}
    base.OnDisable(self)
end

function UIAwardTipsView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

return UIAwardTipsView