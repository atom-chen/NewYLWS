local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

local UIUtil = UIUtil
local ItemMgr = Player:GetInstance():GetItemMgr()
local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab

local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle

local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local InscriptionBagView = BaseClass("InscriptionBagView")

--命签的筛选方式(只显示哪些类型的命签)
local MingQianFilterType = 
{
    0,
    CommonDefine.MingQian_SubType_Tiao,
    CommonDefine.MingQian_SubType_Tong,
    CommonDefine.MingQian_SubType_Wan,
    CommonDefine.MingQian_SubType_Dong,
    CommonDefine.MingQian_SubType_Nan,
    CommonDefine.MingQian_SubType_Xi,
    CommonDefine.MingQian_SubType_Bei,
    CommonDefine.MingQian_SubType_Zhong,
    CommonDefine.MingQian_SubType_Fa,
    CommonDefine.MingQian_SubType_Bai,
}

--命签的排列方式
local MingQianSortType = 
{
    CommonDefine.SortByStageDecrease,
    CommonDefine.SortByStageIncrease,
    CommonDefine.SortByCountDecrease,
    CommonDefine.SortByCountIncrease,
}

function InscriptionBagView:__init(go, windowName)

    self.gameObject = go
    self.winName = windowName
    self.transform = go.transform

    self.m_currFilterType = 0 -- 子类型
    self.m_sortTypeIndex = 1  -- 排序类型
    self.m_filterNameIDArr = { 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029 }
    self.m_sortTypeNameIDArr = { 2062, 2063 ,2060, 2061 }
    
    self.m_itemList = {}
    self.m_seq = 0

    self.m_currShowItemDataList = {}

    self.m_curDragItem = false 

    self:InitView()
end

function InscriptionBagView:InitView()
    self.m_itemContent, self.m_sortBtn,  self.m_switchTypeBtn, self.m_mergeBtn, self.m_bgBtn, self.m_viewport
    = UIUtil.GetChildTransforms(self.transform, {
        "Container/ItemScrollView/Viewport/ItemContent",
        "Container/SortBtn",
        "Container/SwitchTypeBtn",
        "Container/MergeBtn",
        "Container/BgBtn",
        "Container/ItemScrollView/Viewport",
    })

    local titleText, mergeBtnText
    titleText, mergeBtnText, self.m_itemCountText, self.m_sortBtnText, self.m_switchTypeBtnText = UIUtil.GetChildTexts(self.transform, {
        "Container/TitleText",
        "Container/MergeBtn/MergeBtnText",
        "Container/ItemNumText",
        "Container/SortBtn/FitPos/SortBtnText",
        "Container/SwitchTypeBtn/FitPos/SwitchTypeBtnText"
    })

    titleText.text = Language.GetString(670)
    mergeBtnText.text = Language.GetString(671)

    self.m_scrollView = UIUtil.AddComponent(LoopScrowView, self, "Container/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateBagItem))

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_viewport.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_bgBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_sortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_switchTypeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_mergeBtn.gameObject, onClick)
end

function InscriptionBagView:OnClick(go)
    if go.name == "SwitchTypeBtn" then
        self:OnSwitchFilterType()
    elseif go.name == "SortBtn" then
        self:OnSwitchSortType()
    elseif go.name == "MergeBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIInscriptionAutoMergeView)
    elseif go.name == "BgBtn" or go.name == "Viewport" then
        
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_CLICK_MASK, true)
    end
end

function InscriptionBagView:__delete()
    UIUtil.RemoveClickEvent(self.m_viewport.gameObject)
    UIUtil.RemoveClickEvent(self.m_bgBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_sortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_switchTypeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_mergeBtn.gameObject)

    if self.m_scrollView then
        self.m_scrollView:Delete()
        self.m_scrollView = nil
    end

    for _, item in ipairs(self.m_itemList) do
        if item then
           -- UIUtil.RemoveDragEvent(item:GetGameObject())
            item:Delete()
        end
    end
    self.m_itemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0
    self.winName = nil

    self.gameObject = nil
    self.transform = nil
end


function InscriptionBagView:UpdateData(itemChgReason)
    self:UpdateItemList(itemChgReason)

    self:UpdateSwitchTypeBtnName()

    self:UpdateSortBtnName()
end

