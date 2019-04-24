local table_insert = table.insert
local math_ceil = math.ceil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local tostring = tostring

local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local UIWuJiangDevCardItem = BaseClass("UIWuJiangDevCardItem", UIBaseItem)
local base = UIBaseItem

local CardItemPath = TheGameIds.CommonWujiangCardPrefab

function UIWuJiangDevCardItem:OnCreate()

    self.m_frameGo, self.m_cardItemParent = UIUtil.GetChildTransforms(self.transform, {
        "lock/frame",
        "WujiangCardItemParent",
    })

    self.m_frameGo = self.m_frameGo.gameObject
   
    self.m_lockImage = UIUtil.AddComponent(UIImage, self, "lock", AtlasConfig.DynamicLoad)
    self.m_lockImage:SetAtlasSprite("peiyang40.png")

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_frameGo, onClick)

    self.WujiangIndex = 0
    self.m_cardItem = nil
    self.m_seq = 0
end

function UIWuJiangDevCardItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_frameGo)
    if self.m_cardItem then
        self.m_cardItem:Delete()
        self.m_cardItem = nil
    end

    if self.m_lockImage then
        self.m_lockImage:Delete()
        self.m_lockImage = nil
    end

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    self:Release()
    base.OnDestroy(self)
end

function UIWuJiangDevCardItem:SetData(wujiangBriefData)
    
    self.WujiangIndex = 0

    if wujiangBriefData == nil then
        if self.m_cardItem then
            self.m_cardItem:SetActive(false)
        end 

        return
    end

    self.WujiangIndex = wujiangBriefData.index

    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangBriefData.id)
    if not self.m_wujiangCfg then
        return
    end
    
    if self.m_cardItem == nil then
        if self.m_seq == 0 then
            self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq() 
            UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, CardItemPath, function(obj)
                self.m_seq = 0
                
                if not IsNull(obj) then
                    self.m_cardItem = UIWuJiangCardItem.New(obj, self.m_cardItemParent)
                    self.m_cardItem:SetLocalPosition(Vector3.New(0, -23.23, 0))
                    self.m_cardItem:SetData(wujiangBriefData)
                    self.m_cardItem:EnableRaycast(false)
                    self.m_cardItem:SetNameActive(false)
                end
            end)
        end
    else
        self.m_cardItem:SetActive(true)
        self.m_cardItem:SetData(wujiangBriefData)
    end
end

function UIWuJiangDevCardItem:SetLock(isLock)

    if isLock then
        self.m_lockImage:SetAtlasSprite("peiyang41.png")
    else
        self.m_lockImage:SetAtlasSprite("peiyang40.png")
    end
end

function UIWuJiangDevCardItem:OnClick(go, x, y)
    if go == self.m_frameGo then
        if self.WujiangIndex > 0 then
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.WujiangIndex, false)
        end
    end
end

function UIWuJiangDevCardItem:ShowTips(isShow, tipsText)
    if self.m_cardItem and self.m_cardItem:GetActive() then
        self.m_cardItem:ShowTips(isShow, tipsText)
    end 
end

function UIWuJiangDevCardItem:ShowEffect()
    if not self.m_iconEffect then
        local sortOrder = self:PopSortingOrder()
        UIUtil.AddComponent(UIEffect, self, "", sortOrder, TheGameIds.ui_shengxing_icon_fx_path, function(effect)
            self.m_iconEffect = effect
        end)
    end
end

function UIWuJiangDevCardItem:Release()
    if self.m_iconEffect then
        self.m_iconEffect:Delete()
        self.m_iconEffect = nil
    end
end


return UIWuJiangDevCardItem

