local table_insert = table.insert
local string_format = string.format
local math_ceil = math.ceil
local math_floor = math.floor
local GameObject = CS.UnityEngine.GameObject
local Language = Language
local UIUtil = UIUtil
local CommonDefine = CommonDefine
local ConfigUtil = ConfigUtil
local Vector3 = Vector3
local Vector3_Lerp = Vector3.Lerp
local mathf_lerp = Mathf.Lerp
local GameUtility = CS.GameUtility
local AtlasConfig = AtlasConfig
local ItemDefine = ItemDefine
local UISortOrderMgr = UISortOrderMgr
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local RecordItem = require "UI.UIActivity.View.RecordItem"
local RecordPrefab = "UI/Prefabs/Activity/RecordItem.prefab"
local ActMgr = Player:GetInstance():GetActMgr()

local UIActJiXingGaoZhaoView = BaseClass("UIActJiXingGaoZhaoView", UIBaseView)
local base = UIBaseView

local effectPath = "UI/Effect/Prefabs/ui_zhuanpan_kuang"

function UIActJiXingGaoZhaoView:OnCreate()
    base.OnCreate(self)

    self.m_actId = 0
    self.m_awardPosList = {}
    self.m_effectList = {}
    self.m_awardCircleList = {}
    self.m_specialAwardList = {}
    self.m_recordList = {}
    self.m_recordItemList = {}
    self.m_recordSeq = 0
    self.m_awardItemList = {}
    self.m_seq = 0
    self.m_specialName = ""
    
    self:InitView()
end

function UIActJiXingGaoZhaoView:InitView()
    local bounsText, onceBtnText, tenTimesBtnText, actTimeText, actRuleText, actRecordText

    bounsText, self.m_bounsText, onceBtnText, tenTimesBtnText, self.m_onceYuanBaoText, self.m_tenTimesYuanBaoText,
    actTimeText, self.m_actTimeText, actRuleText, self.m_actRuleText, actRecordText
    = UIUtil.GetChildTexts(self.transform, {
        "Panel/LeftPanel/bounsText",
        "Panel/LeftPanel/bonus/bg/Text",
        "Panel/LeftPanel/once_BTN/Text",
        "Panel/LeftPanel/tenTimes_BTN/Text",
        "Panel/LeftPanel/yuanbaoOnce/Text",
        "Panel/LeftPanel/yuanbaoTenTimes/Text",
        "Panel/LeftPanel/ActTime/Bg/Text",
        "Panel/LeftPanel/ActTime/TimeArea/Text",
        "Panel/LeftPanel/ActDesc/Bg/Text",
        "Panel/LeftPanel/ActDesc/Desc/Text",
        "Panel/LeftPanel/ActRecord/Bg/Text"
    })

    self.m_backBtn, self.m_awardPosTr, self.m_onceBtn, self.m_tenTimesBtn, self.m_contentTr,
    self.m_mask, self.m_specialAwardTr
    = UIUtil.GetChildTransforms(self.transform, {
        "BackBtn",
        "Panel/LeftPanel/awardPos",
        "Panel/LeftPanel/once_BTN",
        "Panel/LeftPanel/tenTimes_BTN",
        "Panel/LeftPanel/ActRecord/ScrollView/Viewport/Content",
        "Mask",
        "Panel/LeftPanel/specialAward",
    })

    bounsText.text = Language.GetString(3472)
    onceBtnText.text = Language.GetString(3473)
    tenTimesBtnText.text = Language.GetString(3474)
    actTimeText.text = Language.GetString(3461)
    actRuleText.text = Language.GetString(3462)
    actRecordText.text = Language.GetString(3475)
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)

    self.m_specialAwardPrefab = self.m_specialAwardTr.gameObject
    self.m_bounsImg = UIUtil.AddComponent(UIImage, self, "Panel/LeftPanel/bonus/Image")
    self.m_onceYuanbaoImg = UIUtil.AddComponent(UIImage, self, "Panel/LeftPanel/yuanbaoOnce/Image")
    self.m_tenTimesYuanbaoImg = UIUtil.AddComponent(UIImage, self, "Panel/LeftPanel/yuanbaoTenTimes/Image")

    self.m_loopScrollView = self:AddComponent(LoopScrowView, "Panel/LeftPanel/ActRecord/ScrollView/Viewport/Content", Bind(self, self.UpdateItem))

    for i = 0, self.m_awardPosTr.childCount - 1 do
        local pos = self.m_awardPosTr:GetChild(i)
        table_insert(self.m_awardPosList, pos)
    end

    self:HaldleClick()
