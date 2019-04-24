
local string_format = string.format
local math_ceil = math.ceil
local Language = Language
local UIUtil = UIUtil
local AtlasConfig = AtlasConfig
local ShenBingMgr = Player:GetInstance():GetShenBingMgr()
local bagItemPath = TheGameIds.CommonBagItemPrefab
local bagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local DOTweenShortcut = CS.DOTween.DOTweenShortcut

local UIShenBingStageUpView = BaseClass("UIShenBingStageUpView", UIBaseView)
local base = UIBaseView

function UIShenBingStageUpView:OnCreate()
    base.OnCreate(self)

    local titleText, AttrOneText, AttrTwoText, AttrThreeText, UpAttrOneText, UpAttrTwoText, UpAttrThreeText
    titleText, self.m_InfoText, self.m_stageText,
    self.m_newMingwenText, self.m_mingwenNameText, 
    AttrOneText, AttrTwoText, AttrThreeText, UpAttrOneText, UpAttrTwoText, UpAttrThreeText = UIUtil.GetChildTexts(self.transform, {
        "bgRoot/titleImg/titleText",
        "bgRoot/contentRoot/InfoText",
        "bgRoot/contentRoot/InfoText/StageText",
        "bgRoot/contentRoot/mingwenName/NewMingwenText",
        "bgRoot/contentRoot/mingwenName/mingwenNameText",
        "bgRoot/contentRoot/AttrGrid/AttributeTextOne",
        "bgRoot/contentRoot/AttrGrid/AttributeTextTwo",
        "bgRoot/contentRoot/AttrGrid/AttributeTextThree",
        "bgRoot/contentRoot/UpTextGrid/UpTextOne",
        "bgRoot/contentRoot/UpTextGrid/UpTextTwo",
        "bgRoot/contentRoot/UpTextGrid/UpTextThree",
    })

    self.m_attrTextList = { AttrOneText, AttrTwoText, AttrThreeText }
    self.m_attrUpTextList = {UpAttrOneText, UpAttrTwoText, UpAttrThreeText}

    self.m_closeBtn, self.m_newMingwenGo,self.m_curShenBingInfoTr, self.m_backBtn = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn",
        "bgRoot/contentRoot/mingwenName",
        "bgRoot/contentRoot/ShenBingItem",
        "backBtn"
    })
    self.m_closeBtn = self.m_closeBtn.gameObject
    self.m_backBtn = self.m_backBtn.gameObject
    self.m_newMingwenGo = self.m_newMingwenGo.gameObject
    titleText.text = Language.GetString(2918)
    self.m_newMingwenText.text = Language.GetString(2919)

    self.m_shenbingData = false
    self.m_curShenBingInfoItem = false
    self.m_infoSeq = 0
        

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn, onClick)
    UIUtil.AddClickEvent(self.m_backBtn, onClick)

    self.m_attrTextList = {AttrOneText, AttrTwoText, AttrThreeText}
end

function UIShenBingStageUpView:OnClick(go)
    self:CloseSelf()
end

function UIShenBingStageUpView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn)
    UIUtil.RemoveClickEvent(self.m_backBtn)
    base.OnDestroy(self)
end

