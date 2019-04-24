local math_ceil = math.ceil
local table_insert = table.insert
local table_count = table.count
local table_values = table.values
local string_format = string.format
local CommonDefine = CommonDefine
local BattleEnum = BattleEnum
local Time = Time
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local GameUtility = CS.GameUtility
local Vector3 = Vector3
local Quaternion = Quaternion
local InscriptionCopyHardItem = require "UI.UIInscriptionCopy.InscriptionCopyHardItem"
local InscriptionCopyHardItemPath = "UI/Prefabs/InscriptionCopy/InscriptionCopyHardItem.prefab" 

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam" 

local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)
local SpringContent = CS.SpringContent
local itemHeight = 164.8
local DropItemMaxCount = 3

local math_floor = math.floor

local UIInscriptionCopyView = BaseClass("UIInscriptionCopyView", UIBaseView)
local base = UIBaseView

function UIInscriptionCopyView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    self:HandleClick()
end

function UIInscriptionCopyView:OnEnable(...)
    base.OnEnable(self, ...)
   
    self.m_copyMgr:ReqCopyPanelInfo()
end

function UIInscriptionCopyView:OnDisable()
    --取消加载 
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_detailItemLoaderSeq)
    self.m_detailItemLoaderSeq = 0
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_dropItemLoadSeq)
    self.m_dropItemLoadSeq = 0
    
    --释放
    for _, item in ipairs(self.m_copyDetailItemList) do
        item:Delete()
    end
    self.m_copyDetailItemList = {}
    for _, item in ipairs(self.m_dropItemList) do
        item:Delete()
    end
    self.m_dropItemList = {}

    self.m_curCopyID = 0
    base.OnDisable(self)
end

function UIInscriptionCopyView:OnDestroy()
    self:RemoveEvent()
    base.OnDestroy(self)
end

function UIInscriptionCopyView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_INSCRIPTION_COPY_INFO, self.UpdateView)
    self:AddUIListener(UIMessageNames.MN_INSCRIPTION_COPY_CLICK_COPY, self.OnClickCopyHardItem)
end

function UIInscriptionCopyView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_INSCRIPTION_COPY_INFO, self.UpdateView)
    self:RemoveUIListener(UIMessageNames.MN_INSCRIPTION_COPY_CLICK_COPY, self.OnClickCopyHardItem)
end

function UIInscriptionCopyView:InitVariable()
    self.m_copyMgr = Player:GetInstance().InscriptionMgr

    self.m_copyDetailItemList = {}
    self.m_dropItemList = {}
    self.m_detailItemLoaderSeq = 0
    self.m_dropItemLoadSeq = 0
    self.m_curCopyID = 0
end

function UIInscriptionCopyView:InitView()
    self.m_detailItemRoot, self.m_detailScrollView, self.m_awardItemRoot, self.m_fightBtn,
    self.m_heidi, self.m_closeBtn, self.m_tongqianRectTran, self.m_rankBtn,
    self.m_ruleBtnTr = UIUtil.GetChildRectTrans(self.transform, {
        "bg/leftBg/ItemScrollView/Viewport/ItemContent",
        "bg/leftBg/ItemScrollView",
        "bg/rightBg/ItemScrollView/Viewport/AwardItemContent",
        "bg/rightBg/middle/fight_BTN",
        "CloseBtn",
        "bg/topBg/closeBtn",
        "bg/rightBg/top/TongqianImage",
        "bg/rightBg/top/RankValText/Rank_BTN",
        "bg/topBg/RuleBtn",
    })

    self.m_copyNameText, self.m_consumedTimeText, self.m_tongqianCountText ,self.m_titleText, self.m_awardText,
    self.m_leftTimesText, self.m_fightBtnText, self.m_fightConsumeText, self.m_rankText,
    self.m_tipsText, self.m_noDataText, self.m_rankValText = UIUtil.GetChildTexts(self.transform, {
        "bg/rightBg/top/TongqianImage/copyNameText",
        "bg/rightBg/top/TongqianImage/consumedTimeText",
        "bg/rightBg/top/TongqianImage/TongqianCountText",
        "bg/topBg/titleBg/titleText",        
        "bg/rightBg/middle/awardText",
        "bg/rightBg/middle/leftTimesText",        
        "bg/rightBg/middle/fight_BTN/fightBtnText",
        "bg/rightBg/middle/fightConsumeText",
        "bg/rightBg/middle/rankText",
        "bg/rightBg/middle/TipsText",
        "bg/rightBg/top/NoneDataText", 
        "bg/rightBg/top/RankValText"
    })

    self.m_dropItemScrollView = self:AddComponent(LoopScrowView, "bg/rightBg/ItemScrollView/Viewport/AwardItemContent", Bind(self, self.UpdateDropItem))
    self.m_detailItemScrollView = self:AddComponent(LoopScrowView, "bg/leftBg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateHardItem))
        
    self.m_detailItemBounds = GameUtility.GetRectTransWorldCorners(self.m_detailScrollView)

    self.m_scoreImage = self:AddComponent(UIImage, "bg/rightBg/top/TongqianImage", AtlasConfig.DynamicLoad)

    self.m_titleText.text = Language.GetString(1902)
    self.m_awardText.text = Language.GetString(1802)
    self.m_fightBtnText.text = Language.GetString(2611)
    --self.m_tipsText.text = Language.GetString(1800)
    self.m_rankText.text = Language.GetString(1801)
    self.m_noDataText.text = Language.GetString(1807)
end

function UIInscriptionCopyView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_fightBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_heidi.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_rankBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
end

function UIInscriptionCopyView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_fightBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_heidi.gameObject)
    UIUtil.RemoveClickEvent(self.m_rankBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)
