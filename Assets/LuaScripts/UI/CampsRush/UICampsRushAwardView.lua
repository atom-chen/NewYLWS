local CommonDefine = CommonDefine
local table_insert = table.insert

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab

local UICampsRushAwardView = BaseClass("UICampsRushAwardView", UIBaseView)
local base = UIBaseView

function UICampsRushAwardView:OnCreate()
    base.OnCreate(self)

    self.m_awardData = nil
    self.m_firstPassDropList = {}
    self.m_firstDropItemLoaderSeq = 0
    local awardText, tipsText
    awardText, tipsText, self.m_titleText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/awardBg/awardText",
        "BgRoot/tipsText",
        "BgRoot/titleText",
    })
    self.m_closeBtn, self.m_awardGrid = UIUtil.GetChildRectTrans(self.transform, {
        "CloseBtn",
        "BgRoot/awardBg/awardGrid"
    })

    awardText.text = Language.GetString(1216)
    tipsText.text = Language.GetString(1217)
end

function UICampsRushAwardView:OnDisable()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_firstDropItemLoaderSeq)
    self.m_firstDropItemLoaderSeq = 0

    for _, item in pairs(self.m_firstPassDropList) do
        item:Delete()
    end

    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)

    self.m_firstPassDropList = {}

    base.OnDisable(self)
end

function UICampsRushAwardView:OnEnable(...)
    base.OnEnable(self, ...)
    local _,awardData = ...
    self.m_awardData = awardData

    local floorID = Player:GetInstance():GetCampsRushMgr():GetCurPassFloor()
    self.m_titleText.text = string.format(Language.GetString(1215), floorID)

    if self.m_firstDropItemLoaderSeq == 0  then
        self.m_firstDropItemLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_firstDropItemLoaderSeq, CommonAwardItemPrefab, #self.m_awardData.award_list, function(objs)
            self.m_firstDropItemLoaderSeq = 0

            local CreateAwardParamFromAwardData = PBUtil.CreateAwardParamFromAwardData

            if objs then
                for i = 1, #objs do
                    local bagItem = CommonAwardItem.New(objs[i], self.m_awardGrid, CommonAwardItemPrefab)
                    bagItem:SetLocalScale(Vector3.New(0.86, 0.86, 1))

                    local itemIconParam = CreateAwardParamFromAwardData(self.m_awardData.award_list[i])
                    bagItem:UpdateData(itemIconParam)

                    table_insert(self.m_firstPassDropList, bagItem)
                end
            end
        end)
    end

    self:HandleClick()
end

function UICampsRushAwardView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)

    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UICampsRushAwardView:OnClick(go, x, y)
    UIManagerInst:CloseWindow(UIWindowNames.UICampsRushAward)
    UIManagerInst:Broadcast(UIMessageNames.MN_CAMPSRUSH_INFO_CHG)
end

return UICampsRushAwardView