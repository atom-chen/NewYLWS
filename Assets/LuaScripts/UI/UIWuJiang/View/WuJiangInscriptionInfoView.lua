local table_insert = table.insert
local table_remove = table.remove
local math_ceil = math.ceil

local WujiangMgr = Player:GetInstance().WujiangMgr
local ItemMgr = Player:GetInstance():GetItemMgr()
local GameObject = CS.UnityEngine.GameObject
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local UIUtil = UIUtil
local GameUtility = CS.GameUtility
local UILogicUtil = UILogicUtil
local string_format = string.format

local InscriptionSkillItem = require "UI.UIWuJiang.View.InscriptionSkillItem"
local InscriptionItem = require "UI.UIWuJiang.View.InscriptionItem"
local ItemDataClass = require "DataCenter.ItemData.ItemData"

local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local WuJiangInscriptionInfoView = BaseClass("WuJiangInscriptionInfoView")
local base = UIBaseItem

function WuJiangInscriptionInfoView:__init(go)

    self.gameObject = go
    self.transform = go.transform

    self.m_wujiangIndex = 0
    self.m_seq = 0
    
    self.m_inscriptionItemList = {}
    self.m_selectInscriptionItem = false

    self.m_inscriptionSkillItemList = {}
    self.m_attritemList = {}

    self:InitView()

    self:ShowSkillTips(false)

    self.m_attrList = {
        "max_hp", "mingzhong", "shanbi", "phy_atk",  "phy_baoji",  "phy_def","magic_atk",
        "magic_baoji", "magic_def", "baoji_hurt"
    }

    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    --这里规范点得放在onEnable中
    self.m_sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)

    self.m_recommendInscriptionItemList = {}

    self.m_seq = 0
end

function WuJiangInscriptionInfoView:__delete()

    self.m_attritemList = {}
    GameUtility.DestroyChild(self.m_attrParentTrans.gameObject)

    for i, v in ipairs(self.m_inscriptionSkillItemList) do
        v:Delete()
    end
    self.m_inscriptionSkillItemList = nil

    for i, v in ipairs(self.m_inscriptionItemList) do
        v:Delete()
    end
    self.m_inscriptionItemList = nil

    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)

    self.lastCombinationSkillIDDict = nil

    for i, v in ipairs(self.m_recommendInscriptionItemList) do
        v:Delete()
    end
    self.m_recommendInscriptionItemList = nil

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    self.gameObject = nil
    self.transform = nil
end

function WuJiangInscriptionInfoView:InitView()
    local titleText, title2Text, unloadBtnText
    titleText, title2Text, self.m_skillTipsText, self.m_inscriptionSkillEmptyText, self.m_recommendText, unloadBtnText = UIUtil.GetChildTexts(self.transform, {
        "TitleText",
        "Title2Text",
        "SkillTips/SkillTipsText",
        "InscriptionSkillEmptyText",
        "recommendText",
        "UnLoadBtn/UnLoadBtnText",
    })
    
    self.m_attrParentTrans, self.m_inscriptionSkillParentTrans, self.m_inscriptionParentTrans, 
    self.m_inscriptionSkillItemPrefab, self.m_inscriptionItemPrefab, self.m_attrTextPrefab,
    self.m_skillTips, self.m_bgBtn, self.m_recommendListTran, 
    self.m_unloadBtn = UIUtil.GetChildTransforms(self.transform, {
        "AttrList",
        "InscriptionSkillList",
        "InscriptionList",
        "prefab/InscriptionSkillItemPrefab",
        "prefab/InscriptionItemPrefab",
        "prefab/AttrTextPrefab",
        "SkillTips",
        "BgBtn",
        "recommendList",
        "UnLoadBtn",
    })
   
    self.m_inscriptionSkillItemPrefab = self.m_inscriptionSkillItemPrefab.gameObject
    self.m_inscriptionItemPrefab = self.m_inscriptionItemPrefab.gameObject
    self.m_attrTextPrefab = self.m_attrTextPrefab.gameObject
    self.m_skillTips = self.m_skillTips.gameObject

    titleText.text = Language.GetString(646)
    title2Text.text = Language.GetString(647)
    unloadBtnText.text = Language.GetString(656)
    self.m_inscriptionSkillEmptyText.text = Language.GetString(682)
    self.m_inscriptionSkillEmptyText = self.m_inscriptionSkillEmptyText.gameObject
    self.m_recommendText.text = Language.GetString(761)

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_bgBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_unloadBtn.gameObject, onClick)
end

function WuJiangInscriptionInfoView:OnClick(go)
    if go.name == "BgBtn" then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_CLICK_MASK, true)
    elseif go.name == "UnLoadBtn" then
        if self:CheckUnLoadInscription() then
            Player:GetInstance().InscriptionMgr:ReqEquipInscription(self.m_wujiangIndex)
        end
    end
end

