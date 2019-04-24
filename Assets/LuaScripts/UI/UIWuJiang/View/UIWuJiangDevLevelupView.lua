local string_format = string.format
local tostring = tostring
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local math_ceil = math.ceil
local string_split = string.split
local tonumber = tonumber
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility

local Language = Language
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local ItemMgr = Player:GetInstance():GetItemMgr()

local UIWuJiangDevLevelupView = BaseClass("UIWuJiangDevLevelupView" , UIBaseItem)
local base = UIBaseItem



local BagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local WuJiangMgr = Player:GetInstance().WujiangMgr

function UIWuJiangDevLevelupView:OnCreate()
    base.OnCreate(self)
    
    self.m_wujiangIndex = 0
    self.m_seq = 0

    self.m_expIdList = { 20001, 20002, 20003 }
    self.m_expItem_list = { }
  
    self.m_reqExpData = {
        itemId = 0,
        count = 0,
        addExp = 0
    }

    self.m_tmpWujiangData = { }

    self.m_layerName = UILogicUtil.FindLayerName(self.transform)

    self:ResetFeedData()

    self:InitView()
end

function UIWuJiangDevLevelupView:InitView()

    local titleText
    self.m_expSilder = UIUtil.FindSlider(self.transform, "ExpSilder")
    self.m_expText, self.m_levelText, titleText = UIUtil.GetChildTexts(self.transform, {
        "ExpSilder/ExpText",
        "Level/LvText",
        "ItemList/bg/titleBg/titleText"
    })

    self.m_ItemParentTrans = UIUtil.GetChildTransforms(self.transform, {
        "ItemList"
    })

    titleText.text = Language.GetString(649)
end

function UIWuJiangDevLevelupView:OnDisable()

    base.OnDisable(self)
    
    self:ShowUpLvEffect(false)
end

function UIWuJiangDevLevelupView:OnDestroy()
    for i, v in ipairs(self.m_expItem_list) do
        UIUtil.RemoveEvent(v:GetGameObject())
        GameUtility.SetUIGray(v:GetGameObject(), false)   
        v:Delete()
    end
    
    self.m_expItem_list = { }

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    if self.m_sliderEffect then
        self.m_sliderEffect:Delete()
        self.m_sliderEffect = nil

        UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    end
    base.OnDestroy(self)
end

function UIWuJiangDevLevelupView:UpdateData(wujiangIndex)

    self.m_wujiangIndex = wujiangIndex
    local wujiangData = Player:GetInstance().WujiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not wujiangData then
        return
    end

    self:UpdateExp(wujiangData)

    if self.m_lastLevel and  self.m_lastLevel ~= wujiangData.level then
        self:ShowUpLvEffect(true)
    end

    self.m_lastLevel = wujiangData.level

    local function LoadCallback()
        for i = 1, #self.m_expIdList do
            local bagItem = self.m_expItem_list[i]
            local itemID = self.m_expIdList[i]
            local count = ItemMgr:GetItemCountByID(itemID)
            self:UpdateItem(bagItem, itemID, count)

            GameUtility.SetUIGray(bagItem:GetGameObject(), count == 0)   
        end
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, "UIWuJiangDevelop")
    end


    if #self.m_expItem_list == 0 then
        --未创建

        if self.m_seq == 0 then
            self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, BagItemPrefabPath, #self.m_expIdList, function(objs)
                if objs then
                    for i = 1, #objs do
                        local bagItem = BagItem.New(objs[i], self.m_ItemParentTrans, BagItemPrefabPath)
                        bagItem.m_gameObject.name = self.m_expIdList[i]
                        bagItem:SetLocalPosition(Vector3.New(-223 + (i - 1) * 200, 256))
                        self:HandleExpItemPress(bagItem:GetGameObject())
                        table_insert(self.m_expItem_list, bagItem)
                    end

                    LoadCallback()
                end
            end)
        end
    else
        LoadCallback()
    end
end

function UIWuJiangDevLevelupView:UpdateItem(bagItem, itemID, count)
    count = count or 0
    local itemCfg = ConfigUtil.GetItemCfgByID(itemID)
    if bagItem and itemCfg then
        local itemIconParam = ItemIconParam.New(itemCfg, count)
        bagItem:UpdateData(itemIconParam)
    end
end

function UIWuJiangDevLevelupView:SimulationUpdateExpItem(itemID, count)
    for i, v in ipairs(self.m_expItem_list) do
        if v then
            local expItemID = v:GetItemID()
            if expItemID == itemID then
                count = math_ceil(count)
                v:UpdateItemCount(count)
                break
            end
        end
    end
