local CommonDefine = CommonDefine
local table_insert = table.insert
local PBUtil = PBUtil

local SweepItem = require "UI.CampsRush.CampsRushSweepItem"
local SweepItemPrefabPath = "UI/Prefabs/CampsRush/CampsRushSweepItem.prefab"

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local SpringContent = CS.SpringContent
local itemHeight = 95

local UICampsRushSweepAwardView = BaseClass("UICampsRushSweepAwardView", UIBaseView)
local base = UIBaseView

function UICampsRushSweepAwardView:OnCreate()
    base.OnCreate(self)

    self.m_totalAwardsLoaderSeq = 0
    self.m_totalAwardParamList = nil
    self.m_totalAwardItemList = {}
    self.m_sweepItemLoaderSeq = 0
    self.m_sweepDataList = nil
    self.m_sweepItemList = {}

    self.m_awardScrollView = self:AddComponent(LoopScrowView, "BgRoot/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateSweepAwardItem))
    self.m_totalAwardcrollView = self:AddComponent(LoopScrowView, "BgRoot/TotalItemScrollView/Viewport/TotalItemContent", Bind(self, self.UpdateTotalAwardItem))

    local titleText, totalAwardText, confirmBtnText
    titleText, totalAwardText, confirmBtnText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
        "BgRoot/totalAwardText",
        "BgRoot/confirm_BTN/confirmBtnText",
    })
    self.m_closeBtn, self.m_inputMask, self.m_awardParent, self.m_totalAwardParent, self.m_confirmBtn = UIUtil.GetChildRectTrans(self.transform, {
        "CloseBtn",
        "InputMask",
        "BgRoot/ItemScrollView/Viewport/ItemContent",
        "BgRoot/TotalItemScrollView/Viewport/TotalItemContent",
        "BgRoot/confirm_BTN"
    })
    
    self.m_inputMask = self.m_inputMask.gameObject
    self.m_awardItemContent = self.m_awardParent.gameObject

    titleText.text = Language.GetString(1220)
    totalAwardText.text = Language.GetString(1221)
    confirmBtnText.text = Language.GetString(10)

end

function UICampsRushSweepAwardView:OnDisable()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_totalAwardsLoaderSeq)
    self.m_totalAwardsLoaderSeq = 0
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_sweepItemLoaderSeq)
    self.m_sweepItemLoaderSeq = 0

    for _, item in pairs(self.m_totalAwardItemList) do
        item:Delete()
    end
    self.m_totalAwardItemList = {}

    for _, item in pairs(self.m_sweepItemList) do
        item:Delete()
    end
    self.m_sweepItemList = {}
    self.itemDict = {}

    self.m_springContent = nil

    self:RemoveClick()
    base.OnDisable(self)
end

function UICampsRushSweepAwardView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, sweepDataList = ...
    self.m_sweepDataList = sweepDataList
    
    self:ResetData()

    self:CreateSweepAwards()

    self.m_totalAwardParamList = self:GetTotalAwardParamList()
    -- self:CreateTotalAwards()
    
    self:HandleClick()
end

function UICampsRushSweepAwardView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_inputMask.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_confirmBtn.gameObject, onClick)
end

function UICampsRushSweepAwardView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_inputMask.gameObject)
    UIUtil.RemoveClickEvent(self.m_confirmBtn.gameObject)
end

function UICampsRushSweepAwardView:OnClick(go, x, y)
    local name = go.name 
    if name == "CloseBtn" then
        self:CloseSelf()
    elseif name == "confirm_BTN" then
        self:CloseSelf()
    elseif name == "InputMask" then
        self.m_inputMask:SetActive(false)
        self:CancelMove()
    end
end

function UICampsRushSweepAwardView:CreateTotalAwards()
    if #self.m_totalAwardItemList == 0 and self.m_totalAwardsLoaderSeq == 0  then
        self.m_totalAwardsLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_totalAwardsLoaderSeq, CommonAwardItemPrefab, #self.m_totalAwardParamList, function(objs)
            self.m_totalAwardsLoaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local bagItem = CommonAwardItem.New(objs[i], self.m_totalAwardParent, CommonAwardItemPrefab)
                    bagItem:SetLocalScale(Vector3.New(0.6, 0.6, 1))
                    table_insert(self.m_totalAwardItemList, bagItem)
                end
                self.m_totalAwardcrollView:UpdateView(true, self.m_totalAwardItemList, self.m_totalAwardParamList)
            end
        end)
    end
end

function UICampsRushSweepAwardView:UpdateTotalAwardItem(item, realIndex)
    if self.m_totalAwardParamList then
        if item and realIndex > 0 and realIndex <= #self.m_totalAwardParamList then
            local itemIconParam = self.m_totalAwardParamList[realIndex]
            item:UpdateData(itemIconParam)
        end
    end