end

function UIActJiXingGaoZhaoView:HaldleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_onceBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_tenTimesBtn.gameObject, onClick)
end

function UIActJiXingGaoZhaoView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_onceBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_tenTimesBtn.gameObject)
    
end

function UIActJiXingGaoZhaoView:OnClick(go)
    local goName = go.name
    if goName == "BackBtn" then
        self:CloseSelf()
    elseif goName == "once_BTN" then
        ActMgr:ReqJiXingGaoZhaoLottery(self.m_actId, 1)
    elseif goName == "tenTimes_BTN" then
        ActMgr:ReqJiXingGaoZhaoLottery(self.m_actId, 10)
    end
end

function UIActJiXingGaoZhaoView:RotateTable(pos, awardList)

    coroutine.start(function()
        self.m_mask.gameObject:SetActive(true)
        local waitTime = 0.04
        local endPos = pos + #self.m_awardPosList * 2
        local startPos = 0
        
        while startPos < endPos do
            waitTime = mathf_lerp(waitTime, 0.3, Time.deltaTime)
            self:SetCircleLight(startPos)
            startPos = startPos + 1
            coroutine.waitforseconds(waitTime)
        end
        coroutine.waitforseconds(0.5)
        local uiData = {
            openType = 1,
            awardDataList = awardList,
            btn2Callback = Bind(self, self.ReSetTurntableArrow)
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
        
        self.m_mask.gameObject:SetActive(false)
        ActMgr:ReqJiXingGaoZhaoPanel(self.m_actId)
    end)
end

function UIActJiXingGaoZhaoView:SetCircleLight(pos)
    pos = pos % #self.m_awardPosList
    for i, v in ipairs(self.m_awardCircleList) do
        if i == pos + 1 then
            v.gameObject:SetActive(true)
        else
            v.gameObject:SetActive(false)
        end
    end
end

function UIActJiXingGaoZhaoView:ReSetTurntableArrow()
    for i, v in ipairs(self.m_awardCircleList) do
        v.gameObject:SetActive(false)
    end
end

function UIActJiXingGaoZhaoView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_JIXINGGAOZHAO_INTERFACE, self.UpdateViewData)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_JIXINGGAOZHAO_LOTTERY, self.RotateTable)
end

function UIActJiXingGaoZhaoView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_JIXINGGAOZHAO_INTERFACE, self.UpdateViewData)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_JIXINGGAOZHAO_LOTTERY, self.RotateTable)
end

function UIActJiXingGaoZhaoView:OnEnable(...)
    base.OnEnable(self, ...)

    self.m_actId = 0
    local startTime, endTime, rule
    for i, v in ipairs(ActMgr.ActList) do
        if v.act_type == CommonDefine.Act_Type_JiXingGaoZhao then
            self.m_actId = v.act_id
            startTime = v.start_time
            endTime = v.end_time
            rule = v.act_content
            break
        end
    end
    if self.m_actId == 0 then
        return
    end

    if endTime - startTime < 24 * 3600 then
        self.m_actTimeText.text = string_format("%s", TimeUtil.ToYearMonthDayHourMinSec(startTime, 69, true))
    else
        self.m_actTimeText.text = string_format(Language.GetString(3437), TimeUtil.ToYearMonthDayHourMinSec(startTime, 69, true), TimeUtil.ToYearMonthDayHourMinSec(endTime, 69, true))
    end
    self.m_actRuleText.text = rule

    ActMgr:ReqJiXingGaoZhaoPanel(self.m_actId)
end

function UIActJiXingGaoZhaoView:UpdateItem(item, realIndex)
    if self.m_recordList then
        if item and realIndex > 0 and realIndex <= #self.m_recordList then
            local data = self.m_recordList[realIndex]
            item:UpdateData(data, self.m_specialName)
        end
    end
end

