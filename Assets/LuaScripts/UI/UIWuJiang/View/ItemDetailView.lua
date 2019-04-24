

local table_insert = table.insert
local table_remove = table.remove
local string_format = string.format
local copyNumList = table.copyNumList

local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local ItemMgr = Player:GetInstance():GetItemMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr
local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab

local DoTween = CS.DOTween.DOTween
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local Type_CanvasGroup = typeof(CS.UnityEngine.CanvasGroup)
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local CalculateRelativeRectTransformBounds = CS.UnityEngine.RectTransformUtility.CalculateRelativeRectTransformBounds
local DOTweenSettings = CS.DOTween.DOTweenSettings

local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local ItemDetailView = BaseClass("ItemDetailView" , UIBaseItem)
local base = UIBaseItem

local OperateEquip = 1
local OperateUnLoadOrReplace = 2
local OperateReplace = 3
local OperateUnLoad = 4
local OperateHide = 5
-- 1 装备 2 可卸载可以替换 3 替换  4卸载 5不能操作

function ItemDetailView:OnCreate()

    base.OnCreate(self)

    self.m_item = nil
    self.m_seq = 0

    self:InitView()
end

function ItemDetailView:InitView()
   self.m_btn, self.m_btn2, self.m_btn3,  self.m_itemCreatePos, self.m_equipedGo, self.m_btnGroup = 
   UIUtil.GetChildRectTrans(self.transform, {
       "BtnGrid/Btn",
       "BtnGrid/Btn2",
       "BtnGrid/Btn3",
       "ItemCreatePos",
       "EquipedImage",
       "BtnGrid"
   })
   
   self.m_btnText, self.m_btn2Text, self.m_btn3Text, self.m_itemNameText,self.m_itemAttrText, 
   self.m_itemDescText = UIUtil.GetChildTexts(self.transform, {
    "BtnGrid/Btn/BtnText",
    "BtnGrid/Btn2/Btn2Text",
    "BtnGrid/Btn3/Btn3Text",
    "ItemNameText",
    "ItemAttrText",
    "ItemDescText",
    })

    self.m_itemLockSpt = UIUtil.AddComponent(UIImage, self, "ItemLockSpt", AtlasConfig.DynamicLoad)
    self.m_canvasGroup = self.transform:GetComponent(Type_CanvasGroup)

    self.m_btn3Text.text = Language.GetString(672)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    self.m_btn2 = self.m_btn2.gameObject
    self.m_equipedGo  = self.m_equipedGo.gameObject
    self.m_btnGroup  = self.m_btnGroup.gameObject
    self.m_btnGrid = self.m_btnGroup:GetComponent(Type_GridLayoutGroup)

    self.m_equipedGo:SetActive(false)

    UIUtil.AddClickEvent(self.m_btn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_btn2, onClick)
    UIUtil.AddClickEvent(self.m_btn3.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_itemLockSpt.gameObject, onClick)

    self.m_colorList = { "ffffff","32b0e4", "e041e6", "e8c04c", "d24643"}
end

function ItemDetailView:OnDestroy()

    UIUtil.RemoveClickEvent(self.m_btn.gameObject)
    UIUtil.RemoveClickEvent(self.m_btn2)
    UIUtil.RemoveClickEvent(self.m_btn3.gameObject)
    UIUtil.RemoveClickEvent(self.m_itemLockSpt.gameObject)
   
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    if self.m_item then
        self.m_item:Delete()
        self.m_item = nil
    end

    base.OnDestroy(self)
end