end

function UICampsRushSweepAwardView:GetTotalAwardParamList()
    -- todo 使用正式的itemdata
    local totalAwardIconParamList = {}
    
    local CreateAwardParamFromAwardData = PBUtil.CreateAwardParamFromAwardData

    for _, sweepData in ipairs(self.m_sweepDataList) do
        for _, awardData in ipairs(sweepData.awards) do

            local tmpParam = PBUtil.CreateAwardParamFromAwardData(awardData)

            local isThere = false
            for _, totalParam in ipairs(totalAwardIconParamList) do
                if totalParam:IsEqual(tmpParam) then
                    totalParam.itemCount = totalParam.itemCount + tmpParam.itemCount
                    isThere = true
                    break
                end
            end

            if not isThere then
                table_insert(totalAwardIconParamList, tmpParam)
            end
        end
    end

    return totalAwardIconParamList
end

function UICampsRushSweepAwardView:CreateSweepAwards()

    self.m_isMoveIng = true
    self.m_inputMask:SetActive(true)

    if #self.m_sweepItemList == 0 and self.m_sweepItemLoaderSeq == 0  then
        self.m_sweepItemLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_sweepItemLoaderSeq, SweepItemPrefabPath, 8, function(objs)
            self.m_sweepItemLoaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local sweepItem = SweepItem.New(objs[i], self.m_awardParent, SweepItemPrefabPath)
                    table_insert(self.m_sweepItemList, sweepItem)
                end
                self.m_awardScrollView:UpdateView(true, self.m_sweepItemList, self.m_sweepDataList)
               
                self.m_index = 0
                self.m_deltaTime = 0.2
            end
        end)
    end
end

function UICampsRushSweepAwardView:UpdateSweepAwardItem(item, realIndex)
    if self.m_sweepDataList then
        if item and realIndex > 0 and realIndex <= #self.m_sweepDataList then
            local data = self.m_sweepDataList[realIndex]
            item:SetData(self.m_sweepDataList[realIndex])

            self:CheckItem(item, realIndex)
            
            if not self.itemDict then
                self.itemDict = {}
            end
            self.itemDict[realIndex] = item
        end
    end
end

function UICampsRushSweepAwardView:Update()
    
    if self.m_index == -1 or self.m_deltaTime <= 0 then
        return
    end

    if self.m_sweepDataList and self.m_index >= #self.m_sweepDataList then
        return
    end

    if self.m_deltaTime > 0 then
        self.m_deltaTime = self.m_deltaTime - Time.deltaTime
        if self.m_deltaTime <= 0 then
            self.m_newItemBottomY = self.m_newItemBottomY + itemHeight
            local sizeDelta = self.m_awardScrollView:GetScrollRectSize()

            if self.m_newItemBottomY > sizeDelta.y then
                local y = self.m_newItemBottomY - sizeDelta.y
                
                if self.m_index == #self.m_sweepDataList - 1 then
                    self.m_springContent = SpringContent.Begin(self.m_awardItemContent, Vector3.New(0, y, 0), 8, function()
                        self:CancelMove()
                    end)
                else
                    self.m_springContent = SpringContent.Begin(self.m_awardItemContent, Vector3.New(0, y, 0), 8)
                end
            end

            self.m_deltaTime = 0.2
            self.m_index = self.m_index + 1

            if self.itemDict[self.m_index] then
                self.itemDict[self.m_index]:SetActive(true)
            else
                Logger.Log("index error ", self.m_index)
            end

            if self.m_index == #self.m_sweepDataList then
                self:ResetData()
            end
        end
    end
end

function UICampsRushSweepAwardView:ShowSweepItemList(bShow)
    for i, v in ipairs(self.m_sweepItemList) do
        if i > #self.m_sweepDataList then
            v:SetActive(false)
        else
            v:SetActive(bShow)
        end
    end
end

function UICampsRushSweepAwardView:ResetData()
    self.m_deltaTime = 0
    self.m_isMoveIng = false
    self.m_index = -1
    self.m_newItemBottomY = 0
end

function UICampsRushSweepAwardView:CheckItem(item, realIndex)
    if self.m_isMoveIng then
        if realIndex ~= self.m_index then
            item:SetActive(false)
        end
    end
end

function UICampsRushSweepAwardView:CancelMove()
    self.m_inputMask:SetActive(false)

    self:ResetData()

    self:ShowSweepItemList(true)

    self:CreateTotalAwards()
    UIUtil.DisableSpringContent(self.m_springContent)
end

return UICampsRushSweepAwardView