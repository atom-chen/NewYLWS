local GameObject = CS.UnityEngine.GameObject
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil
local string_format = string.format
local string_split = CUtil.SplitString
local CommonDefine = CommonDefine
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local MountMgr = Player:GetInstance():GetMountMgr()
local HorseRaceMgr = Player:GetInstance():GetHorseRaceMgr()
local bagItemPath = TheGameIds.CommonBagItemPrefab
local ZuoQiObjPath = "UI/Prefabs/ZuoQi/ZuoQiObj.prefab"
local bagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local UIHorseRaceSelectView = BaseClass("UIHorseRaceSelectView", UIBaseView)
local base = UIBaseView

function UIHorseRaceSelectView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIHorseRaceSelectView:InitView()

    local directionText
    directionText, self.m_typeSortBtnText, self.m_levelSortBtnText, self.m_countText = UIUtil.GetChildTexts(self.transform, {
        "Container/bg/directionText",
        "Container/bg/top/TypeSortBtn/FitPos/TypeSortBtnText",
        "Container/bg/top/LevelSortBtn/FitPos/LevelSortBtnText",
        "Container/bg/top/CountText",
    })

    self.m_closeBtn, self.m_typeSortBtn, self.m_levelSortBtn, self.m_viewContent = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn",
        "Container/bg/top/TypeSortBtn",
        "Container/bg/top/LevelSortBtn",
        "Container/bg/ItemScrollView/Viewport/ItemContent",
    })

    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/bg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateZuoqiList))

    directionText.text = Language.GetString(4156)
    self.m_typeSortPriorityTexts = string_split(Language.GetString(3501), "|")
    self.m_levelSortPriorityTexts = string_split(Language.GetString(2902), "|")
    self.m_seq = 0
    self.m_zuoqiItemList = {}
end

function UIHorseRaceSelectView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_typeSortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_levelSortBtn.gameObject, onClick)
end

function UIHorseRaceSelectView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_typeSortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_levelSortBtn.gameObject)
end

function UIHorseRaceSelectView:OnEnable(...)
    base.OnEnable(self, ...)
    local order
    order = ...
    self.m_typeSortPriority = CommonDefine.MOUNT_TYPE_ALL
    self.m_levelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN
    self:HandleClick()
    self:UpdateZuoQiItem(false)
end

function UIHorseRaceSelectView:OnClick(go, x, y)
    if go.name == "closeBtn" then
        self:CloseSelf()
    elseif go.name == "TypeSortBtn" then
        self.m_typeSortPriority = self.m_typeSortPriority + 1
        if self.m_typeSortPriority > CommonDefine.MOUNT_TYPE_RHINO then
            self.m_typeSortPriority = CommonDefine.MOUNT_TYPE_ALL
        end
        self:UpdateZuoQiItem(true)
    elseif go.name == "LevelSortBtn" then
        self.m_levelSortPriority = self.m_levelSortPriority + 1
        if self.m_levelSortPriority > CommonDefine.SHENBING_LEVEL_UP then
            self.m_levelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN
        end
        self:UpdateZuoQiItem(true)
    end
end