function ItemDetailView:UpdateData(itemData, operateType, wujiangIndex, isEquiped) 
    if not itemData then
        return
    end  
    self.m_itemData = itemData
    self.m_operateType = operateType
    self.m_wujiangIndex = wujiangIndex
    self.m_isEquiped = isEquiped

    local itemCfg = self.m_itemData:GetItemCfg()
    if not itemCfg then
        return
    end

    if isEquiped == nil then
        isEquiped = false
    end

    self.m_equipedGo:SetActive(isEquiped)

    self:ShowBtn(operateType)

    if self.m_item == nil then
        self:CreateItem()
    else
        self:UpdateBagItemData(self.m_item, self.m_itemData)
    end
    
    self.m_itemNameText.text = itemCfg.sName
    self.m_itemDescText.text = itemCfg.sTips

    local stage  = UILogicUtil.GetInscriptionStage(itemCfg.id)
    local color = self.m_colorList[stage]
    self.m_itemAttrText.text =  string_format(Language.GetString(689), color, UILogicUtil.GetInscriptionDesc(itemCfg.id)) 
 
    local bounds = CalculateRelativeRectTransformBounds(self.transform)
    self.m_size = bounds.size

    if not self.m_isTweenShow then
        self.m_isTweenShow = true
        
        coroutine.start(self.TweenShow, self)
    end
end

function ItemDetailView:SetReplaceItemID(itemID)
    self.m_replaceItemID = itemID
end

function ItemDetailView:CreateItem()
    if self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, BagItemPrefabPath, function(obj)
            self.m_seq = 0
            if not IsNull(obj) then
                self.m_item = BagItemClass.New(obj, self.m_itemCreatePos, BagItemPrefabPath)

                self:UpdateBagItemData(self.m_item, self.m_itemData)
            end
        end)
    end
end

function ItemDetailView:UpdateBagItemData(targetBagItem, itemData)
    if not itemData then
        return
    end
    local itemIconParam = ItemIconParam.New(itemData:GetItemCfg(), 0, itemData:GetStage(), itemData:GetIndex())
    itemIconParam.needShowLock = true
    itemIconParam.isLocked = itemData:GetLockState()
    itemIconParam.onClickShowDetail = true

    targetBagItem:UpdateData(itemIconParam)
    self.m_curSelectBagItem = targetBagItem

    local canLock = targetBagItem:NeedShowLock()
    local isLocked = targetBagItem:GetLockState() or false 
    self:ChangeLock(canLock, isLocked)
end 

function ItemDetailView:OnLockChg(param) 
    if not self.m_curSelectBagItem then
        return
    end

    if param.item_id == self.m_curSelectBagItem:GetItemID() and param.index == self.m_curSelectBagItem:GetIndex() then
        local isLocked = param.lock == 1
        local canLock = self.m_curSelectBagItem:NeedShowLock()

        self.m_curSelectBagItem:SetLockState(isLocked)
         
        self:ChangeLock(canLock, isLocked)
    end
end

function ItemDetailView:ChangeLock(canLock, isLocked) 
    -- if canLock then
    --     UILogicUtil.SetLockImage(self.m_itemLockSpt, isLocked)
    -- else
    --     self.m_itemLockSpt:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
    -- end 

    UILogicUtil.SetLockImage(self.m_itemLockSpt, isLocked)
end

function ItemDetailView:OnClick(go, x, y)
    local goName = go.name
    if goName == "Btn" or goName == "Btn2" then
        if self.m_itemData then
            local inscription_id_list = WuJiangMgr:GetOwnInscriptionIDList(self.m_wujiangIndex)
            inscription_id_list = copyNumList(inscription_id_list)

            
            local function remove_inscription()
                if inscription_id_list then
                    for i, v in ipairs(inscription_id_list) do
                        if v == self.m_itemData:GetItemID() then
                            table_remove(inscription_id_list, i)
                            break
                        end
                    end
                end
            end

            local function replace_inscription()
                if inscription_id_list then
                    -- print("self.m_replaceItemID ",self.m_replaceItemID,self.m_itemData:GetItemID(), table.dump(inscription_id_list))
                    for i, v in ipairs(inscription_id_list) do
                        if v == self.m_replaceItemID then
                            inscription_id_list[i] = self.m_itemData:GetItemID()
                            Player:GetInstance().InscriptionMgr:SetEquipInscriptionItemID(self.m_itemData:GetItemID())
                            break
                        end
                    end
                end
            end

            if self.m_operateType == OperateEquip then
                inscription_id_list = inscription_id_list or {}
                table_insert(inscription_id_list,  self.m_itemData:GetItemID())

                Player:GetInstance().InscriptionMgr:SetEquipInscriptionItemID(self.m_itemData:GetItemID())

            elseif self.m_operateType == OperateUnLoad then
                remove_inscription()
            
            elseif self.m_operateType == OperateReplace then
                replace_inscription()

            elseif self.m_operateType == OperateUnLoadOrReplace then
                if goName == "Btn" then
                    remove_inscription()
                elseif goName == "Btn2" then
                    replace_inscription()
                end
            end
            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "UIWuJiangInscription")
            local isReplace = (self.m_operateType == OperateUnLoadOrReplace and goName == "Btn2") or self.m_operateType == OperateReplace
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_OPERATION, inscription_id_list, isReplace)
        end
       
    elseif goName == "Btn3" then
        if self.m_itemData then
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_MERGE_VIEW_SHOW, true, self.m_itemData)
        end
    elseif goName == "ItemLockSpt" then
        self:OnItemLockSptClick()
    end