function InscriptionBagView:UpdateBagItem(item, realIndex)
    if not item then
        return
    end
    if realIndex > #self.m_currShowItemDataList then
        return
    end
    self:UpdateBagItemData(item, self.m_currShowItemDataList[realIndex])

    self:CurrSelectItemChg(item)
end

function InscriptionBagView:UpdateBagItemData(targetBagItem, itemData)
    if not itemData then
        return
    end
    local itemIconParam = ItemIconParam.New(itemData:GetItemCfg(), itemData:GetItemCount(), itemData:GetStage(), itemData:GetIndex(), function(bagItem)
        if not bagItem then
            return
        end

        self:ClearCurrSelectItem()

        bagItem:SetOnSelectState(true)
        self.m_currSelectItem = bagItem
        self.m_currSelectItemID = bagItem:GetItemID()

        local itemData = ItemMgr:GetItemData(bagItem:GetItemID())

        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_DETAIL_SHOW, true, itemData)
        
    end, true, true, itemData:GetLockState(), nil)
    
    targetBagItem:UpdateData(itemIconParam)
end

function InscriptionBagView:CurrSelectItemChg(bagItem)
    if self.m_currSelectItemID and bagItem then
        bagItem:SetOnSelectState(self.m_currSelectItemID == bagItem:GetItemID())
    end
end

function InscriptionBagView:UpdateItemList(itemChgReason)
    self.m_currShowItemDataList = self:GetAllItemDataList()

    if #self.m_itemList == 0 then
        self:CreateItemList()
    else
        self:ResetScrollView()
    end

    self:UpdateAllItemCount()
 
    if not itemChgReason or itemChgReason ~= CommonDefine.ItemChgReason_Lock then
        self:ClearCurrSelectItem() --操作会导致item删除等情况，所以取消选中 
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_DETAIL_SHOW, false)
    end
end

function InscriptionBagView:ResetScrollView()
    self.m_scrollView:UpdateView(true, self.m_itemList, self.m_currShowItemDataList)
    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CHILD_UI_SHOW_END, self.winName)
end

--创建物品列表
function InscriptionBagView:CreateItemList()
    if #self.m_itemList > 0 then
        return
    end

    if self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, BagItemPrefabPath, 28, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local bagItem = BagItemClass.New(objs[i], self.m_itemContent, BagItemPrefabPath) 
                    table_insert(self.m_itemList, bagItem)
                end

                self:ResetScrollView()
            end
        end)
    end
end

function InscriptionBagView:GetAllItemDataList() 
    local allItemDataList = {}

    ItemMgr:Walk(function(itemData)
        if itemData then
            local itemCfg = itemData:GetItemCfg()
            if itemCfg and itemCfg.sMainType == CommonDefine.ItemMainType_MingQian then
                if self.m_currFilterType == 0 or self.m_currFilterType == itemCfg.sSubType then
                    table_insert(allItemDataList, itemData)
                end
            end
        end
    end)

    local sortFunc = self:GetSortFunc()
    if sortFunc then
        table_sort(allItemDataList, sortFunc)
    end

    return allItemDataList
end

function InscriptionBagView:UpdateAllItemCount()
    local count = 0
    if self.m_currShowItemDataList then
        for _, itemData in pairs(self.m_currShowItemDataList) do
            if itemData then
                count = count + itemData:GetItemCount()
            end
        end
    end
    self.m_itemCountText.text = string_format(Language.GetString(669), count)
end

