local ItemMgr = Player:GetInstance():GetItemMgr()
local UIUtil = UIUtil
local string_format = string.format

local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local BagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local UIEffect = UIEffect
local ui_mingqian_equip_path = "UI/Effect/Prefabs/ui_mingqian_equip"

local InscriptionItem = BaseClass("InscriptionItem", UIBaseItem)
local base = UIBaseItem

function InscriptionItem:OnCreate()
    base.OnCreate(self)

    self.m_emptyItem, self.m_lockImageGo, self.m_itemIconSptGo = UIUtil.GetChildTransforms(self.transform, {
        "EmptyItem",
        "EmptyItem/LockImgge",
        "EmptyItem/ItemIconSpt"
    })

    self.m_emptyItem = self.m_emptyItem.gameObject
    self.m_lockImageGo = self.m_lockImageGo.gameObject
    self.m_itemIconSptGo = self.m_itemIconSptGo.gameObject

    self.m_seq = 0
    self.m_sortOrder = 0

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_emptyItem, onClick)
end

function InscriptionItem:OnClick(go)
    if go == self.m_emptyItem then
        if not self.m_lock then
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_BAG_SHOW, true)
        else
            if self.m_index == 7 then
                UILogicUtil.FloatAlert(string_format(Language.GetString(703), 3))
            elseif self.m_index == 8 then
                UILogicUtil.FloatAlert(string_format(Language.GetString(703), 9))
            elseif self.m_index == 9 then
                UILogicUtil.FloatAlert(string_format(Language.GetString(703), 15))
            end
        end
    end
end

function InscriptionItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_emptyItem)
    self.m_itemOnClick = nil

    if self.m_bagItem then
        self.m_bagItem:Delete()
        self.m_bagItem = nil
    end

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    self:ShowEquipEffect(false)

    base.OnDestroy(self)
end

function InscriptionItem:SetData(inscriptionItemID, itemOnClick, isLock, index, sortOrder)

    self.m_index = index
    self.m_inscriptionItemID = inscriptionItemID
    self.m_sortOrder = sortOrder
    if inscriptionItemID == nil then
        self.m_emptyItem:SetActive(true)
        isLock = isLock or false

        self.m_lockImageGo:SetActive(isLock)
        self.m_itemIconSptGo:SetActive(not isLock)

        self.m_lock = isLock

        if self.m_bagItem then
            self.m_bagItem:SetActive(false)
        end
        
        return
    end
    
    self.m_emptyItem:SetActive(false)

    self.m_itemOnClick = itemOnClick

    if self.m_bagItem then
        if self.m_bagItem:GetActive() == false then
            self.m_bagItem:SetActive(true)
        end
        self:UpdateInscriptionItem(self.m_bagItem, inscriptionItemID)
    else
        if self.m_seq == 0 then
            self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, BagItemPrefabPath, 
                function(go)
                    self.m_seq = 0
                    if IsNull(go) then
                        return
                    end
    
                    self.m_bagItem = BagItem.New(go, self.transform, BagItemPrefabPath)
                    self:UpdateInscriptionItem(self.m_bagItem, inscriptionItemID)
                end)
        end
    end
end

function InscriptionItem:UpdateInscriptionItem(inscriptionItem, itemID, count)
    count = count or 0
    local itemCfg = ConfigUtil.GetItemCfgByID(itemID)
    if inscriptionItem and itemCfg then
        local itemIconParam = ItemIconParam.New(itemCfg, count, nil, 0, self.m_itemOnClick, false, true)
        --itemIconParam.onClickShowDetail = true
        inscriptionItem:UpdateData(itemIconParam)
    end
end

function InscriptionItem:GetInscriptionItemID()
    return self.m_inscriptionItemID
end

function InscriptionItem:ShowEquipEffect(isShow)
    if isShow then
        if not self.m_equipInscriptionEffect then
            UIUtil.AddComponent(UIEffect, self, "", self.m_sortOrder, ui_mingqian_equip_path, function(effect)
                self.m_equipInscriptionEffect = effect
            end)
        else
            self.m_equipInscriptionEffect:Play()
        end
    else
        if self.m_equipInscriptionEffect then
            self.m_equipInscriptionEffect:Delete()
            self.m_equipInscriptionEffect = nil
        end
    end
end

return InscriptionItem