end

function UIWuJiangDevLevelupView:ClearSimulationData()
    for i, v in ipairs(self.m_expItem_list) do
        if v then
            local expItemID = v:GetItemID()
            v:UpdateItemCount(ItemMgr:GetItemCountByID(expItemID))
        end
    end
end

function UIWuJiangDevLevelupView:UpdateExp(wujiangData)
    -- wujiangData， 可能用临时数据

    local wuJiangLevelCfg = ConfigUtil.GetWuJiangLevelCfgByID(wujiangData.level)
    if not wuJiangLevelCfg then
        return
    end

    local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(wujiangData.star)
    if not wujiangStarCfg then
        return
    end

    self.m_levelText.text = string_format(Language.GetString(648), wujiangData.level, wujiangStarCfg.level_limit)
    self.m_expText.text = string_format(Language.GetString(630), wujiangData.exp, wuJiangLevelCfg.need_exp)
    self.m_expSilder.value = wujiangData.exp / wuJiangLevelCfg.need_exp
end

function UIWuJiangDevLevelupView:HandleExpItemPress(expItemGo)
   
    if IsNull(expItemGo) then
        return
    end

    --按下
    local touch_begin = function(go, x, y)
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "UIWuJiangDevLevelup")
        -- print("touch_begin ", self.m_expItemNameOnPress)

        DOTweenShortcut.DOScale(go.transform, 0.9, 0.2)

        if self.m_expItemNameOnPress == "" then
            
           local itemID = tonumber(go.name)
           self.m_onPressItemNum = ItemMgr:GetItemCountByID(itemID)
           
           if self.m_onPressItemNum <= 0 then
                UILogicUtil.FloatAlert(Language.GetString(644))
                return
           end

           local itemFuncCfg = ConfigUtil.GetItemFuncCfgByID(itemID)
           if not itemFuncCfg then
               return
           end

           self.m_reqExpData.itemId = itemID
           self.m_reqExpData.addExp = itemFuncCfg.func_value1
           
           self.m_isOnPressExp = true
           self.m_expItemNameOnPress = go.name

           self:SetTmpWuJiangData()
           
        --    print("self.m_expItemNameOnPress ", self.m_expItemNameOnPress, itemID)
           --显示特效
        end
    end

    --松开
    local touch_end = function (go, x, y)

        DOTweenShortcut.DOScale(go.transform, 1, 0.2)

        --print("touch_end", go.name == self.m_expItemNameOnPress, self.m_isOnPressExp)
        if go.name == self.m_expItemNameOnPress and self.m_isOnPressExp then
           self:EndPressExpItem()
        end
    end
   
    UIUtil.AddDownEvent(expItemGo, touch_begin)
    UIUtil.AddUpEvent(expItemGo, touch_end)
end

function UIWuJiangDevLevelupView:SetTmpWuJiangData()
    
    local wujiangData = Player:GetInstance().WujiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not wujiangData then
        return
    end

    self.m_tmpWujiangData.level = wujiangData.level
    self.m_tmpWujiangData.exp = wujiangData.exp
    self.m_tmpWujiangData.star = wujiangData.star
    self.m_tmpWujiangData.id = wujiangData.id
    self.m_tmpWujiangData.index = self.m_wujiangIndex
end


function UIWuJiangDevLevelupView:EndPressExpItem()
    
    local itemNum = ItemMgr:GetItemCountByID(self.m_reqExpData.itemId)
    --print("itemNum ",itemNum)
    if itemNum > 0 then

        if self.m_reqExpData.count == 0 then
            self.m_reqExpData.count = 1
        end

        if self.m_reqExpData.count > itemNum then
            self.m_reqExpData.count = itemNum
        end

        local expItem = {
            item_id = self.m_reqExpData.itemId,
            count = self.m_reqExpData.count
        }
        WuJiangMgr:ReqLevelUp(self.m_wujiangIndex, expItem)
    end

    self:ResetFeedData()
    --特效去掉
end

function UIWuJiangDevLevelupView:ResetFeedData()
    self.m_feedTime = 0
    self.m_feedInterval = 0.5
    self.m_expItemNameOnPress = "" --当前按了哪个Item
    self.m_isOnPressExp = false
    self.m_reqExpData.count = 0
end


