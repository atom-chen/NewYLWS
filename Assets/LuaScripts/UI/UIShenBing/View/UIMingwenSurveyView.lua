
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local string_split = string.split

local MingwenItem = require "UI.UIShenBing.View.MingwenItem"
local MingwenItemPrefab = "UI/Prefabs/Shenbing/MingwenItem.prefab"
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local Language = Language
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local CommonDefine = CommonDefine

local UIMingwenSurveyView = BaseClass("UIMingwenSurveyView", UIBaseView)
local base = UIBaseView

function UIMingwenSurveyView:OnCreate()
    base.OnCreate(self)
    local titleText
    titleText, self.m_buttonText = UIUtil.GetChildTexts(self.transform, {
        "Container/Mingwen/bg/top/Text",
        "Container/Mingwen/bg/mid/TypeSortBtn/FitPos/Text",
    })

    self.m_backBtn, self.m_sortBtn, self.m_contentTr = UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
        "Container/Mingwen/bg/mid/TypeSortBtn",
        "Container/Mingwen/bg/ItemScrollView/Viewport/ItemContent",
    })

    titleText.text = Language.GetString(2937)
    self.m_sortPriorityTexts = string_split(Language.GetString(2941), "|")

    self.m_mingwenList = {}
    self.m_mingwenItemList = {}
    self.m_seq = 0
    self.m_sortPriority = 0

    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/Mingwen/bg/ItemScrollView/Viewport/ItemContent",  Bind(self, self.UpdateItem))

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_sortBtn.gameObject, onClick)
end

function UIMingwenSurveyView:OnClick(go)
    if go.name == "backBtn" then
        self:CloseSelf()

    elseif go.name == "TypeSortBtn" then
        self.m_sortPriority = self.m_sortPriority + 1
        if self.m_sortPriority > CommonDefine.GongSu then
            self.m_sortPriority = CommonDefine.QuanBu
        end

        self:UpdateView()
    end
end

function UIMingwenSurveyView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_sortBtn.gameObject)
    base.OnDestroy(self)
end

function UIMingwenSurveyView:OnEnable(...)
    base.OnEnable(self, ...)
    
    self.m_sortPriority = CommonDefine.QuanBu

    self:UpdateView()
end

function UIMingwenSurveyView:UpdateView()
    self.m_mingwenList = self:GetSortMingwenList()

    if #self.m_mingwenItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, MingwenItemPrefab, 18, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local mingwenItem = MingwenItem.New(objs[i], self.m_contentTr, MingwenItemPrefab)
                    table_insert(self.m_mingwenItemList, mingwenItem)
                end
            end
            self.m_scrollView:UpdateView(true, self.m_mingwenItemList, self.m_mingwenList)
        end)
    else
        self.m_scrollView:UpdateView(true, self.m_mingwenItemList, self.m_mingwenList)
    end

    if self.m_sortPriority <= #self.m_sortPriorityTexts then
        self.m_buttonText.text = self.m_sortPriorityTexts[self.m_sortPriority + 1]
    end
end

function UIMingwenSurveyView:UpdateItem(item, realIndex)
    if self.m_mingwenList then
        if item and realIndex > 0 and realIndex <= #self.m_mingwenList then
            local data = self.m_mingwenList[realIndex]
            item:UpdateData(data)
        end
    end
end

function UIMingwenSurveyView:GetSortMingwenList()
    local MingwenCfgList = ConfigUtil.GetShenbingInscriptionCfgList()

    local mingwenList = {}
    for i, v in pairs(MingwenCfgList) do
        for _, type in ipairs(v.type) do
            if type == self.m_sortPriority then
                table_insert(mingwenList, v)
            end
        end
        if self.m_sortPriority == CommonDefine.QuanBu then
            table_insert(mingwenList, v)
        end
    end

    table_sort(mingwenList, function(l, r)
        if l.paixu ~= r.paixu then
            return l.paixu < r.paixu
        end
        return l.id < r.id
    end)

    return mingwenList
end

function UIMingwenSurveyView:OnDisable()
    

    for i, v in ipairs(self.m_mingwenItemList) do
        v:Delete()
    end
    self.m_mingwenItemList = {}

    base.OnDisable(self)
end

return UIMingwenSurveyView