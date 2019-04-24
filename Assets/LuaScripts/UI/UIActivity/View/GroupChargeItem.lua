
local math_ceil = math.ceil
local math_floor = math.floor
local string_format = string.format
local table_insert = table.insert
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local Vector2 = Vector2
local CommonDefine = CommonDefine
local AtlasConfig = AtlasConfig
local GameUtility = CS.GameUtility
local UISliderHelper = typeof(CS.UISliderHelper)
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local ItemMgr = Player:GetInstance():GetItemMgr()
local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)

local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local ActMgr = Player:GetInstance():GetActMgr()

local GroupChargeItem = BaseClass("GroupChargeItem", UIBaseItem)
local base = UIBaseItem

function GroupChargeItem:OnCreate()
    base.OnCreate(self)
    local boxCond1, boxCond2, boxCond3, boxParentTr1, boxParentTr2, boxParentTr3,
    getTr1, getTr2, getTr3, redPoint1, redPoint2, redPoint3, boxImg1, boxImg2, boxImg3

    self.m_conditionText, self.m_descText, boxCond1, boxCond2, boxCond3 = UIUtil.GetChildTexts(self.transform, { 
        "Condition/Text",
        "Condition/Text2",
        "AwardItemPos1/CondText",
        "AwardItemPos2/CondText",
        "AwardItemPos3/CondText",
    })

    self.m_boxBtn1, self.m_boxBtn2, self.m_boxBtn3, self.m_boxTr1, self.m_boxTr2, self.m_boxTr3,
    getTr1, getTr2, getTr3, redPoint1, redPoint2, redPoint3, self.m_sliderTr
    = UIUtil.GetChildRectTrans(self.transform, {
        "AwardItemPos1",
        "AwardItemPos2",
        "AwardItemPos3",
        "AwardItemPos1/BoxImg1",
        "AwardItemPos2/BoxImg2",
        "AwardItemPos3/BoxImg3",
        "AwardItemPos1/GotImg",
        "AwardItemPos2/GotImg",
        "AwardItemPos3/GotImg",
        "AwardItemPos1/RedPoint",
        "AwardItemPos2/RedPoint",
        "AwardItemPos3/RedPoint",
        "ProgressSlider",
    })

    boxImg1 = UIUtil.AddComponent(UIImage, self, "AwardItemPos1/BoxImg1")
    boxImg2 = UIUtil.AddComponent(UIImage, self, "AwardItemPos2/BoxImg2")
    boxImg3 = UIUtil.AddComponent(UIImage, self, "AwardItemPos3/BoxImg3")
    self.m_slider = UIUtil.FindComponent(self.transform, UISliderHelper, "ProgressSlider")

    self.m_actId = 0
    self.m_boxCondText = {boxCond1, boxCond2, boxCond3}
    self.m_boxParentTrList = {self.m_boxBtn1, self.m_boxBtn2, self.m_boxBtn3}
    self.m_getGoList = {getTr1.gameObject, getTr2.gameObject, getTr3.gameObject}
    self.m_redPointGoList = {redPoint1.gameObject, redPoint2.gameObject, redPoint3.gameObject}
    self.m_boxImgList = {boxImg1, boxImg2, boxImg3}
    self.m_boxBtnList = {self.m_boxTr1, self.m_boxTr2, self.m_boxTr3}
    self.m_boxIndexList = {}
    self.m_boxAwardList = {}
    self.m_boxStatusList = {}
    self.m_boxTweenList = {}
    self.m_boxItemList = {}
    self.m_seq = 0


    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_boxBtn1.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxBtn2.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxBtn3.gameObject, onClick)
end

function GroupChargeItem:OnClick(go)
    if go.name == "AwardItemPos1" then
        self:HandleBoxClick(1)
    elseif go.name == "AwardItemPos2" then
        self:HandleBoxClick(2)
    elseif go.name == "AwardItemPos3" then
        self:HandleBoxClick(3)
    end
end

function GroupChargeItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_boxBtn1.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxBtn2.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxBtn3.gameObject)

    for _, tweenner in pairs(self.m_boxTweenList) do
        if tweenner then
            UIUtil.KillTween(tweenner)
        end
    end

    self.m_boxIndexList = {}
    self.m_boxAwardList = {}
    self.m_boxStatusList = {}
    self.m_boxIndexList = {}

    base.OnDestroy(self)
end

function GroupChargeItem:UpdateData(entry, actId, textList)
    if not entry then
        return
    end

    self.m_boxIndexList = {}
    self.m_boxAwardList = {}
    self.m_boxStatusList = {}
    self.m_conditionText.text = textList[1]
    self.m_descText.text = string_format(textList[2], entry.total_count)
    self.m_actId = actId or 0
    local maxCond = 0
    for i, v in ipairs(entry.box_list) do
        if v.cond > maxCond then
            maxCond = v.cond
        end
    end
    self.m_slider:UpdateSliderImmediately(entry.total_count/maxCond)
    local sliderPos = self.m_sliderTr.anchoredPosition
    local width = self.m_sliderTr.sizeDelta.x
    for i, v in ipairs(entry.box_list) do
        table_insert(self.m_boxIndexList, v.box_index)
        table_insert(self.m_boxAwardList, v.award_list)
        table_insert(self.m_boxStatusList, v.status)
        self.m_boxCondText[i].text = math_ceil(v.cond)
        self.m_boxParentTrList[i].anchoredPosition = Vector2.New(sliderPos.x + (v.cond/maxCond) * width, sliderPos.y)
        self:HandleBoxRedPoint(v.status, self.m_redPointGoList[i], self.m_boxImgList[i], i, self.m_boxBtnList[i], self.m_getGoList[i])
    end

end

function GroupChargeItem:HandleBoxRedPoint(status, redPointGo, image, i, roteTrans, GetGo)
    if status == CommonDefine.ACT_BTN_STATUS_UNREACH then -- 未达成，屏蔽红点
        redPointGo:SetActive(false)
        GetGo:SetActive(false)
        image:SetAtlasSprite("zhuxian18.png", false, AtlasConfig.DynamicLoad)

        UIUtil.KillTween(self.m_boxTweenList[i])

    elseif status == CommonDefine.ACT_BTN_STATUS_REACH then -- 以达成未领取 开启红点
        redPointGo:SetActive(true)
        GetGo:SetActive(false)
        image:SetAtlasSprite("zhuxian18.png", false, AtlasConfig.DynamicLoad)

        UIUtil.KillTween(self.m_boxTweenList[i])
        local lastTweener = self.m_boxTweenList[i]
        local sequence = UIUtil.TweenRotateToShake(roteTrans, lastTweener, RotateStart, RotateEnd)
        self.m_boxTweenList[i] = sequence

    elseif status == CommonDefine.ACT_BTN_STATUS_TAKEN then -- 已领取 更换图片，屏蔽红点
        redPointGo:SetActive(false)
        GetGo:SetActive(true)
        image:SetAtlasSprite("zhuxian17.png", false, AtlasConfig.DynamicLoad)

        UIUtil.KillTween(self.m_boxTweenList[i])

    end
end

function GroupChargeItem:HandleBoxClick(index)
    if self.m_boxStatusList[index] == CommonDefine.ACT_BTN_STATUS_REACH then
        ActMgr:ReqTakeGroupChargeAward(self.m_actId, self.m_boxIndexList[index])
    else
        UIManagerInst:OpenWindow(UIWindowNames.UIAwardTips, self.m_boxAwardList[index])
    end
end

return GroupChargeItem