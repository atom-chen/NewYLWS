local UIItemDetailView = BaseClass("UIItemDetailView", UIBaseView)
local base = UIBaseView
local UIUtil = UIUtil
local table_insert = table.insert
local UITipsHelper = require "UI.Common.UITipsHelper"
local CommonDefine = CommonDefine
local UIBagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local UIBagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local ItemMgr = Player:GetInstance():GetItemMgr()

function UIItemDetailView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIItemDetailView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    base.OnDestroy(self)
end

function UIItemDetailView:InitView()

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
    self.m_currSelectItem = nil      
end

function UIItemDetailView:OnEnable(...)
    base.OnEnable(self, ...)

    local order 
    order, self.m_currSelectItem = ...
   
    if self.m_currSelectItem then
        local posZ = self.m_currSelectItem:GetItemDetailPosZ()
        local pos = self.transform.localPosition
        if posZ ~= 0 then
            pos.z = posZ
        else
            pos.z = 0  --reset
        end
        self.transform.localPosition = pos

    end

    self:ChgItemDetailShowState(true)

    if self.m_tips then
        self.m_tips:Init(Vector2.New(-260, -30))
    end
end

function UIItemDetailView:UpdateData()
end

function UIItemDetailView:ChgItemDetailShowState(isShow)
    if isShow then
        self:UpdateItemDetailContainer()
    else
        if self.m_currSelectItem then
            self.m_currSelectItem:SetOnSelectState(false)
            self.m_currSelectItem = nil
        end
    end
end

function UIItemDetailView:UpdateItemDetailContainer()
    if not self.m_currSelectItem  then
        self:ChgItemDetailShowState(false)
        return
    end
    local itemCfg = self.m_currSelectItem:GetItemCfg()
    local itemCount = self.m_currSelectItem:GetItemCount()
    local stage = self.m_currSelectItem:GetStage()
    local index = self.m_currSelectItem:GetIndex()
    if not itemCfg then
        return
    end

    --显示物品图标
    if not self.m_itemDetailTmpItem then
        self.m_bagItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObject(self.m_bagItemSeq, UIBagItemPrefabPath, function(go)
            self.m_bagItemSeq = 0
            if not go then
                return
            end
            
            self.m_itemDetailTmpItem = UIBagItem.New(go, self.m_itemCreatePos)
            local itemIconParam = ItemIconParam.New(itemCfg, itemCount, stage, index)
            self.m_itemDetailTmpItem:UpdateData(itemIconParam)
        end)
    else
        local itemIconParam = ItemIconParam.New(itemCfg, itemCount, stage, index)
        self.m_itemDetailTmpItem:UpdateData(itemIconParam)
    end
    --更新物品信息
    self.m_itemNameText.text = itemCfg.sName
    self.m_itemDescText.text = itemCfg.sTips
    -- self.m_currNumText.text = string.format("%.d",itemCount)
    local stage  = UILogicUtil.GetInscriptionStage(itemCfg.id)
    local color = CommonDefine.colorList[stage]
    self.m_attrText.text = string.format(Language.GetString(689), color, UILogicUtil.GetInscriptionDesc(itemCfg.id)) 
end

function UIItemDetailView:OnDisable()
    
    
    self:ChgItemDetailShowState(false)

    if self.m_bagItemSeq and self.m_bagItemSeq > 0 then
        UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    end
    
    self.m_bagItemSeq = 0

    if self.m_itemDetailTmpItem then
        self.m_itemDetailTmpItem:Delete()
        self.m_itemDetailTmpItem = nil
    end

    self.m_currSelectItem = nil

    base.OnDisable(self)
end

function UIItemDetailView:OnClick(go, x, y)
    self:CloseSelf()
end

return UIItemDetailView