
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local PBUtil = PBUtil
local Vector3 = Vector3
local table_insert = table.insert
local Language = Language
local CampsRushSweepItem = BaseClass("CampsRushSweepItem", UIBaseItem)
local base = UIBaseItem

function CampsRushSweepItem:OnCreate()
    base.OnCreate(self)

    self.m_loaderSeq = 0
    self.m_wujiangItemList = {}
    self.m_titleText = UIUtil.GetChildTexts(self.transform, {
        "titleText",
    })
    self.m_awardRoot = UIUtil.FindTrans(self.transform, "awardGrid")
end

function CampsRushSweepItem:OnDestroy()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_loaderSeq)
    self.m_loaderSeq = 0

    for _, item in pairs(self.m_wujiangItemList) do
        item:Delete()
    end
    self.m_wujiangItemList = {}

    base.OnDestroy(self)
end

function CampsRushSweepItem:SetData(sweepData)
    self.m_titleText.text = string.format(Language.GetString(1222), sweepData.floor)

    if #self.m_wujiangItemList == 0 and self.m_loaderSeq == 0  then
        self.m_loaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_loaderSeq, CommonAwardItemPrefab, #sweepData.awards, function(objs)
            self.m_loaderSeq = 0
            if objs then
                local CreateAwardParamFromAwardData = PBUtil.CreateAwardParamFromAwardData
                for i = 1, #objs do
                    local bagItem = CommonAwardItem.New(objs[i], self.m_awardRoot, CommonAwardItemPrefab)
                    bagItem:SetLocalScale(Vector3.New(0.6, 0.6, 1))

                    local itemIconParam = CreateAwardParamFromAwardData(sweepData.awards[i])
                    bagItem:UpdateData(itemIconParam)

                    table_insert(self.m_wujiangItemList, bagItem)
                end
            end
        end)
    end
end

return CampsRushSweepItem