function InscriptionBagView:GetSortFunc()
    local sortFunc = nil

    local isGuideMingQian = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_MINGQIAN)
    if self.m_sortTypeIndex > 0 and self.m_sortTypeIndex <= #MingQianSortType then
        local sortType = MingQianSortType[self.m_sortTypeIndex]
        if sortType == CommonDefine.SortByCountDecrease then
            --按数量降序排序
            sortFunc = function(itemData1, itemData2)
                if itemData1 and itemData2 then
                    if isGuideMingQian then
                        local isSort, sortRet = self:GuideMingQianSort(itemData1, itemData2)
                        if isSort then return sortRet end
                    end
                    local itemCount1 = itemData1:GetItemCount() or 0
                    local itemCount2 = itemData2:GetItemCount() or 0
                    if itemCount1 ~= itemCount2 then
                        return itemCount1 > itemCount2
                    end
                    local itemCfg1 = itemData1:GetItemCfg()
                    local itemCfg2 = itemData2:GetItemCfg()


                    return self:BagItemDefaultSort(itemCfg1, itemCfg2)
                end
            end

        elseif sortType == CommonDefine.SortByCountIncrease then
            --按数量降序升序
            sortFunc = function(itemData1, itemData2)
                if itemData1 and itemData2 then
                    if isGuideMingQian then
                        local isSort, sortRet = self:GuideMingQianSort(itemData1, itemData2)
                        if isSort then return sortRet end
                    end
                    local itemCount1 = itemData1:GetItemCount() or 0
                    local itemCount2 = itemData2:GetItemCount() or 0
                    if itemCount1 ~= itemCount2 then
                        return itemCount1 < itemCount2
                    end
                    local itemCfg1 = itemData1:GetItemCfg()
                    local itemCfg2 = itemData2:GetItemCfg()
                    return self:BagItemDefaultSort(itemCfg1, itemCfg2)
                end
            end

        elseif sortType == CommonDefine.SortByStageDecrease then
            --按品阶降序排序
            sortFunc = function(itemData1, itemData2)
                if itemData1 and itemData2 then
                    if isGuideMingQian then
                        local isSort, sortRet = self:GuideMingQianSort(itemData1, itemData2)
                        if isSort then return sortRet end
                    end

                   
                    local itemCfg1 = itemData1:GetItemCfg()
                    local itemCfg2 = itemData2:GetItemCfg()
                    
                    if itemCfg1 and itemCfg2 then
                        local itemColor1 = itemCfg1.nColor or 0
                        local itemColor2 = itemCfg2.nColor or 0
                        if itemColor1 ~= itemColor2 then
                            return itemColor1 > itemColor2
                        end
                    end
                    return self:BagItemDefaultSort(itemCfg1, itemCfg2)
                end
            end

        elseif sortType == CommonDefine.SortByStageIncrease then
            --按品阶升序排序
            sortFunc = function(itemData1, itemData2)
                if itemData1 and itemData2 then
                    if isGuideMingQian then
                        local isSort, sortRet = self:GuideMingQianSort(itemData1, itemData2)
                        if isSort then return sortRet end
                    end
                    local itemCfg1 = itemData1:GetItemCfg()
                    local itemCfg2 = itemData2:GetItemCfg()
                    if itemCfg1 and itemCfg2 then
                        local itemColor1 = itemCfg1.nColor or 0
                        local itemColor2 = itemCfg2.nColor or 0
                        if itemColor1 ~= itemColor2 then
                            return itemColor1 < itemColor2
                        end
                    end
                    return self:BagItemDefaultSort(itemCfg1, itemCfg2)
                end
            end
        end
    end

    return sortFunc
end

function InscriptionBagView:BagItemDefaultSort(itemCfg1, itemCfg2)
    if itemCfg1 and itemCfg2 then
        local sSubType = itemCfg1.sSubType
        local sSubType2 = itemCfg2.sSubType
        if sSubType ~= sSubType2 then
            return sSubType < sSubType2
        end

        return itemCfg1.nBagsort > itemCfg2.nBagsort
    end
    return false
end

function InscriptionBagView:GuideMingQianSort(itemdata1, itemdata2)
    local itemCfg1 = itemdata1:GetItemCfg()
    local itemCfg2 = itemdata2:GetItemCfg()
    if itemCfg1 and itemCfg2 then
        if CommonDefine.MingQian_SubType_Tong == itemCfg1.sSubType and CommonDefine.MingQian_SubType_Tong ~= itemCfg2.sSubType then
            return true, true
        elseif CommonDefine.MingQian_SubType_Tong ~= itemCfg1.sSubType and CommonDefine.MingQian_SubType_Tong == itemCfg2.sSubType then
            return true, false
        elseif CommonDefine.MingQian_SubType_Tong == itemCfg1.sSubType and CommonDefine.MingQian_SubType_Tong == itemCfg2.sSubType then
            if itemCfg1.id == 21101 and itemCfg2.id ~= 21101 then
                return true, true
            elseif itemCfg1.id ~= 21101 and itemCfg2.id == 21101 then
                return true, false
            end
        end
    end
    return false
end

function InscriptionBagView:OnSwitchSortType()

    self.m_sortTypeIndex = self.m_sortTypeIndex + 1
    if self.m_sortTypeIndex > #MingQianSortType then
        self.m_sortTypeIndex = 1
    end

    self:UpdateSortBtnName()

    self:UpdateItemList()
