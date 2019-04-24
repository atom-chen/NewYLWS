
local table_insert = table.insert
local string_split = string.split
local math_ceil = math.ceil
local string_format = string.format
local Language = Language
local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local MountMgr = Player:GetInstance():GetMountMgr()
local bagItemPath = TheGameIds.CommonBagItemPrefab
local bagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local UIMyMountView = BaseClass("UIMyMountView", UIBaseView)
local base = UIBaseView

function UIMyMountView:OnCreate()
    base.OnCreate(self)
    local titleText
    titleText, self.m_mountCountText, self.m_typeSortBtnText, self.m_levelSortBtnText = UIUtil.GetChildTexts(self.transform, {
        "Container/MyMount/bg/top/Text",
        "Container/MyMount/bg/mid/CountText",
        "Container/MyMount/bg/mid/btnGrid/TypeSortBtn/FitPos/SortBtnText",
        "Container/MyMount/bg/mid/btnGrid/LevelSortBtn/FitPos/LevelSortBtnText",
    })

    self.m_backBtn, self.m_typeSortBtn, self.m_levelSortBtn, self.m_contentTr = UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
        "Container/MyMount/bg/mid/btnGrid/TypeSortBtn",
        "Container/MyMount/bg/mid/btnGrid/LevelSortBtn",
        "Container/MyMount/bg/ItemScrollView/Viewport/ItemContent"
    })

    titleText.text = Language.GetString(3520)
    self.m_typeSortPriorityTexts = string_split(Language.GetString(3501), "|")
    self.m_levelSortPriorityTexts = string_split(Language.GetString(2902), "|")

    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/MyMount/bg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateZuoqiList))

    self.m_zuoqiItemList = {}
    self.m_seq = 0
    self.m_curSelectItem = false

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_typeSortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_levelSortBtn.gameObject, onClick)
end

function UIMyMountView:OnClick(go)
    if go.name == "backBtn" then
        self:CloseSelf()
    elseif go.name == "TypeSortBtn" then
        self.m_typeSortPriority = self.m_typeSortPriority + 1
        if self.m_typeSortPriority > CommonDefine.MOUNT_TYPE_RHINO then
            self.m_typeSortPriority = CommonDefine.MOUNT_TYPE_ALL
        end
        self:UpdateZuoQiItem()
    elseif go.name == "LevelSortBtn" then
        self.m_levelSortPriority = self.m_levelSortPriority + 1
        if self.m_levelSortPriority > CommonDefine.SHENBING_LEVEL_UP then
            self.m_levelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN
        end
        self:UpdateZuoQiItem()
    end
end

function UIMyMountView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_typeSortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_levelSortBtn.gameObject)
    base.OnDestroy(self)
end

function UIMyMountView:OnEnable(...)
    base.OnEnable(self, ...)
    -- print("enable")
    self.m_typeSortPriority = CommonDefine.MOUNT_TYPE_ALL
    self.m_levelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN

    self:UpdateZuoQiItem()
end

function UIMyMountView:UpdateZuoQiItem()
    self:GetSortZuoQiList()
    self.m_mountCountText.text = string_format(Language.GetString(2903), #self.m_zuoqiList)

    if #self.m_zuoqiItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, bagItemPath, 30, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local zuoqiItem = bagItem.New(objs[i], self.m_contentTr, bagItemPath)
                    table_insert(self.m_zuoqiItemList, zuoqiItem)
                end
            end
            self.m_scrollView:UpdateView(true, self.m_zuoqiItemList, self.m_zuoqiList)
        end)
    else
        self.m_scrollView:UpdateView(true, self.m_zuoqiItemList, self.m_zuoqiList)
    end

    if self.m_typeSortPriority - 22999 <= #self.m_typeSortPriorityTexts then
        self.m_typeSortBtnText.text = self.m_typeSortPriorityTexts[self.m_typeSortPriority - 22999]
    end

    if self.m_levelSortPriority <= #self.m_levelSortPriorityTexts then
        self.m_levelSortBtnText.text = self.m_levelSortPriorityTexts[self.m_levelSortPriority]
    end
end

function UIMyMountView:GetSortZuoQiList()
    self.m_zuoqiList = MountMgr:GetSortMountList(self.m_levelSortPriority, self.m_wujiangIndex, function(data)
        local zuoqiCfg = ConfigUtil.GetZuoQiCfgByID(data.m_id)
        if self.m_typeSortPriority == CommonDefine.MOUNT_TYPE_ALL or zuoqiCfg.id == self.m_typeSortPriority then
            return true
        end
    end)
end

function UIMyMountView:UpdateZuoqiList(item, realIndex)
    if self.m_zuoqiList then
        if item and realIndex > 0 and realIndex <= #self.m_zuoqiList then
            local data = self.m_zuoqiList[realIndex]
            local itemCfg = ConfigUtil.GetItemCfgByID(data.m_id)
            local horseCfg = ConfigUtil.GetZuoQiCfgByID(data.m_id)
            local itemIconParam = ItemIconParam.New(itemCfg, 1, data.m_stage, data.m_index, Bind(self, self.ZuoQiItemClick), false, false, false,
                false, false, data.m_stage, false)
            itemIconParam.horseNameText = horseCfg["name"..math_ceil(data.m_stage)]
            item:UpdateData(itemIconParam)
        end
    end

end 

function UIMyMountView:ZuoQiItemClick(item)
    if not item then
        return
    end
    self.m_curSelectItem = item
    local screenPoint = UIManagerInst.UICamera:WorldToScreenPoint(item:GetTransform().position)
    UIManagerInst:OpenWindow(UIWindowNames.UIMountItemTips, item:GetIndex(), screenPoint, Bind(self, self.MountItemCallback))
end

function UIMyMountView:MountItemCallback()
    if self.m_curSelectItem then
        UIManagerInst:OpenWindow(UIWindowNames.UIZuoQiImprove, self.m_curSelectItem:GetIndex())
        self:CloseSelf()
    end
end

function UIMyMountView:OnDisable()
    UIGameObjectLoader:CancelLoad(self.m_seq)
    self.m_seq = 0

    for _, v in pairs(self.m_zuoqiItemList) do
        v:Delete()
    end
    self.m_zuoqiItemList = {}
    self.m_zuoqiList = nil
    self.m_curSelectItem = false
    self.m_curZuoQiData = false

    base.OnDisable(self)
end

return UIMyMountView