end

function UIInscriptionCopyView:OnClick(go, x, y)
    local name = go.name
    
    if name == "fight_BTN" then
        if self:IsLocked(self.m_copyCfg) then
            UILogicUtil.FloatAlert(Language.GetString(1808))
            return
        end

        if self.m_panelInfo  then
            if self.m_panelInfo.left_times == 0 then
                UILogicUtil.FloatAlert(Language.GetString(86))
                return
            end
        end

        UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, BattleEnum.BattleType_INSCRIPTION, self:GetCurCopyID())
    
    elseif name == "Rank_BTN" then
        UIManagerInst:OpenWindow(UIWindowNames.UICommonRank, CommonDefine.COMMONRANK_INSCRIPTIONCOPY)

    elseif name == "CloseBtn" or name == "closeBtn" then
        self:CloseSelf()
    elseif name == "RuleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 117) 
    end
end

function UIInscriptionCopyView:UpdateView(panelInfo)
    self.m_panelInfo = panelInfo
    if not self.m_panelInfo then
        return
    end

    self:CalcCurCopyID()
    self:UpdateCopyDetail()
    self:UpdateHardDetailItem()
    self:UpdateDropItemList()
end

function UIInscriptionCopyView:CalcCurCopyID()
    if self.m_panelInfo then
        if self.m_curCopyID == 0 then
            if self.m_panelInfo.pass_copyID > 0 then
                local nextCopyID = self.m_panelInfo.pass_copyID + 1
                local nextCopyCfg = ConfigUtil.GetInscriptionCopyCfgByID(nextCopyID)
                if nextCopyCfg and not self:IsLocked(nextCopyCfg) then
                    self.m_curCopyID = nextCopyID
                else
                    self.m_curCopyID = self.m_panelInfo.pass_copyID
                end
            else
                local copyList = ConfigUtil.GetInscriptionCopyCfgList()
                if copyList then
                    self.m_curCopyID = copyList[1].id
                end
            end
        end
    end
end

function UIInscriptionCopyView:GetCurCopyID()
    return self.m_curCopyID
end

function UIInscriptionCopyView:UpdateCopyDetail()
    local copyCfg = ConfigUtil.GetInscriptionCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end
    
    self.m_copyCfg = copyCfg
  
    self.m_fightConsumeText.text = copyCfg.stamina

    if self.m_panelInfo.pass_floor_max > 0 and copyCfg.floor <= self.m_panelInfo.pass_floor_max then
        self.m_noDataText.gameObject:SetActive(false)
        self.m_tongqianRectTran.gameObject:SetActive(true)
        self.m_copyNameText.text = copyCfg.name

        local floorData
        if self.m_panelInfo.floor_list then
            for i, v in ipairs(self.m_panelInfo.floor_list) do
                if v.floor == copyCfg.floor then
                    floorData = v
                    break
                end 
            end
        end

        if floorData then
            local scoreAwardCfgList	= ConfigUtil.GetInscriptionCopyScoreAwardCfgList()
            for i, v in ipairs(scoreAwardCfgList) do
                if v then
                    if floorData.best_score <= v.max and floorData.best_score >= v.min then
                        self.m_scoreImage:SetAtlasSprite(v.image, true)
                    end
                end
            end

            self.m_consumedTimeText.text = floorData.best_consumed_time > 0 and TimeUtil.ToMinSecStr(floorData.best_consumed_time) or ""
            self.m_tongqianCountText.text = math_ceil(floorData.best_score)
        end
        self.m_rankValText.text = self.m_panelInfo.rank > 0 and string_format(Language.GetString(1810), self.m_panelInfo.rank) or Language.GetString(1809)
    else
        self.m_noDataText.gameObject:SetActive(true)
        self.m_tongqianRectTran.gameObject:SetActive(false)
    end

    self:UpdateLeftTimes()
end

function UIInscriptionCopyView:UpdateLeftTimes()
    if self.m_panelInfo  then
        if self.m_panelInfo.left_times == 0 then
            self.m_leftTimesText.text = string_format(Language.GetString(2820),  self.m_panelInfo.left_times)
        else
            self.m_leftTimesText.text = string_format(Language.GetString(2804),  self.m_panelInfo.left_times)
        end
    end
end

