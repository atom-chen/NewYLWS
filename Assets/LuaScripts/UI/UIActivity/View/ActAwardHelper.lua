local string_format = string.format
local table_insert = table.insert
local math_ceil = math.ceil
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local CommonDefine = CommonDefine
local TimeUtil = TimeUtil
local ImageConfig = ImageConfig
local Type_ScrollRect = typeof(CS.UnityEngine.UI.ScrollRect)
local GameObject = CS.UnityEngine.GameObject
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local ActMgr = Player:GetInstance():GetActMgr()

local ActAwardItemClass = require "UI.UIActivity.View.ActAwardItem"
local ActAwardItemPrefabPath = "UI/Prefabs/Activity/AwardItem.prefab"
local ActExchangeItemClass = require "UI.UIActivity.View.ActExchangeItem"
local ActExchangeItemPrefabPath = "UI/Prefabs/Activity/ExchangeItem.prefab"
local GroupChargeItemClass = require "UI.UIActivity.View.GroupChargeItem"
local GroupChargeItemPrefabPath = "UI/Prefabs/Activity/GroupChargeItem.prefab"
local RebateItemClass = require "UI.UIActivity.View.RebateItem"
local RebateItemPrefabPath = "UI/Prefabs/Activity/RebateItem.prefab"


local ActAwardHelper = BaseClass("ActAwardHelper")

function ActAwardHelper:__init(actTr, actView)
    self.m_actView = actView

    local actTimeText, actDescText, gotoShopBtnText

    actTimeText, actDescText, self.m_actTimeText, self.m_actDescText, self.m_titleText,
    gotoShopBtnText = UIUtil.GetChildTexts(actTr, {
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/TimeBg/Text",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/DescBg/Text",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/TimeArea/Text",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/Desc/Text",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/Title/Text",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/Title/GotoShopBtn/Text",
    })

    self.m_actDefaultTr, self.m_gridTr, self.m_gotoShopBtn = UIUtil.GetChildTransforms(actTr, {
        "Container/Act/bg/RightContainer/ActDefault",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/AwardGrid",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/Title/GotoShopBtn",
    })

    self.m_contentRect, self.m_descRect, self.m_gridRect =  UIUtil.GetChildRectTrans(actTr, {
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/Desc",
        "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/AwardGrid"
    })

    self.m_titleImg = self.m_actView:GetDetailTitleImg()
    self.m_scrollRect = UIUtil.FindComponent(actTr, Type_ScrollRect, "Container/Act/bg/RightContainer/ActDefault/ItemScrollView")
    
    self.m_actDefaultGo = self.m_actDefaultTr.gameObject
    actTimeText.text = Language.GetString(3461)
    actDescText.text = Language.GetString(3462)
    gotoShopBtnText.text = Language.GetString(3452)
    self.m_chargeTextList = {Language.GetString(3467), Language.GetString(3470)}
    self.m_v5TextList = {Language.GetString(3468), Language.GetString(3471)}
    self.m_v5ExtraTextList = {Language.GetString(3469), Language.GetString(3471)}
    
    self.m_awardItemList = {}
    self.m_seq = 0

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_gotoShopBtn.gameObject, onClick)
end

function ActAwardHelper:__delete()
    self.m_actView = nil
    UIUtil.RemoveClickEvent(self.m_gotoShopBtn.gameObject)
    self:Close()
end

function ActAwardHelper:OnClick(go)
    if go.name == "GotoShopBtn" then
        local oneAct = self.m_actView:GetOneAct()
        if not oneAct then
            return
        end
        UIManagerInst:OpenWindow(UIWindowNames.UIRebateShop, oneAct.act_id, 0)
    end
end

function ActAwardHelper:Close()
    self.m_actDefaultGo:SetActive(false)
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    for _, v in ipairs(self.m_awardItemList) do
        v:Delete()
    end
    self.m_awardItemList = {}
end

