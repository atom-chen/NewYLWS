local Vector3 = Vector3
local Vector2 = Vector2
local string_format = string.format
local math_min = math.min
local math_ceil = math.ceil
local table_insert = table.insert
local tonumber = tonumber
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local CommonDefine = CommonDefine
local UIWindowNames = UIWindowNames
local ItemData = ItemData
local UIManagerInstance = UIManagerInst
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local ShenBingMgr = Player:GetInstance():GetShenBingMgr()

local ShenBingInscriptionItem = require "UI.UIWuJiang.View.ShenBingInscriptionItem"
local ShenBingInscriptionItemPath = "UI/Prefabs/Common/ShenBingInscriptionItemPrefab.prefab"

local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local DetailShenbingHelper = BaseClass("DetailShenbingHelper")

function DetailShenbingHelper:__init(bagTr, bagView)
    self.m_bagView = bagView

    self.m_shenbingDetailContainer, self.m_shenbingInscriptionItemParent, self.m_itemCreatePos = 
    UIUtil.GetChildTransforms(bagTr, { 
        "ShenbingDetailContainer",
        "ShenbingDetailContainer/ShenbingInscriptionList",
        "ShenbingDetailContainer/IconRoot"
    })

    self.m_attrText1, self.m_attrText2, self.m_attrText3, 
    self.m_shenbingStageText, self.m_masterText, self.m_shenbingNameText = 
    UIUtil.GetChildTexts(bagTr, {
        "ShenbingDetailContainer/AttrTextGrid/AttrText1",
        "ShenbingDetailContainer/AttrTextGrid/AttrText2",
        "ShenbingDetailContainer/AttrTextGrid/AttrText3",
        "ShenbingDetailContainer/IconRoot/Info/StageText",
        "ShenbingDetailContainer/IconRoot/MasterText",
        "ShenbingDetailContainer/IconRoot/Info/ShenbingNameText"
    })

    self.m_attrTextList = { self.m_attrText1, self.m_attrText2, self.m_attrText3 }
 
    self.m_itemLockSpt = bagView:AddComponent(UIImage, "ShenbingDetailContainer/IconRoot/ShenbingLockSpt", AtlasConfig.DynamicLoad)

    self.m_itemDetailTmpItem = nil      --用于展示新品详细信息的临时item
    self.m_bagItemSeq = 0
    self.m_shenbingInscriptionList = {}

    self.m_showing = false
    self:HandleClick()
end

function DetailShenbingHelper:__delete()
    self:RemoveClick()
    self:Close()
    self.m_bagView = nil
end

function DetailShenbingHelper:Close()
    self.m_shenbingDetailContainer.gameObject:SetActive(false)

    if self.m_itemDetailTmpItem then
        self.m_itemDetailTmpItem:Delete()
        self.m_itemDetailTmpItem = nil
    end

    for i,v in ipairs(self.m_attrTextList) do
        v.text = ""
    end
    
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    self.m_bagItemSeq = 0
    
    for i,v in ipairs(self.m_shenbingInscriptionList) do
        v:Delete()
    end
    self.m_shenbingInscriptionList = {}

    self.m_showing = false
end

function DetailShenbingHelper:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_itemLockSpt.gameObject, onClick)
end

function DetailShenbingHelper:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_itemLockSpt.gameObject)
end

function DetailShenbingHelper:OnClick(go, x, y)
    local goName = go.name

    if goName == "ShenbingLockSpt" then
        self:OnItemLockSptClick()
    end
end


--点击物品详细信息界面的锁按钮
function DetailShenbingHelper:OnItemLockSptClick()
    if self.m_bagView:GetCurrSelectBagItem() then
        self.m_bagView:GetCurrSelectBagItem():ChgLockState()
    end
end

function DetailShenbingHelper:OnUseBtnClick()
    -- if self.selectItem then
    --     local itemMainType = self.selectItem:GetItemMainType()
    --     if itemMainType == CommonDefine.ItemMainType_MingQian then

    --     elseif itemMainType == CommonDefine.ItemMainType_Mount then

    --     elseif itemMainType == CommonDefine.ItemMainType_ShenBing then

    --     elseif itemMainType == CommonDefine.ItemMainType_XinWu then
            
    --     elseif itemMainType == CommonDefine.ItemMainType_OtherItem then
    --         self:OpenItemUseWindow(true)
    --     end
    -- end
end