function WuJiangInscriptionInfoView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_bgBtn.gameObject)
    base.OnDestroy(self)
end

function WuJiangInscriptionInfoView:UpdateData(wujiangIndex)
    self.m_wujiangIndex = wujiangIndex

    local wujiangData = WujiangMgr:GetWuJiangData(wujiangIndex)
    if not wujiangData then
        return
    end

    local inscriptions_detail_info =  wujiangData.inscriptions_detail_info
    if inscriptions_detail_info then
        
        self:UpdateInscriptionList(inscriptions_detail_info, wujiangData.tupo)

        self:UpdateSkillItemList(inscriptions_detail_info)

        self:UpdateAttrList(inscriptions_detail_info.attr)

        self:UpdateRecommendInscriptionList(wujiangData.id)

        self.m_lastWuJiangIndex = self.m_wujiangIndex
    end
end

function WuJiangInscriptionInfoView:CheckUnLoadInscription()
    local wujiangData = WujiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not wujiangData then
        return
    end

    local inscriptions_detail_info =  wujiangData.inscriptions_detail_info
    if inscriptions_detail_info then
        local inscription_list = inscriptions_detail_info.inscription_id_list
        if inscription_list and #inscription_list > 0 then
            return true
        end
    end

    UILogicUtil.FloatAlert(Language.GetString(658))
    return false
end

function WuJiangInscriptionInfoView:UpdateInscriptionList(inscriptions_detail_info, tupo)
    local inscription_list = inscriptions_detail_info.inscription_id_list
    
    if inscription_list then

        local function onItemClick(item)
            if not item then
                return
            end
            
            if self.m_selectInscriptionItem then
                self.m_selectInscriptionItem:SetOnSelectState(false)
            end

            item:SetOnSelectState(true)
            self.m_selectInscriptionItem = item

            local itemData = ItemMgr:GetItemData(item:GetItemID())
            if itemData == nil then --有可能背包里的item被消耗了  
                itemData = ItemDataClass.New(item:GetItemID(), 0)
            end
            
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_ITEM_CLICK, true, itemData)
        end

        local inscriptionEquipCount = UILogicUtil.GetInscriptionEquipCount(tupo)

        for i = 1, 9 do
            local inscriptionItem

            if i > #self.m_inscriptionItemList then
                local go = GameObject.Instantiate(self.m_inscriptionItemPrefab)
                inscriptionItem = InscriptionItem.New(go, self.m_inscriptionParentTrans)
                inscriptionItem:SetLocalPosition(Vector3.New(67.5 + (i - 1) * 149, -72.5))
                table_insert(self.m_inscriptionItemList, inscriptionItem)
            else
                inscriptionItem = self.m_inscriptionItemList[i]
            end

            local isLock = i > inscriptionEquipCount

            local inscriptionItemID = i <= #inscription_list and inscription_list[i] or nil
            inscriptionItem:SetData(inscriptionItemID, onItemClick, isLock, i, self.m_sortOrder)
        end

        self:CancelSelect()

        local equipInscriptionItemID = Player:GetInstance().InscriptionMgr:GetEquipInscriptionItemID()
        if equipInscriptionItemID > 0 then
            for i = #self.m_inscriptionItemList, 1, -1 do
                local inscriptionItemID = self.m_inscriptionItemList[i]:GetInscriptionItemID()
                if inscriptionItemID and inscriptionItemID == equipInscriptionItemID then
                    UIUtil.OnceTweenScale(self.m_inscriptionItemList[i]:GetTransform(), Vector3.one, 1.5)
                    self.m_inscriptionItemList[i]:ShowEquipEffect(true)
                    break
                end
            end
        end
    end
end

function WuJiangInscriptionInfoView:CancelSelect()
   
    if self.m_selectInscriptionItem then
        self.m_selectInscriptionItem:SetOnSelectState(false)
        self.m_selectInscriptionItem = nil
    end
end

function WuJiangInscriptionInfoView:UpdateAttrList(attr)
    if not attr then
        return
    end

    local list = {}
    for i, v in ipairs(self.m_attrList) do
        if attr[v] then
            table_insert(list, attr[v])
        end
    end

    for i, v in ipairs(list) do
        local attrItem
        if i > #self.m_attritemList then
            local go = GameObject.Instantiate(self.m_attrTextPrefab, self.m_attrParentTrans)
            attrItem = UIUtil.FindText(go.transform)
            table_insert(self.m_attritemList, attrItem)
        else
            attrItem = self.m_attritemList[i]
        end
        
        local attrtype = CommonDefine[self.m_attrList[i]]
        if attrtype then
           
            local str = Language.GetString(attrtype + 10).."+"..UILogicUtil.GetWuJiangSecondAttrVal(self.m_attrList[i], v)
            
            if v > 0 then
                str = string_format(Language.GetString(765), str)
            end

           -- print("attrStr ",str, attrItem.text, attrItem.text ~= str)
            --print("attrStr ",self.m_lastWuJiangIndex, self.m_wujiangIndex)

            if self.m_lastWuJiangIndex == self.m_wujiangIndex and attrItem.text ~= '' and attrItem.text ~= str then
                UIUtil.OnceTweenScale(attrItem.transform, Vector3.one, 1.5)
            end

            attrItem.text = str
        end
    end