function ActAwardHelper:UpdateInfo(isReset)
    local oneAct = self.m_actView:GetOneAct()
    if not oneAct then
        return
    end

    if oneAct.act_type == CommonDefine.Act_Type_ZheKouShangCheng then
        self.m_gotoShopBtn.gameObject:SetActive(true)
    else
        self.m_gotoShopBtn.gameObject:SetActive(false)
    end

    if isReset then
        self.m_contentRect.localPosition = Vector2.zero
    end
    self.m_actDefaultGo:SetActive(true)
    if #oneAct.tag_list > 0 then
        self.m_scrollRect.vertical = true
        local ItemClass = ActAwardItemClass
        local ItemPrefabPath = ActAwardItemPrefabPath
        if oneAct.act_type == CommonDefine.Act_Type_Time_Count_Limit_Exchange or oneAct.act_type == CommonDefine.Act_Type_Item_Collection then
            ItemClass = ActExchangeItemClass
            ItemPrefabPath = ActExchangeItemPrefabPath
        elseif  oneAct.act_type == CommonDefine.Act_Type_ZheKouShangCheng then
            ItemClass = RebateItemClass
            ItemPrefabPath = RebateItemPrefabPath
        end
        if #self.m_awardItemList == 0 and self.m_seq == 0 then
            self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
            UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, ItemPrefabPath, #oneAct.tag_list, function(objs)
                self.m_seq = 0 
                if objs then
                    for i = 1, #objs do
                        local awardItem = ItemClass.New(objs[i], self.m_gridTr, ItemPrefabPath)
                        table_insert(self.m_awardItemList, awardItem)
                        awardItem:UpdateData(oneAct.tag_list[i], self.m_actView:GetCurActId(), i)
                    end
                end
            end)
        else
            for i, v in ipairs(self.m_awardItemList) do
                v:UpdateData(oneAct.tag_list[i], self.m_actView:GetCurActId(), i)
            end
        end
    else
        self.m_scrollRect.vertical = false
    end


    self.m_titleImg:SetAtlasSprite(oneAct.act_bg..".png", false, ImageConfig.Activity)
    self.m_titleText.text = oneAct.act_name
    if oneAct.end_time - oneAct.start_time < 24 * 3600 then
        self.m_actTimeText.text = string_format("%s", TimeUtil.ToYearMonthDayHourMinSec(oneAct.start_time, 69, true))
    else
        self.m_actTimeText.text = string_format(Language.GetString(3437), TimeUtil.ToYearMonthDayHourMinSec(oneAct.start_time, 69, true), TimeUtil.ToYearMonthDayHourMinSec(oneAct.end_time, 69, true))
    end
    self.m_actDescText.text = oneAct.act_content
    local contentSizeDelta = self.m_contentRect.sizeDelta
    local descSizeDelta = self.m_descRect.sizeDelta
    local gridSizeDelta = self.m_gridRect.sizeDelta

    self.m_contentRect.sizeDelta = Vector2.New(contentSizeDelta.x, 310 + descSizeDelta.y + gridSizeDelta.y)
end

function ActAwardHelper:UpdateGroupChargeData(groupChargeData, isReset)
    local oneAct = self.m_actView:GetOneAct()
    if not oneAct then
        return
    end

    if isReset then
        self.m_contentRect.localPosition = Vector2.zero
    end
    self.m_actDefaultGo:SetActive(true)
    self.m_titleImg:SetAtlasSprite(oneAct.act_bg..".png", false, ImageConfig.Activity)
    self.m_titleText.text = oneAct.act_name
    if oneAct.end_time - oneAct.start_time < 24 * 3600 then
        self.m_actTimeText.text = string_format("%s", TimeUtil.ToYearMonthDayHourMinSec(oneAct.start_time, 69, true))
    else
        self.m_actTimeText.text = string_format(Language.GetString(3437), TimeUtil.ToYearMonthDayHourMinSec(oneAct.start_time, 69, true), TimeUtil.ToYearMonthDayHourMinSec(oneAct.end_time, 69, true))
    end
    self.m_actDescText.text = oneAct.act_content
    local contentSizeDelta = self.m_contentRect.sizeDelta
    local descSizeDelta = self.m_descRect.sizeDelta
    local gridSizeDelta = self.m_gridRect.sizeDelta
    self.m_contentRect.sizeDelta = Vector2.New(contentSizeDelta.x, 310 + descSizeDelta.y + gridSizeDelta.y)

    if #self.m_awardItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, GroupChargeItemPrefabPath, 3, function(objs)
            self.m_seq = 0 
            if objs then
                for i = 1, #objs do
                    local item = GroupChargeItemClass.New(objs[i], self.m_gridTr, GroupChargeItemPrefabPath)
                    table_insert(self.m_awardItemList, item)
                    if i == 1 then
                        item:UpdateData(groupChargeData.charge_entry, self.m_actView:GetCurActId(), self.m_chargeTextList)
                    elseif i == 2 then
                        item:UpdateData(groupChargeData.vip5_entry, self.m_actView:GetCurActId(), self.m_v5TextList)
                    elseif i == 3 then
                        item:UpdateData(groupChargeData.vip5_extra_entry, self.m_actView:GetCurActId(), self.m_v5ExtraTextList)
                    end                        
                end
            end
        end)
    else
        for i, item in ipairs(self.m_awardItemList) do
            if i == 1 then
                item:UpdateData(groupChargeData.charge_entry, self.m_actView:GetCurActId(), self.m_chargeTextList)
            elseif i == 2 then
                item:UpdateData(groupChargeData.vip5_entry, self.m_actView:GetCurActId(), self.m_v5TextList)
            elseif i == 3 then
                item:UpdateData(groupChargeData.vip5_extra_entry, self.m_actView:GetCurActId(), self.m_v5ExtraTextList)
            end    
        end
    end
end


return ActAwardHelper