function UIActJiXingGaoZhaoView:UpdateViewData(data)
    if not data then
        return
    end
    
    if #self.m_awardItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, CommonAwardItemPrefab, #data.lottery_list, function(objs)
            self.m_seq = 0 
            if objs then
                for i = 1, #objs do
                    if data.lottery_list[i]:GetItemData() and data.lottery_list[i]:GetItemData():GetItemID() == ItemDefine.JiXingGaoZhao_ID then
                        local specilaAward = GameObject.Instantiate(self.m_specialAwardPrefab)
                        local trans = specilaAward.transform
                        trans:SetParent(self.m_awardPosList[i])
                        trans.localScale = Vector3.one
                        trans.localPosition = Vector3.zero
                        local text = UIUtil.GetChildTexts(trans, {"Text"})
                        text.text = string_format(Language.GetString(3476), data.lottery_list[i]:GetItemData():GetItemCount())
                        self.m_specialAwardList[i] = specilaAward
                    else
                        local awardItem = CommonAwardItem.New(objs[i], self.m_awardPosList[i], CommonAwardItemPrefab)
                        local awardIconParam = PBUtil.CreateAwardParamFromAwardData(data.lottery_list[i])
                        awardItem:UpdateData(awardIconParam)
                        self.m_awardItemList[i] = awardItem
                    end
                end
            end
        end)
    else
        for k, v in pairs(self.m_specialAwardList) do
            local trans = v.transform
            local text = UIUtil.GetChildTexts(trans, {"Text"})
            text.text = string_format(Language.GetString(3476), data.lottery_list[k]:GetItemData():GetItemCount())
        end
        for k, v in pairs(self.m_awardItemList) do
            local awardIconParam = PBUtil.CreateAwardParamFromAwardData(data.lottery_list[k])
            v:UpdateData(awardIconParam)
        end
    end

    self.m_onceYuanBaoText.text = math_ceil(data.once_price)
    self.m_tenTimesYuanBaoText.text = math_ceil(data.ten_times_price) 
    self.m_bounsText.text = math_ceil(data.bonus_count)
    local itemCfg = ConfigUtil.GetItemCfgByID(data.currency)
    if itemCfg then
        self.m_specialName = itemCfg.sName
        self.m_bounsImg:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
        self.m_onceYuanbaoImg:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
        self.m_tenTimesYuanbaoImg:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
    end

    self.m_recordList = data.record_list
    if #self.m_recordItemList == 0 and self.m_recordSeq == 0 then
        self.m_recordSeq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_recordSeq, RecordPrefab, 7, function(objs)
            self.m_recordSeq = 0 
            if objs then
                for i = 1, #objs do
                    local recordItem = RecordItem.New(objs[i], self.m_contentTr, RecordPrefab)
                    table_insert(self.m_recordItemList, recordItem)
                end
            end
            self.m_loopScrollView:UpdateView(true, self.m_recordItemList, data.record_list)
        end)
    else
        self.m_loopScrollView:UpdateView(false, self.m_recordItemList, data.record_list)
    end
    if #self.m_awardCircleList == 0 then
        self:CreateEffect()
    end
end

function UIActJiXingGaoZhaoView:CreateEffect()
    local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
    for i = 0, self.m_awardPosTr.childCount - 1 do
        self:AddComponent(UIEffect, "Panel/LeftPanel/awardPos/"..(i + 1), sortOrder, effectPath, function(effect)
            effect:SetLocalPosition(Vector3.zero)
            effect:SetLocalScale(Vector3.one)
            table_insert(self.m_awardCircleList, effect.transform:GetChild(1))
            table_insert(self.m_effectList, effect)
        end)
    end
    self:ReSetTurntableArrow()
end

function UIActJiXingGaoZhaoView:OnDisable()
    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0
    UIGameObjectLoaderInstance:CancelLoad(self.m_recordSeq)
    self.m_recordSeq = 0
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    
    for _, v in ipairs(self.m_effectList) do
        self:RemoveComponent(v:GetName(), UIEffect)
    end
    self.m_effectList = {}
    self.m_awardCircleList = {}
    for _, v in pairs(self.m_awardItemList) do
        v:Delete()
    end
    self.m_awardItemList = {}
    for _, v in ipairs(self.m_recordItemList) do
        v:Delete()
    end
    self.m_recordItemList = {}
    
    for _, v in pairs(self.m_specialAwardList) do
        GameObject.Destroy(v)
    end
    self.m_specialAwardList = {}


    self.m_mask.gameObject:SetActive(false)
    base.OnDisable(self)
end

function UIActJiXingGaoZhaoView:OnDestroy()
    self:RemoveClick()
    base.OnDestroy(self)
end

return UIActJiXingGaoZhaoView