end

function InscriptionBagView:UpdateSortBtnName()
    if self.m_sortTypeIndex > 0 and self.m_sortTypeIndex <= #self.m_sortTypeNameIDArr then
        local sortTypeNameID = self.m_sortTypeNameIDArr[self.m_sortTypeIndex]
        self.m_sortBtnText.text = Language.GetString(sortTypeNameID)
    end
end

function InscriptionBagView:OnSwitchFilterType()
    self.m_currFilterType = self.m_currFilterType + 1
    if self.m_currFilterType + 1 > #MingQianFilterType then
        self.m_currFilterType = 0
    end
    self:UpdateItemList()

    self:UpdateSwitchTypeBtnName()
end

function InscriptionBagView:UpdateSwitchTypeBtnName()
    local index = self.m_currFilterType + 1
    if index > 0 and index <= #self.m_filterNameIDArr then
        self.m_switchTypeBtnText.text = Language.GetString(self.m_filterNameIDArr[index])
    end
end

function InscriptionBagView:ClearCurrSelectItem()
    if self.m_currSelectItem then
        self.m_currSelectItem:SetOnSelectState(false)
        self.m_currSelectItem = nil
        self.m_currSelectItemID = 0
    end
end

function InscriptionBagView:ChangeLock(itemID, isLock)
    for _, item in ipairs(self.m_itemList) do
        if item:GetItemID() == itemID then
            item:SetLockState(isLock)
            break
        end
    end 
end 

function InscriptionBagView:OnLockChg(param) 
    self:ChangeLock(param.item_id, param.lock == 1)
    if not self.m_currSelectItem then
        return
    end 
    if param.item_id == self.m_currSelectItem:GetItemID() and param.index == self.m_currSelectItem:GetIndex() then
        local isLocked = param.lock == 1
        local canLock = self.m_currSelectItem:NeedShowLock()
 
        self.m_currSelectItem:SetLockState(isLocked) 
    end 
end  

function InscriptionBagView:OnDisable()
    self:ClearCurrSelectItem()
	base.OnDisable(self)
end

--[[ function InscriptionBagView:HandleDrag(dragGO)
    local function DragBegin(go, x, y, eventData)
        self:OnDragBegin(go, x, y, eventData)
    end

    local function DragEnd(go, x, y, eventData)
        self:OnDragEnd(go, x, y, eventData)
    end

    local function Drag(go, x, y, eventData)
        self:OnDrag(go, x, y, eventData)
    end
   
    UIUtil.AddDragBeginEvent(dragGO, DragBegin)
    UIUtil.AddDragEndEvent(dragGO, DragEnd)
    UIUtil.AddDragEvent(dragGO, Drag)
end ]]

--[[ function InscriptionBagView:OnDragBegin(go, x, y, eventData)

    --已经在拖拽
    if self.m_curDragItem then
        return
    end

    --数据校验
    local realIndex = tonumber(go.name)
    if realIndex > #self.m_currShowItemDataList then
        return
    end

    if self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, BagItemPrefabPath, 
            function(go)
                self.m_seq = 0
                if IsNull(go) then
                    return
                end

                self.m_curDragItem = BagItemClass.New(go, self.m_dragItemContent, BagItemPrefabPath)
                self:UpdateBagItemData(self.m_curDragItem, self.m_currShowItemDataList[realIndex])

                local ok, outV2 = ScreenPointToLocalPointInRectangle(self.m_dragItemContent, eventData.position, eventData.pressEventCamera)
                self.m_curDragItem:SetAnchoredPosition(Vector2.New(outV2.x, outV2.y))
            end)
    end

    --更新DragItem
    --self:EnableItemRaycast(false) todo
end ]]

--[[ function InscriptionBagView:OnDragEnd(go, x, y, eventData)
    if self.m_curDragItem then
        self.m_curDragItem:Delete()
        self.m_curDragItem = nil
    end
end

function InscriptionBagView:OnDrag(go, x, y, eventData)
    if self.m_curDragItem then
        local ok, outV2 = ScreenPointToLocalPointInRectangle(self.m_dragItemContent, eventData.position, eventData.pressEventCamera)
        self.m_curDragItem:SetAnchoredPosition(Vector2.New(outV2.x, outV2.y))
    end
end
 ]]

return InscriptionBagView