function UIInscriptionCopyView:UpdateHardDetailItem()
    local copyList = ConfigUtil.GetInscriptionCopyCfgList()

    if #self.m_copyDetailItemList == 0 then
        if self.m_detailItemLoaderSeq == 0 then
            self.m_detailItemLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_detailItemLoaderSeq, InscriptionCopyHardItemPath, #copyList, function(objs)
                self.m_detailItemLoaderSeq = 0
                if objs then
                    for i = 1, #objs do
                        local copyDetailItem = InscriptionCopyHardItem.New(objs[i], self.m_detailItemRoot, InscriptionCopyHardItemPath)
                        table_insert(self.m_copyDetailItemList, copyDetailItem)
                    end
                    self.m_detailItemScrollView:UpdateView(true, self.m_copyDetailItemList, copyList)
                    self:SetDetailScrollViewPos()
                end
            end)
        end
    else
        self.m_detailItemScrollView:UpdateView(true, self.m_copyDetailItemList, copyList)
        self:SetDetailScrollViewPos()
    end
end

function UIInscriptionCopyView:SetDetailScrollViewPos()
    local newItemBottomY = 0
    for _, item in ipairs(self.m_copyDetailItemList) do 
        newItemBottomY = newItemBottomY + itemHeight
        if item:GetCopyID() == self:GetCurCopyID() then
            break
        end
    end
    local sizeDelta = self.m_detailItemScrollView:GetScrollRectSize()
    if newItemBottomY > sizeDelta.y then
        local y = newItemBottomY - sizeDelta.y
        SpringContent.Begin(self.m_detailItemRoot.gameObject, Vector3.New(0, y, 0), 100)
    end
end

function UIInscriptionCopyView:UpdateHardItem(item, realIndex)
    local copyList = ConfigUtil.GetInscriptionCopyCfgList()

    if item and realIndex > 0 and realIndex <= #copyList then
        local copyCfg = copyList[realIndex]
        local copyID = copyCfg.id

        local lock = self:IsLocked(copyCfg)

        item:SetData(copyID, lock, self:GetCurCopyID() == copyID, self.m_detailItemBounds)
    end
end

function UIInscriptionCopyView:IsLocked(copyCfg)
    local lock = false
    if copyCfg then
        local floor = copyCfg.floor
        if Player:GetInstance():GetUserMgr():GetUserData().level < copyCfg.level then
            lock = true
            --print("lock  ", copyCfg.id)
        else
            if self.m_panelInfo then
                local preFloor = floor - 1
                if preFloor > self.m_panelInfo.pass_floor_max and floor ~= 1 then
                    lock = true
                    --print("lock 2 ", copyCfg.id ,self.m_panelInfo.pass_floor_max, floor)
                end
            end
        end
    end
    
    return lock
end

function UIInscriptionCopyView:UpdateDropItemList()
    local copyCfg = ConfigUtil.GetInscriptionCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end
  
    local dropList = {}
    if copyCfg.item_id1 ~= 0 then
        table_insert(dropList, copyCfg.item_id1)
    end
    if copyCfg.item_id2 ~= 0 then
        table_insert(dropList, copyCfg.item_id2)
    end
    if copyCfg.item_id3 ~= 0 then
        table_insert(dropList, copyCfg.item_id3)
    end

    self.m_dropList = dropList

    if #self.m_dropItemList == 0 then
        if self.m_dropItemLoadSeq == 0 then
            self.m_dropItemLoadSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()

            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_dropItemLoadSeq, CommonAwardItemPrefab, DropItemMaxCount, function(objs)
                self.m_dropItemLoadSeq = 0
                if objs then
                    for i = 1, #objs do
                        local bagItem = CommonAwardItem.New(objs[i], self.m_awardItemRoot, CommonAwardItemPrefab)
                        bagItem:SetLocalScale(Vector3.New(0.85, 0.85, 1))
                        table_insert(self.m_dropItemList, bagItem)
                    end
                    self.m_dropItemScrollView:UpdateView(true, self.m_dropItemList, dropList)
                end
            end)
        end
    else
        self.m_dropItemScrollView:UpdateView(true, self.m_dropItemList, dropList)
    end
end

function UIInscriptionCopyView:UpdateDropItem(item, realIndex)
    local copyCfg = ConfigUtil.GetInscriptionCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end

    if self.m_dropList then
        local itemID = self.m_dropList[realIndex]
        local data = {
            item_id = itemID,
            count = 1,
        }
        local itemIconParam = AwardIconParamClass.New(data.item_id, data.count)
        item:UpdateData(itemIconParam)  
    end  
end

function UIInscriptionCopyView:OnClickCopyHardItem(copyID)
    if self:GetCurCopyID() ~= copyID then
        for _, item in ipairs(self.m_copyDetailItemList) do 
            if item:GetCopyID() == copyID then
                item:DoSelect(true, self.m_detailItemBounds)
            end
            if item:GetCopyID() == self:GetCurCopyID() then
                item:DoSelect(false, self.m_detailItemBounds)
            end
        end
    end
    
    self:SetCurCopyID(copyID)
    self:UpdateCopyDetail()
    self:UpdateDropItemList()
end

function UIInscriptionCopyView:SetCurCopyID(copyID)
    self.m_curCopyID = copyID
end

return UIInscriptionCopyView