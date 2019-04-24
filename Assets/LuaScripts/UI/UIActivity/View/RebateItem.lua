
local math_ceil = math.ceil
local math_floor = math.floor
local string_format = string.format
local table_insert = table.insert
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local GameUtility = CS.GameUtility
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local ItemMgr = Player:GetInstance():GetItemMgr()

local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local ActMgr = Player:GetInstance():GetActMgr()
local AtlasConfig = AtlasConfig

local RebateItem = BaseClass("RebateItem", UIBaseItem)
local base = UIBaseItem

function RebateItem:OnCreate()
    base.OnCreate(self)

    self.m_conditionText, self.m_descText, self.m_btnText, self.m_rebateText = UIUtil.GetChildTexts(self.transform, { 
        "Condition/Text",
        "Desc",
        "Button/Text",
        "RebateImg/Text",
    })

    self.m_useImgTr, self.m_getBtnTr, self.m_descTr, self.m_rebateBgTr = UIUtil.GetChildTransforms(self.transform, {
        "UseImg",
        "Button",
        "Desc",
        "RebateImg/Bg"
    })

    self.m_btnImg = UIUtil.AddComponent(UIImage, self, "Button")
    self.m_rebateImg = UIUtil.AddComponent(UIImage, self, "RebateImg")

    self.m_useImgGo = self.m_useImgTr.gameObject
    self.m_getBtnGo = self.m_getBtnTr.gameObject
    self.m_rebateBgGo = self.m_rebateBgTr.gameObject
    self.m_descGo = self.m_descTr.gameObject

    self.m_actId = 0
    self.m_tagIndex = 0
    self.m_btnStatus = -1

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_getBtnGo, onClick)
end

function RebateItem:OnClick(go)
    if go.name == "Button" then
        if self.m_btnStatus == CommonDefine.ACT_BTN_STATUS_CHARGE then
            UIManagerInst:OpenWindow(UIWindowNames.UIVipShop)
        elseif self.m_btnStatus == CommonDefine.ACT_BTN_STATUS_CAN_TRY then
            ActMgr:ReqGetRebate(self.m_actId, self.m_tagIndex)
        elseif self.m_btnStatus == CommonDefine.ACT_BTN_STATUS_GOTO_SHOP then
            UIManagerInst:OpenWindow(UIWindowNames.UIRebateShop, self.m_actId, self.m_tagIndex)
        end
    end
end

function RebateItem:UpdateData(tagList, actId, tagIndex)
    if not tagList then
        return
    end
    
    self.m_actId = actId or 0
    self.m_tagIndex = tagIndex or 0
    self.m_btnStatus = tagList.btn_status or -1
    self.m_conditionText.text = tagList.tag_name
    self.m_descText.text = tagList.progress

    if tagList.param1 == tagList.param2 then
        self.m_rebateBgGo:SetActive(true)
        self.m_rebateText.text = math_ceil(tagList.param1)
        self.m_rebateImg:SetAtlasSprite("huodong19.png", false, AtlasConfig.DynamicLoad)
    elseif tagList.param1 < tagList.param2 then
        self.m_rebateBgGo:SetActive(false)
        self.m_rebateText.text = string_format(Language.GetString(3453), tagList.param1, tagList.param2)
        self.m_rebateImg:SetAtlasSprite("huodong20.png", false, AtlasConfig.DynamicLoad)
    end
    
    self.m_useImgGo:SetActive(false)
    self.m_getBtnGo:SetActive(false)
    self.m_descGo:SetActive(false)
    self.m_btnText.text = ""
    if tagList.btn_status == CommonDefine.ACT_BTN_STATUS_CHARGE then
        self.m_btnText.text = Language.GetString(3449)
        self.m_getBtnGo:SetActive(true)
        self.m_descGo:SetActive(true)
    elseif tagList.btn_status ==  CommonDefine.ACT_BTN_STATUS_CAN_TRY then
        self.m_btnText.text = Language.GetString(3451)
        self.m_getBtnGo:SetActive(true)
        self.m_descGo:SetActive(true)
    elseif tagList.btn_status ==  CommonDefine.ACT_BTN_STATUS_GOTO_SHOP then
        self.m_btnText.text = Language.GetString(3452)
        self.m_getBtnGo:SetActive(true)
        self.m_descGo:SetActive(true)
    elseif tagList.btn_status ==  CommonDefine.ACT_BTN_STATUS_USED then
        self.m_useImgGo:SetActive(true)
    end

end

function RebateItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_getBtnGo)

    
    base.OnDestroy(self)
end

return RebateItem