function UIHorseRaceSelectView:UpdateZuoQiItem(reset)

    self:GetSortZuoQiList()

    if #self.m_zuoqiItemList == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, bagItemPath, 30, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local zuoqiItem = bagItem.New(objs[i], self.m_viewContent, bagItemPath)
                    table_insert(self.m_zuoqiItemList, zuoqiItem)
                end
            end
            self.m_scrollView:UpdateView(true, self.m_zuoqiItemList, self.m_zuoqiList)
        end)
    else
        self.m_scrollView:UpdateView(reset, self.m_zuoqiItemList, self.m_zuoqiList)
    end

    self.m_countText.text = string_format(Language.GetString(2903), #self.m_zuoqiList)

    if self.m_typeSortPriority - 22999 <= #self.m_typeSortPriorityTexts then
        self.m_typeSortBtnText.text = self.m_typeSortPriorityTexts[self.m_typeSortPriority - 22999]
    end

    if self.m_levelSortPriority <= #self.m_levelSortPriorityTexts then
        self.m_levelSortBtnText.text = self.m_levelSortPriorityTexts[self.m_levelSortPriority]
    end
end

function UIHorseRaceSelectView:GetSortZuoQiList()
    self.m_zuoqiList = self:SortZuoQi(self.m_levelSortPriority, nil, function(data)
        local zuoqiCfg = ConfigUtil.GetZuoQiCfgByID(data.m_id)
        if self.m_typeSortPriority == CommonDefine.MOUNT_TYPE_ALL or zuoqiCfg.id == self.m_typeSortPriority then
            return true
        end
    end)
end

function UIHorseRaceSelectView:SortZuoQi(priority, wujiangIndex, filter)
    local mountList = {}
    local allMountList = MountMgr:GetAllMount()

    if allMountList then
        for _, v in pairs(allMountList) do
            if v then
                if filter then
                    if filter(v) then
                        table_insert(mountList, v)
                    end
                end
            end
        end
    
        table_sort(mountList, function(l, r)
            local bagSortL = ConfigUtil.GetItemCfgByID(l.m_id).nBagsort
            local bagSortR = ConfigUtil.GetItemCfgByID(r.m_id).nBagsort
    
            local isLeftTired = HorseRaceMgr:CheckHorseIsTired(l:GetIndex())
            local isRightTired = HorseRaceMgr:CheckHorseIsTired(r:GetIndex())
            if isLeftTired ~= isRightTired then
                return isLeftTired < isRightTired
            end
    
            if l.m_stage ~= r.m_stage then
                if priority == CommonDefine.SHENBING_LEVEL_DOWN then
                    return l.m_stage > r.m_stage
                elseif priority == CommonDefine.SHENBING_LEVEL_UP then
                    return l.m_stage < r.m_stage
                end
            end
    
            if bagSortL and bagSortR then
                if bagSortL ~= bagSortR then
                    return bagSortL < bagSortR
                end
            end
        end)
    end

    return mountList
end

function UIHorseRaceSelectView:UpdateZuoqiList(item, realIndex)
    if self.m_zuoqiList then
        if item and realIndex > 0 and realIndex <= #self.m_zuoqiList then
            local data = self.m_zuoqiList[realIndex]
            local isTired = HorseRaceMgr:CheckHorseIsTired(data:GetIndex()) == 1
            local itemCfg = ConfigUtil.GetItemCfgByID(data.m_id)
            local horseCfg = ConfigUtil.GetZuoQiCfgByID(data.m_id)
            local itemIconParam = ItemIconParam.New(itemCfg, 1, data.m_stage, data.m_index, Bind(self, self.ZuoQiItemClick), false, false, false, false, false, data.m_stage, isTired)
            itemIconParam.equipText = Language.GetString(4157)
            itemIconParam.horseNameText = string_format(Language.GetString(4174),self:GetTotalAttr(data))
            item:SetIconColor(not isTired)
            item:UpdateData(itemIconParam)
        end
    end
end

function UIHorseRaceSelectView:GetTotalAttr(data)
    local totalAttr = 0
    local baseAttr = data.m_base_first_attr
    local extraAttr = data.m_extra_first_attr
    local attrNameList = CommonDefine.first_attr_name_list
    if baseAttr and extraAttr then
        for i, v in pairs(attrNameList) do
            local val = baseAttr[v]
            local val2 = extraAttr[v]
            if val and val2 then
                totalAttr = totalAttr + val + val2
            end
        end        
    end
    return totalAttr
end

function UIHorseRaceSelectView:ZuoQiItemClick(item)
    if not item then
        return
    end

    local index = item:GetIndex()
    if HorseRaceMgr:CheckHorseIsTired(index) == 1 then
        UILogicUtil.FloatAlert(Language.GetString(4158))
    else
        HorseRaceMgr:ReqApplyRacing(index)
        self:CloseSelf()
    end
end

function UIHorseRaceSelectView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()

    UIGameObjectLoader:CancelLoad(self.m_seq)
    self.m_seq = 0
    
    for _, v in pairs(self.m_zuoqiItemList) do
        v:SetIconColor(true)
        v:Delete()
    end
    self.m_zuoqiItemList = {}
    self.m_zuoqiList = nil
end

function UIHorseRaceSelectView:OnDestroy()
    base.OnDestroy(self)
end

function UIHorseRaceSelectView:OnAddListener()
	base.OnAddListener(self)
end

function UIHorseRaceSelectView:OnRemoveListener()
	base.OnRemoveListener(self)
end

return UIHorseRaceSelectView