function DetailShenbingHelper:UpdateInfo()
    local selectItem = self.m_bagView:GetCurrSelectBagItem()
    if not selectItem then
        return
    end

    local itemCfg = selectItem:GetItemCfg()
    if not itemCfg then
        return
    end
    
    local shenbingCfg = ConfigUtil.GetShenbingCfgByID(selectItem:GetItemID())
    if not shenbingCfg then
        return
    end

    local index = selectItem:GetIndex()
    local shenbingData = ShenBingMgr:GetShenBingDataByIndex(index)
    if not shenbingData then
        return
    end

    self.m_showing = true

    local stage = UILogicUtil.GetShenBingStageByLevel(shenbingData:GetStage())

    self.m_shenbingDetailContainer.gameObject:SetActive(true)

    local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, 0, nil, false, false, false,
        false, false, shenbingData:GetStage())

    --显示物品图标
    if not self.m_itemDetailTmpItem then
        self.m_bagItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObject(self.m_bagItemSeq, BagItemPrefabPath, function(go)
            self.m_bagItemSeq = 0
            if not go then
                return
            end
            
            self.m_itemDetailTmpItem = BagItemClass.New(go, self.m_itemCreatePos, BagItemPrefabPath)
            self.m_itemDetailTmpItem:UpdateData(itemIconParam)
        end)
    else
        self.m_itemDetailTmpItem:UpdateData(itemIconParam)
    end
    
    --更新锁的状态
    local canLock = selectItem:NeedShowLock()
    local isLocked = selectItem:GetLockState() or false
    self:ChangeLock(canLock, isLocked)

    self.m_shenbingNameText.text = UILogicUtil.GetShenBingNameByStage(shenbingData:GetStage(), shenbingCfg)
    if shenbingData:GetStage() > 0 then
        self.m_shenbingStageText.text = string_format("+%d", shenbingData:GetStage())
    else
        self.m_shenbingStageText.text = ""
    end

    self.m_masterText.text = string_format(Language.GetString(760), shenbingCfg.wujiang_name)

    self:UpdateAttrList(shenbingData)
    self:UpdateMingWenList(shenbingData)
end

function DetailShenbingHelper:UpdateAttrList(shenbingData)
    local attrList = shenbingData:GetAttrList()
    if attrList then
        local index = 1
        local nameList = CommonDefine.second_attr_name_list
        for _, name in ipairs(nameList) do
            local val = attrList[name]
            if val then
                local attrType = CommonDefine[name]
                if attrType then
                    if index <= #self.m_attrTextList then
                        local attrText = self.m_attrTextList[index]
                        attrText.text = Language.GetString(attrType + 10)..string_format("<color=#17f100>+%d</color>", val)
                        index = index + 1
                    end
                end
            end
        end
    end
end

function DetailShenbingHelper:UpdateMingWenList(shenbingData)
    
    local selectItem = self.m_bagView:GetCurrSelectBagItem()
    local index = selectItem:GetIndex()
    local shenbingData = ShenBingMgr:GetShenBingDataByIndex(index)
    local shenbingCfg = ConfigUtil.GetShenbingCfgByID(shenbingData:GetItemID())
    local insCount = 3
    if shenbingCfg then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(shenbingCfg.wujiang_id)
        if wujiangCfg then
            if wujiangCfg.rare == CommonDefine.WuJiangRareType_3 then
                insCount = 2
            elseif wujiangCfg.rare == CommonDefine.WuJiangRareType_4 then
                insCount = 3
            end
        end
    end

    local mingwenList = shenbingData:GetMingWenList()
    local function loadCallBack()
        for i, v in ipairs(self.m_shenbingInscriptionList) do
            local mingwenData = mingwenList and mingwenList[i] or nil
            v:GetGameObject():SetActive(true)
            v:SetData(i, mingwenData)
            if i > insCount then
                v:GetGameObject():SetActive(false)
            end
        end
    end

    if #self.m_shenbingInscriptionList == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, ShenBingInscriptionItemPath, 3, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local bagItem = ShenBingInscriptionItem.New(objs[i], self.m_shenbingInscriptionItemParent, ShenBingInscriptionItemPath)
                    table_insert(self.m_shenbingInscriptionList, bagItem)
                end

                loadCallBack()
            end
        end)
    else
        loadCallBack()
    end
end

function DetailShenbingHelper:ChangeLock(canLock, isLocked)
    if not self.m_showing then
        return
    end

    if canLock then
        UILogicUtil.SetLockImage(self.m_itemLockSpt, isLocked)
    else
        self.m_itemLockSpt:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
    end
end

return DetailShenbingHelper