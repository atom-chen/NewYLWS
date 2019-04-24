local string_split = string.split
local table_insert = table.insert

local ConfigUtil = ConfigUtil
local GameObject = CS.UnityEngine.GameObject
local CommonDefine = CommonDefine
local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab

local UIInscriptionStageItem = require "UI.UIWuJiang.View.UIInscriptionStageItem"

local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local UIInscriptionAutoMergeView = BaseClass("UIInscriptionAutoMergeView", UIBaseView)
local base = UIBaseView


function UIInscriptionAutoMergeView:OnCreate()
    base.OnCreate(self)
  
    self.m_seq = 0
    self.m_stageItemList = {}
    self.m_typeItemList = {}
    self.m_inscriptionItemIDList = { 21110, 21101 ,21119, 21128 ,21130 ,21129 ,21131 ,21132, 21133, 21134 }

    self:InitView()
end

function UIInscriptionAutoMergeView:InitView()
    local descText, descText2, mergeBtnText
    descText, descText2, mergeBtnText, self.m_tongqianText = UIUtil.GetChildTexts(self.transform, {
        "Container/DescText",
        "Container/DescText2",
        "Container/Merge_BTN/MergeBtnText",
        "Container/Merge_BTN/TongQianImage/TongQianText"
    })

    descText.text = Language.GetString(678)
    descText2.text = Language.GetString(679)
    mergeBtnText.text = Language.GetString(671)

    self.m_closeBtn, self.m_mergeBtn, self.m_inscriptionStagePrefab, self.m_inscriptionStageParent, self.m_inscriptionTypeParent, 
    self.m_tongQianImageTrans = 
    UIUtil.GetChildTransforms(self.transform, {
        "CloseBtn",
        "Container/Merge_BTN",
        "InscriptionStagePrefab",
        "Container/InscriptionStageList",
        "Container/InscriptionTypeList",
        "Container/Merge_BTN/TongQianImage"
    })

    self.m_inscriptionStagePrefab = self.m_inscriptionStagePrefab.gameObject

    self.m_stageNameTexts = string_split(Language.GetString(680), "|")

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent( self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_mergeBtn.gameObject, onClick)
    
end

function UIInscriptionAutoMergeView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_mergeBtn.gameObject)
    base.OnDestroy(self)
end

function UIInscriptionAutoMergeView:OnEnable(...)
    base.OnEnable(self, ...)
    

    self:UpdateData()
end

function UIInscriptionAutoMergeView:UpdateData()

    local startIndex = CommonDefine.MingQian_Stage_1
    local endIndex = CommonDefine.MingQian_Stage_4

    local function onItemClick2(item)
        if not item then
            return
        end

        self:UpdateCost()
    end

    for i = startIndex, endIndex do
        local go = GameObject.Instantiate(self.m_inscriptionStagePrefab)
        local stageItem = UIInscriptionStageItem.New(go, self.m_inscriptionStageParent)
        table_insert(self.m_stageItemList, stageItem)
        stageItem:SetLocalPosition(Vector3.New(0, -93.66 * (i - 1), 0))
        stageItem:UpdateData(i , self.m_stageNameTexts[i], i == 1 and true or false, onItemClick2)
    end

    local function onItemClick(item)
        if not item then
            return
        end
        
        self:UpdateCost()
    end

    if self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, BagItemPrefabPath, 10, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local inscriptionItem = BagItemClass.New(objs[i], self.m_inscriptionTypeParent, BagItemPrefabPath)
                    table_insert(self.m_typeItemList, inscriptionItem)
                    self:UpdateInscriptionItem(inscriptionItem, self.m_inscriptionItemIDList[i], 0, onItemClick)
                    inscriptionItem:SetOnSelectState(true)
                end
            end
        end)
    end

    self:UpdateCost()
end

function UIInscriptionAutoMergeView:UpdateInscriptionItem(inscriptionItem, itemID, count, func)
    count = count or 0
    local itemCfg = ConfigUtil.GetItemCfgByID(itemID)
    if inscriptionItem and itemCfg then
        local itemIconParam = ItemIconParam.New(itemCfg, count, nil, 0, func, false, true)
        itemIconParam.isShowCheck = true
        inscriptionItem:UpdateData(itemIconParam)
    end
end

function UIInscriptionAutoMergeView:OnDisable()

    for i = 1, #self.m_stageItemList do
        self.m_stageItemList[i]:Delete()
    end

    self.m_stageItemList = {}

    for i = 1, #self.m_typeItemList do
        self.m_typeItemList[i]:Delete()
    end

    self.m_typeItemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    base.OnDisable(self)
end

function UIInscriptionAutoMergeView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf()

    elseif go.name == "Merge_BTN" then

        local stageList, typeList = self:GetStageListAndTypeList()
        if #stageList == 0 or #typeList == 0 then
            UILogicUtil.FloatAlert(Language.GetString(681))
            return
        end

        Player:GetInstance().InscriptionMgr:ReqAutoMergeInscription(stageList, typeList)

    end
end

function UIInscriptionAutoMergeView:UpdateCost()

    local stageList, typeList = self:GetStageListAndTypeList()

  --[[   local stageDict = {}
    local typeDict = {}

    for i, v in ipairs(stageList) do
        stageDict[v] = true
    end
    for i, v in ipairs(typeList) do
        typeDict[v] = true
    end ]]

    local count = Player:GetInstance().InscriptionMgr:CalcAutoMergeCost(stageList, typeList)
    self.m_tongqianText.text = count

    coroutine.start(self.FitTongQianPos, self)
end

function UIInscriptionAutoMergeView:FitTongQianPos()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_tongQianImageTrans, self.m_mergeBtn)
end

function UIInscriptionAutoMergeView:GetStageListAndTypeList()
    local stageList = {}
    local typeList = {}
    for i, v in ipairs(self.m_stageItemList) do
        if v then
            if v:IsSelect() then
                table_insert(stageList, v.Stage)
            end
        end
    end

    for i, v in ipairs(self.m_typeItemList) do
        if v then
            if v:IsOnSelected() then
                local itemID = v:GetItemID()
                local inscriptionStageInfo = ConfigUtil.GetInscriptionStageCfgByID(itemID)
                if inscriptionStageInfo then
                    table_insert(typeList, inscriptionStageInfo.type)
                end
            end
        end
    end
    return stageList, typeList
end


return UIInscriptionAutoMergeView
