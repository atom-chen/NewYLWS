
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local ItemMgr = Player:GetInstance():GetItemMgr()

local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local ItemContentPath = "Container/ItemScrollView/Viewport/ItemContent"
local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local InscriptionMergeSuccView = BaseClass("InscriptionMergeSuccView", UIBaseView)
local base = UIBaseView

function InscriptionMergeSuccView:OnCreate()
    base.OnCreate(self)

    self.m_seq = 0
    self.m_itemList = {}

    self:InitView()
end

function InscriptionMergeSuccView:InitView()
    self.m_closeBtn , self.m_containerTrans, self.m_itemContentTrans, self.m_itemScrollViewTran = 
    UIUtil.GetChildTransforms(self.transform, {
        "CloseBtn",
        "Container",
        ItemContentPath,
        "Container/ItemScrollView"
    })
    
    local getItemText = UIUtil.GetChildTexts(self.transform, {
        "Container/GetItemText",
    })
    
    getItemText.text = Language.GetString(691)

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent( self.m_closeBtn.gameObject, onClick)

    self.m_scrollView = self:AddComponent(LoopScrowView, ItemContentPath, Bind(self, self.UpdateBagItem))
end

function InscriptionMergeSuccView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function InscriptionMergeSuccView:OnDestroy()
    
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function InscriptionMergeSuccView:UpdateBagItem(item, realIndex)
    if not item then
        return
    end

    if not self.m_inscription_list then
        return
    end

    if realIndex > #self.m_inscription_list then
        return
    end

    self:UpdateBagItemData(item, self.m_inscription_list[realIndex])
end

function InscriptionMergeSuccView:UpdateBagItemData(targetBagItem, itemData)
    if not itemData then
        return
    end
    local itemCount = itemData:GetItemCount()
    local itemIconParam = ItemIconParam.New(itemData:GetItemCfg(), itemCount, itemData:GetStage(), itemData:GetIndex(), nil, 
    false, false, itemData:GetLockState(), nil, ItemMgr:CheckIsNewGet(itemData:GetItemID()))
    itemIconParam.onClickShowDetail = true
    targetBagItem:UpdateData(itemIconParam)
end

function InscriptionMergeSuccView:OnEnable(...)
    base.OnEnable(self, ...)

    _, inscription_list = ...
    if inscription_list then

        self.m_inscription_list = inscription_list

        self:UpdateItemList()
    end
end

function InscriptionMergeSuccView:OnDisable()
    for _,item in ipairs(self.m_itemList) do
        if item then
            item:Delete()
        end
    end
    self.m_itemList = {}
    self.m_inscription_list = nil

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    base.OnDisable(self)
end

function InscriptionMergeSuccView:UpdateItemList()
    if #self.m_itemList > 0 then
        return
    end

    self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, BagItemPrefabPath, 8, function(objs)
        self.m_seq = 0
        if objs then
            for i = 1, #objs do
                local bagItem = BagItemClass.New(objs[i], self.m_itemContentTrans, BagItemPrefabPath)
                if bagItem then
                    table_insert(self.m_itemList, bagItem)
                end
            end

            self.m_scrollView:UpdateView(true, self.m_itemList, self.m_inscription_list)

            if #self.m_inscription_list < 5 then
               -- coroutine.start(self.FitItemContentPos, self)
                local posX =  345 - (145 * #self.m_inscription_list) / 2
                self.m_itemContentTrans.localPosition = Vector3.New(posX, self.m_itemContentTrans.localPosition.y, 0)
            end
        end
    end)
end



--[[ function InscriptionMergeSuccView:FitItemContentPos()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_itemContentTrans, self.m_itemScrollViewTran)
end ]]

return InscriptionMergeSuccView