end

function ItemDetailView:OnItemLockSptClick()
    if self.m_curSelectBagItem then 
        self.m_curSelectBagItem:ChgLockState()
    end
end

function ItemDetailView:ShowBtn(type)
    -- Logger.Log("ShowBtn type "..type)
    if type == OperateHide then
        self.m_btnGroup:SetActive(false)
        return
    else
        self.m_btnGroup:SetActive(true)
    end

    if type == OperateEquip then
        self.m_btnText.text = Language.GetString(675)
    elseif type == OperateUnLoadOrReplace then
        self.m_btnText.text = Language.GetString(673)
        self.m_btn2Text.text = Language.GetString(674)
    elseif type == OperateReplace then
        self.m_btnText.text = Language.GetString(674)
    elseif type == OperateUnLoad then
        self.m_btnText.text = Language.GetString(673)
    end

    if type == OperateUnLoadOrReplace then
        self.m_btn2:SetActive(true)
        self.m_btnGrid.spacing = Vector2.New(0, 0)
    else
        self.m_btn2:SetActive(false)
        self.m_btnGrid.spacing = Vector2.New(68, 0)
    end
end

function ItemDetailView:Refresh(wujiangIndex, itemData, operateType, isEquiped)
    if itemData then
        self.m_itemData = itemData
    end

    if operateType then
        self.m_operateType = operateType
    end

    if isEquiped then
        self.m_isEquiped = isEquiped
    end

    self.m_wujiangIndex = wujiangIndex

    if self.m_itemData and self.m_wujiangIndex then
        self:UpdateData(self.m_itemData, self.m_operateType, self.m_wujiangIndex, self.m_isEquiped)
    end
end

function ItemDetailView:GetItemID()
    if self.m_itemData then
        return self.m_itemData:GetItemID()
    end
end

function ItemDetailView:GetItemData()
    return self.m_itemData
end

function ItemDetailView:OnDisable()
    self.m_isTweenShow = false

    base.OnDisable(self)
end

local TweenTime = 0.3
local ScaleSize = Vector3.New(1.3, 1.3, 1.3)

function ItemDetailView:TweenShow()
    coroutine.waitforframes(1)

    --缩放
    self.transform.localScale = ScaleSize
    DOTweenShortcut.DOScale(self.transform, 1, TweenTime)
 
    --移动
    if self.m_size then
        local offsetY = self.m_size.y * 0.2
        local oldPos = self.transform.localPosition
        self.transform.localPosition = oldPos + Vector3.New(0, offsetY, 0)
        DOTweenShortcut.DOLocalMoveY(self.transform, oldPos.y, TweenTime)
    end 

    --渐变
    local function setterFunc(alpha)
        self.m_canvasGroup.alpha = alpha
    end
    local tweener = DoTween.To(setterFunc, 0.1, 1, TweenTime)
    DOTweenSettings.OnComplete(tweener, function()
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CHILD_UI_SHOW_END, "UIWuJiangInscriptionItem")
    end)
 end

return ItemDetailView