function UIShenBingStageUpView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, shenbingIndex = ...

    self.m_isOpen = true

    if shenbingIndex then
        self.m_shenbingData = ShenBingMgr:GetShenBingDataByIndex(shenbingIndex)
    end

    if self.m_shenbingData then
        local data = self.m_shenbingData
        local shenbingCfgList = ConfigUtil.GetShenbingCfgList()

        local itemCfg = ConfigUtil.GetItemCfgByID(data.m_id)
        local stage = self:GetStageByLevel(data.m_stage)
        if not self.m_curShenBingInfoItem and self.m_infoSeq == 0 then
            self.m_infoSeq = UIGameObjectLoader:PrepareOneSeq()
            UIGameObjectLoader:GetGameObject(self.m_infoSeq, bagItemPath, function(go)
                self.m_infoSeq = 0
                if not IsNull(go) then
                    self.m_curShenBingInfoItem = bagItem.New(go, self.m_curShenBingInfoTr, bagItemPath)
                    self.m_curShenBingInfoItem:SetAsFirstSibling()
                    self.m_curShenBingInfoItem:SetAnchoredPosition(Vector3.zero)
                    local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, data.m_index, nil, false, false, false,
                    false, false, data.m_stage, data.m_equiped_wujiang_index == self.m_wujiangIndex)
                    self.m_curShenBingInfoItem:UpdateData(itemIconParam)
                end
            end)
        else
            local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, data.m_index, nil, false, false, false,
            false, false, data.m_stage, data.m_equiped_wujiang_index == self.m_wujiangIndex)
            self.m_curShenBingInfoItem:UpdateData(itemIconParam)
        end

        if shenbingCfgList then
            for i, v in pairs(shenbingCfgList) do
                if v.id == data.m_id then
                    self.m_InfoText.text = UILogicUtil.GetShenBingNameByStage(data.m_stage, v)
                    self.m_stageText.text = string_format("+%d", data.m_stage)
                end
            end
        end

        local mingwenList = data.m_mingwen_list
        if mingwenList then
            if #mingwenList == 0 or data.m_stage % 5 ~= 0 then
                self.m_newMingwenGo:SetActive(false)
            else
                self.m_newMingwenGo:SetActive(true)

                --最后一个
                local theLastMingWen = mingwenList[#mingwenList]

                self.m_mingwenNameText.text = ''
                local mingwenCfg2 = ConfigUtil.GetShenbingInscriptionCfgByID(theLastMingWen.mingwen_id)
                if mingwenCfg2 then
                    local shenbingInscriptionCfgList = ConfigUtil.GetShenbingInscriptionCfgListByQuality(mingwenCfg2.quality)
                    if shenbingInscriptionCfgList and #shenbingInscriptionCfgList > 0 then

                        local count = 20
                        coroutine.start(function()
                            if self.m_isOpen then
                                --UIUtil.DoGraphicTweenAlpha(self.m_newMingwenText, 1, 0, 1, 0, 0)
                                local newMingwenTextTran = self.m_newMingwenText.transform
                                newMingwenTextTran.localScale = Vector3.one * 0.01
                                DOTweenShortcut.DOScale(newMingwenTextTran, Vector3.one, 0.4)

                                coroutine.waitforseconds(0.5)
                                while count > 0 do
                                    coroutine.waitforseconds(0.05)
                                    local index = math.random(1, #shenbingInscriptionCfgList)
                                    local mingwenCfg3 = shenbingInscriptionCfgList[index]
                                    self.m_mingwenNameText.text = self:GetMingwenNameColor(mingwenCfg3.quality, mingwenCfg3.name)
                                    count = count - 1
                                end
    
                                local mingwenCfg = ConfigUtil.GetShenbingInscriptionCfgByID(theLastMingWen.mingwen_id)
                                self.m_mingwenNameText.text = self:GetMingwenNameColor(mingwenCfg.quality, mingwenCfg.name)
                                UIUtil.OnceTweenScale(self.m_mingwenNameText.transform, Vector3.one, 1.5)
                            end
                        end)
                    end
                end
            end
        end

      
        local shenbingCfg = ConfigUtil.GetShenbingCfgByID(data.m_id)
        if not shenbingCfg then
            return
        end

       
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(shenbingCfg.wujiang_id)
        if not wujiangCfg then
            return
        end

       

        local shenbingImproveCfg = ConfigUtil.GetShenbingImproverCfgByID(wujiangCfg.nTypeJob * 100 + data.m_stage)
        if not shenbingImproveCfg then
            return
        end

        local preShenBingImproveCfg = ConfigUtil.GetShenbingImproverCfgByID(wujiangCfg.nTypeJob * 100 + data.m_stage - 1)
        if not preShenBingImproveCfg then
            return
        end

       
        
        local attrList = data.m_attr_list
        if attrList then
            local index = 1
            local attrNameList = CommonDefine.mingwen_second_attr_name_list
            for i, v in ipairs(attrNameList) do
                local attrVal = attrList[v]
                if attrVal and attrVal > 0 then
                    local val = preShenBingImproveCfg[v]
                    if val and val > 0 then
                        local attrType = CommonDefine[v]
                        if attrType then
                            if index <= #self.m_attrTextList then
                                self.m_attrTextList[index].text = Language.GetString(attrType + 10)..string_format("<color=#17f100>+%d</color>", val)
                                index = index + 1
                            end
                        end
                    end
                end
            end
        end

        if attrList then
            local index = 1
            local attrNameList = CommonDefine.mingwen_second_attr_name_list
            for i, v in ipairs(attrNameList) do
                local val = attrList[v]
                if val and val > 0 then
                    local val2 = shenbingImproveCfg[v]
                    if val2 then
                        self.m_attrUpTextList[index].text = string_format("<color=#feb500>+%d</color>", val2)
                        index = index + 1
                    end
                end
            end
        end
    end
end

function UIShenBingStageUpView:GetStageByLevel(level)
    local stage = 0
if level < 5 then
        stage = CommonDefine.ItemStageType_1
    elseif level >= 5 and level < 10 then
        stage = CommonDefine.ItemStageType_2
    elseif level >= 10 and level < 15 then
        stage = CommonDefine.ItemStageType_3
    elseif level == 15 then
        stage = CommonDefine.ItemStageType_4
    end
    return stage
end

function UIShenBingStageUpView:GetMingwenNameColor(quality, name)
    if quality == CommonDefine.SHENBING_MINGWEN_QUALITY_1 then
        return string_format(Language.GetString(2932), name)
    elseif quality == CommonDefine.SHENBING_MINGWEN_QUALITY_2 then
        return string_format(Language.GetString(2933), name)
    elseif quality == CommonDefine.SHENBING_MINGWEN_QUALITY_3 then
        return string_format(Language.GetString(2934), name)
    else
        return ''
    end
end

function UIShenBingStageUpView:OnDisable()
    self.m_shenbingData = false

    UIGameObjectLoader:CancelLoad(self.m_infoSeq)
    self.m_infoSeq = 0
    self.m_curShenBingInfoItem:Delete()
    self.m_curShenBingInfoItem = false

    self.m_isOpen = false

    base.OnDisable(self)
end

function UIShenBingStageUpView:OnTweenOpenComplete()

    base.OnTweenOpenComplete(self)

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

return UIShenBingStageUpView