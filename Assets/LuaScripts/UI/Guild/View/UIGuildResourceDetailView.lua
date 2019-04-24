local UIGuildResourceDetailView = BaseClass("UIGuildResourceDetailView", UIBaseView)
local base = UIBaseView
local UIUtil = UIUtil
local table_insert = table.insert
local UITipsHelper = require "UI.Common.UITipsHelper"
local CommonDefine = CommonDefine
local ConfigUtil = ConfigUtil
local UILogicUtil = UILogicUtil
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local Utils = Utils

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

function UIGuildResourceDetailView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIGuildResourceDetailView:InitView()

    self.m_tips = self:AddComponent(UITipsHelper, "ItemDetailContainer")
     
    self.m_itemCreatePos, self.m_backBtn, self.m_itemContainerTr = 
    UIUtil.GetChildRectTrans(self.transform, {
        "ItemDetailContainer/ItemCreatePos",
        "backBtn",
        "ItemDetailContainer",
    })

    self.m_itemNameText, self.m_itemDescText, self.m_attrText = 
    UIUtil.GetChildTexts(self.transform, {
        "ItemDetailContainer/ItemNameText",
        "ItemDetailContainer/ItemDescText",
        "ItemDetailContainer/ItemAttrText",
    })

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    self.m_itemDetailTmpItem = nil 
    self.m_itemID = 0   
end

function UIGuildResourceDetailView:OnEnable(...)
    base.OnEnable(self)
    local order 
    order, itemID = ...

    if not itemID then
        return
    end

    self.m_itemID = itemID

    self:UpdateItemDetailContainer()
    if self.m_tips then
        self.m_tips:Init(Vector2.New(260, -30))
    end
end


function UIGuildResourceDetailView:UpdateItemDetailContainer()

    if self.m_itemDetailTmpItem then
        self.m_itemDetailTmpItem:Delete()
        self.m_itemDetailTmpItem = nil
    end

    --显示物品图标
    self.m_bagItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoaderInstance:GetGameObject(self.m_bagItemSeq, CommonAwardItemPrefab, function(go)
        self.m_bagItemSeq = 0
        if not go then
            return
        end
        
        self.m_itemDetailTmpItem = CommonAwardItem.New(go, self.m_itemCreatePos, CommonAwardItemPrefab)
        local iconParam = AwardIconParamClass.New(self.m_itemID, 1)
        self.m_itemDetailTmpItem:UpdateData(iconParam)
    end)
    
    --更新物品信息
    
    local itemCfg = ConfigUtil.GetItemCfgByID(self.m_itemID)
    if itemCfg then
        local itemMainType = itemCfg.sMainType
        if itemMainType == CommonDefine.ItemMainType_ShenBing then
            local shenbingCfg = ConfigUtil.GetShenbingCfgByID(self.m_itemID)
            if shenbingCfg then
                self.m_itemNameText.text = UILogicUtil.GetShenBingNameByStage(iconParam.level, shenbingCfg)
            end
        else
            self.m_itemNameText.text = itemCfg.sName
        end

        self.m_itemDescText.text = itemCfg.sTips

        if itemMainType == CommonDefine.ItemMainType_MingQian then
            local stage  = UILogicUtil.GetInscriptionStage(self.m_itemID)
            local color = CommonDefine.colorList[stage]
            self.m_attrText.text = string.format(Language.GetString(689), color, UILogicUtil.GetInscriptionDesc(self.m_itemID)) 
        else
            self.m_attrText.text = ''
        end
    end

end

function UIGuildResourceDetailView:OnDisable()
    base.OnDisable(self)
    
    if self.m_bagItemSeq and self.m_bagItemSeq > 0 then
        UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    end
    self.m_bagItemSeq = 0
    
    if self.m_itemDetailTmpItem then
        self.m_itemDetailTmpItem:Delete()
        self.m_itemDetailTmpItem = nil
    end   
end

function UIGuildResourceDetailView:OnClick(go, x, y)
    self:CloseSelf()
end

function UIGuildResourceDetailView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    base.OnDestroy(self)
end

return UIGuildResourceDetailView