end

function WuJiangInscriptionInfoView:UpdateSkillItemList(inscriptions_detail_info)
    local combination_list = inscriptions_detail_info.combination_list
    if combination_list then

        

        local isInitedSkillDict = self.lastCombinationSkillIDDict ~= nil
        if not isInitedSkillDict then
            self.lastCombinationSkillIDDict = {}
        end

        local tmpSkillDict = {}
       
        for i, v in ipairs(combination_list) do
            local inscriptionSkillItem
            if i > #self.m_inscriptionSkillItemList then
                local go = GameObject.Instantiate(self.m_inscriptionSkillItemPrefab)
                inscriptionSkillItem = InscriptionSkillItem.New(go, self.m_inscriptionSkillParentTrans)
                table_insert(self.m_inscriptionSkillItemList, inscriptionSkillItem)
            else
                inscriptionSkillItem = self.m_inscriptionSkillItemList[i]
            end

            local function OnClickSkillItem(skillData, pos)
                if skillData then
                    local goList = {}
                    local posList = skillData.pos_list
                    if posList then
                        for i, v in ipairs(posList) do
                            local go = self.m_inscriptionItemList[v]:GetGameObject()
                            if not IsNull(go) then
                                table_insert(goList, go)
                            end
                        end 
                    end
                    UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangSkillTipsView, pos, skillData, goList, i)
                end
                -- print("skillData ", skillData)
            end
            
            inscriptionSkillItem:SetData(v, OnClickSkillItem, self.m_sortOrder)

            --第一次不播特效
            if isInitedSkillDict then
                if not self.lastCombinationSkillIDDict[v.skill_id] then
                    inscriptionSkillItem:ShowJihuoEffect(true)
                end
            end
            tmpSkillDict[v.skill_id] = true
        end

        self.lastCombinationSkillIDDict = tmpSkillDict

        local delCount = #self.m_inscriptionSkillItemList - #combination_list
        local index = #self.m_inscriptionSkillItemList - delCount + 1
        if delCount > 0 then
            for i = #self.m_inscriptionSkillItemList, index, -1 do
                self.m_inscriptionSkillItemList[i]:Delete()
                table_remove(self.m_inscriptionSkillItemList, i)
            end
        end

        self.m_inscriptionSkillEmptyText:SetActive(#combination_list == 0)
    end
end

function WuJiangInscriptionInfoView:ShowSkillTips(isShow)
    self.m_skillTips:SetActive(isShow)
    self.m_skillTipsText.text = ""
end

function WuJiangInscriptionInfoView:GetSelectInscriptionItem()
    return self.m_selectInscriptionItem
end



function WuJiangInscriptionInfoView:UpdateRecommendInscriptionList(wujiangID)
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
    if wujiangCfg then
        local mingqianList = wujiangCfg.mingqianList
        if mingqianList then
            local createCount = #mingqianList - #self.m_recommendInscriptionItemList

            function loadCallBack()
                for i, v in ipairs(self.m_recommendInscriptionItemList) do
                    if i > #mingqianList then
                        v:SetActive(false)
                    else
                        local itemID = mingqianList[i]
                        local itemCfg = ConfigUtil.GetItemCfgByID(itemID)
                        if itemCfg then
                            v:SetActive(true)
                            self:UpdateInscriptionItem(v, itemCfg)
                        end
                    end
                end
            end

            if createCount > 0 then
                if self.m_seq == 0 then
                    self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq() 

                    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, BagItemPrefabPath, createCount, function(objs)
                        self.m_seq = 0
                        if objs then
                            for i = 1, #objs do
                                if not IsNull(objs[i]) then
                                    local bagItem = BagItemClass.New(objs[i], self.m_recommendListTran, BagItemPrefabPath)
                                    if bagItem then
                                        bagItem:ShowIconMask(false)
                                        bagItem:ShowFrame(false)
                                        table_insert(self.m_recommendInscriptionItemList, bagItem)
                                    end
                                end
                            end
                           
                            loadCallBack()
                        end
                    end)
                end
            else
                loadCallBack()
            end
        end   
    end
end


function WuJiangInscriptionInfoView:UpdateInscriptionItem(inscriptionItem, itemCfg, count)
    count = count or 0
    if inscriptionItem then
        local itemIconParam = ItemIconParam.New(itemCfg, count)
        itemIconParam.onClickShowDetail = true
        inscriptionItem:UpdateData(itemIconParam)
    end
end

return WuJiangInscriptionInfoView