function UIWuJiangDevLevelupView:UpdateFeedExp(deltaTime)
    
    if not self.m_isOnPressExp then
        return
    end

    if self:FeedExpIsUpLimit() then
        return
    end

    self.m_feedTime = self.m_feedTime + deltaTime
    if self.m_feedTime < self.m_feedInterval then
        return
    end

    self.m_feedTime = 0
    
    if self.m_reqExpData.itemId > 0 and self.m_expItemNameOnPress ~= "" and self.m_onPressItemNum > 0 then
        local wujiangData = Player:GetInstance().WujiangMgr:GetWuJiangData(self.m_wujiangIndex)
        if wujiangData then

            local fMinFrame = 0.1  --最小帧数间隔
            if self.m_reqExpData.itemId == 20001 then
                fMinFrame = 0.033
            elseif self.m_reqExpData.itemId == 20002 then
                fMinFrame = 0.067
            elseif self.m_reqExpData.itemId == 20003 then
                fMinFrame = 0.1
            end

            --更新频率递增
            if self.m_feedInterval > fMinFrame then
                self.m_feedInterval = self.m_feedInterval - 0.333
                if self.m_feedInterval < fMinFrame then
                    self.m_feedInterval = fMinFrame
                end
            end

            self.m_reqExpData.count = self.m_reqExpData.count + 1

            -- print("m_feedInterval , reqExpData.count :", self.m_feedInterval, self.m_reqExpData.count)

            local nowItemCount = self.m_onPressItemNum - self.m_reqExpData.count
            if nowItemCount > -1 then

                --刷新道具
                self:SimulationUpdateExpItem(self.m_reqExpData.itemId, nowItemCount)

                -- print("self.m_reqExpData.addExp ",self.m_reqExpData.addExp)
                local addExp =  self.m_reqExpData.addExp + self.m_tmpWujiangData.exp
                self:CheckLevelUp(addExp)

                if nowItemCount == 0 then
                    self:EndPressExpItem()
                end
            end
        end
    end
end

function UIWuJiangDevLevelupView:CheckLevelUp(currExp)
    --直接修改本地数据
      local bLevelUp = false
      if self.m_tmpWujiangData then  

        self.m_tmpWujiangData.exp = currExp

        local wuJiangLevelCfg = ConfigUtil.GetWuJiangLevelCfgByID(self.m_tmpWujiangData.level)
        local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(self.m_tmpWujiangData.star)

        --升级
        if wuJiangLevelCfg and wujiangStarCfg then
            while self.m_tmpWujiangData.exp >= wuJiangLevelCfg.need_exp and self.m_tmpWujiangData.level < wujiangStarCfg.level_limit do
        
                self.m_tmpWujiangData.exp = self.m_tmpWujiangData.exp - wuJiangLevelCfg.need_exp
                self.m_tmpWujiangData.level = self.m_tmpWujiangData.level + 1

                wuJiangLevelCfg = ConfigUtil.GetWuJiangLevelCfgByID(self.m_tmpWujiangData.level)
                bLevelUp = true
            end
        end

        --可能填满经验
        wuJiangLevelCfg = ConfigUtil.GetWuJiangLevelCfgByID(self.m_tmpWujiangData.level)
        if wuJiangLevelCfg then
            if self.m_tmpWujiangData.exp > wuJiangLevelCfg.need_exp then
                self.m_tmpWujiangData.exp =  wuJiangLevelCfg.need_exp 
            end
        end
        
        if bLevelUp then
            self:ShowUpLvEffect(true)
        end

        self:UpdateExp(self.m_tmpWujiangData)
      end
  
      return bLevelUp
  end
  

  function UIWuJiangDevLevelupView:FeedExpIsUpLimit()

    local wuJiangLevelCfg = ConfigUtil.GetWuJiangLevelCfgByID(self.m_tmpWujiangData.level)
    local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(self.m_tmpWujiangData.star)

    if not wuJiangLevelCfg or not wujiangStarCfg then
        return true
    end

    if self.m_tmpWujiangData.exp >= wuJiangLevelCfg.need_exp and self.m_tmpWujiangData.level >= wujiangStarCfg.level_limit then
        return true
    end
end

function UIWuJiangDevLevelupView:ShowUpLvEffect(isShow)
    if isShow then
        if not self.m_sliderEffect then
            local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
            UIUtil.AddComponent(UIEffect, self, "ExpSilder", sortOrder, TheGameIds.ui_shengjitiao01_fx_path, function(effect)
                self.m_sliderEffect = effect
            end)
        else
            self.m_sliderEffect:Show(true)
        end
    else
        if self.m_sliderEffect then
            self.m_sliderEffect:Delete()
            self.m_sliderEffect = nil
        end
    end
end


return UIWuJiangDevLevelupView