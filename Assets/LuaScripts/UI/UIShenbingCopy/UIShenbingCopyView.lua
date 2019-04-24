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
local ShenbingCopyHardItem = require "UI.UIShenbingCopy.ShenbingCopyHardItem"
local ShenbingCopyHardItemPath = "UI/Prefabs/ShenbingCopy/ShenbingHardItem.prefab" 
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam" 

local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)
local SpringContent = CS.SpringContent
local itemHeight = 164.8

local UIShenbingCopyView = BaseClass("UIShenbingCopyView", UIBaseView)
local base = UIBaseView

function UIShenbingCopyView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    
    self:HandleClick()
end

function UIShenbingCopyView:OnEnable(...)
    base.OnEnable(self, ...)
   
    self.m_sbCopyMgr:ReqPanel()
end

function UIShenbingCopyView:OnAddListener()
	base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.MN_SBCOPY_INFO_CHG, self.UpdateView)
    self:AddUIListener(UIMessageNames.MN_SBCOPY_TIMES_CHG, self.UpdateLeftTimes)
    self:AddUIListener(UIMessageNames.MN_SBCOPY_CLICK_COPY, self.OnClickCopyHardItem)
end

function UIShenbingCopyView:OnRemoveListener()
	base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.MN_SBCOPY_INFO_CHG, self.UpdateView)
    self:RemoveUIListener(UIMessageNames.MN_SBCOPY_TIMES_CHG, self.UpdateLeftTimes)
    self:RemoveUIListener(UIMessageNames.MN_SBCOPY_CLICK_COPY, self.OnClickCopyHardItem)
end

function UIShenbingCopyView:OnDisable()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_detailItemLoaderSeq)
    self.m_detailItemLoaderSeq = 0
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_dropItemLoadSeq)
    self.m_dropItemLoadSeq = 0
    
    for _, item in ipairs(self.m_copyDetailItemList) do
        item:Delete()
    end
    self.m_copyDetailItemList = {}
    for _, item in ipairs(self.m_dropItemList) do
        item:Delete()
    end
    self.m_dropItemList = {}

    base.OnDisable(self)
end

function UIShenbingCopyView:OnDestroy()
    self:RemoveEvent()
    base.OnDestroy(self)
end

-- 初始化非UI变量
function UIShenbingCopyView:InitVariable()
    self.m_sbCopyMgr = Player:GetInstance():GetShenbingCopyMgr()
    self.m_copyDetailItemList = {}
    self.m_dropItemList = {}
    self.m_detailItemLoaderSeq = 0
    self.m_dropItemLoadSeq = 0
    self.m_curCopyID = 0
end

-- 初始化UI变量
function UIShenbingCopyView:InitView()
    self.m_detailItemRoot, self.m_detailScrollView, self.m_awardItemRoot, self.m_fightBtn,
    self.m_heidi, self.m_closeBtn, self.m_ruleBtnTr = UIUtil.GetChildRectTrans(self.transform, {
        "bg/leftBg/ItemScrollView/Viewport/ItemContent",
        "bg/leftBg/ItemScrollView",
        "bg/rightBg/ItemScrollView/Viewport/AwardItemContent",
        "bg/rightBg/middle/fight_BTN",
        "CloseBtn",
        "bg/topBg/closeBtn",
        "bg/topBg/RuleBtn",
    })

    self.m_copyNameText, self.m_copyDesText, self.m_dropText, self.m_titleText, self.m_awardText,
    self.m_leftTimesText, self.m_fightBtnText, self.m_fightConsumeText = UIUtil.GetChildTexts(self.transform, {
        "bg/rightBg/top/copyNameText",
        "bg/rightBg/top/copyDesText",
        "bg/rightBg/top/dropText",
        "bg/topBg/titleBg/titleText",        
        "bg/rightBg/middle/awardText",
        "bg/rightBg/middle/leftTimesText",        
        "bg/rightBg/middle/fight_BTN/fightBtnText",
        "bg/rightBg/middle/fightConsumeText",
    })

    self.m_dropItemScrollView = self:AddComponent(LoopScrowView, "bg/rightBg/ItemScrollView/Viewport/AwardItemContent", Bind(self, self.UpdateDropItem))
    self.m_detailItemScrollView = self:AddComponent(LoopScrowView, "bg/leftBg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateHardItem))
        
    self.m_detailItemBounds = GameUtility.GetRectTransWorldCorners(self.m_detailScrollView)

    self.m_titleText.text = Language.GetString(2803)
    self.m_awardText.text = Language.GetString(2609)
    
    self.m_fightBtnText.text = Language.GetString(2611)
end

function UIShenbingCopyView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_fightBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_heidi.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIShenbingCopyView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_fightBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_heidi.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)
end

function UIShenbingCopyView:OnClick(go, x, y)
    local name = go.name
    
    if name == "fight_BTN" then
        local left = self.m_sbCopyMgr:GetLeftTimes()
        if left == 0 then
            UILogicUtil.FloatAlert(Language.GetString(86))
            return
        end

        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "fight_BTN")

        UIManagerInst:OpenWindow(UIWindowNames.UIShenbingCopyLineupMainView, BattleEnum.BattleType_SHENBING, self:GetCurCopyID())
    
    elseif name == "CloseBtn" or name == "closeBtn" then
        self:CloseSelf()
    elseif go.name == "RuleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 120) 
    end
end

function UIShenbingCopyView:CalcCurCopyID()
    local cfgList = ConfigUtil.GetShenbingCopyCfgList()

    self.m_curCopyID = cfgList[1].id
    for _, v in ipairs(cfgList) do
        if not self:IsLocked(v) then
            if v.id > self.m_curCopyID then
                self.m_curCopyID = v.id
            end
        end
    end
end

function UIShenbingCopyView:UpdateView(copyID)
    if not copyID or copyID == 0 then
        self:CalcCurCopyID()
    else
        self:SetCurCopyID(copyID)
    end

    self:UpdateCopyDetail()
    self:UpdateHardDetailItem()
    

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

function UIShenbingCopyView:UpdateCopyDetail()
    local copyCfg = ConfigUtil.GetShenbingCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end
    
    self.m_copyNameText.text = copyCfg.copyName
    self.m_copyDesText.text = copyCfg.desc
    self.m_dropText.text = copyCfg.dropDesc
    
    self.m_fightConsumeText.text = copyCfg.stamina
    self:UpdateLeftTimes()
    self:UpdateDropItemList()
end

function UIShenbingCopyView:UpdateHardDetailItem()
    local copyList = ConfigUtil.GetShenbingCopyCfgList()

    if #self.m_copyDetailItemList == 0 then
        if self.m_detailItemLoaderSeq == 0 then
            self.m_detailItemLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_detailItemLoaderSeq, ShenbingCopyHardItemPath, #copyList, function(objs)
                self.m_detailItemLoaderSeq = 0
                if objs then
                    for i = 1, #objs do
                        local copyDetailItem = ShenbingCopyHardItem.New(objs[i], self.m_detailItemRoot, ShenbingCopyHardItemPath)
                        table_insert(self.m_copyDetailItemList, copyDetailItem)
                    end
                    self.m_detailItemScrollView:UpdateView(true, self.m_copyDetailItemList, copyList)
                    self:SetDetailScrollViewPos()
                end
            end)
        end
    else
        self.m_detailItemScrollView:UpdateView(true, self.m_copyDetailItemList, copyList)
        -- self:SetDetailScrollViewPos()
    end
end

function UIShenbingCopyView:SetDetailScrollViewPos()
    local newItemBottomY = 0
    for _, item in ipairs(self.m_copyDetailItemList) do 
        newItemBottomY = newItemBottomY + 160       -- itemHeight
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

function UIShenbingCopyView:UpdateDropItemList()
    local copyCfg = ConfigUtil.GetShenbingCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end

    local dropList = {}

    for i = 1, 5 do
        if copyCfg['item_id'..i] > 0 then
            table_insert(dropList, i)
        end
    end

    if #self.m_dropItemList == 0 then
        if self.m_dropItemLoadSeq == 0 then
            self.m_dropItemLoadSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()

            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_dropItemLoadSeq, CommonAwardItemPrefab, #dropList, function(objs)
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

function UIShenbingCopyView:OnClickCopyHardItem(copyID)
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
end

function UIShenbingCopyView:UpdateDropItem(item, realIndex)
    local copyCfg = ConfigUtil.GetShenbingCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end

    local itemID = copyCfg['item_id'..realIndex]
    local itemCount = copyCfg['item_count'..realIndex]

    if item and itemID then
        local data = {
            item_id = itemID,
            count = itemCount,
        }
        local itemIconParam = AwardIconParamClass.New(data.item_id, data.count)
        item:UpdateData(itemIconParam) 
    end
end

function UIShenbingCopyView:IsLocked(copyCfg)
    local copyID = copyCfg.id

    local lock = false
    if Player:GetInstance():GetUserMgr():GetUserData().level < copyCfg.open_level then
        lock = true
    else
        local preCopyID = copyID - 1
        if preCopyID > 0 then
            if not self.m_sbCopyMgr:IsPassed(preCopyID) then
                lock = true
            end
        end
    end

    return lock
end

function UIShenbingCopyView:UpdateHardItem(item, realIndex)
    local copyList = ConfigUtil.GetShenbingCopyCfgList()

    if item and realIndex > 0 and realIndex <= #copyList then
        local copyCfg = copyList[realIndex]
        local copyID = copyCfg.id

        local lock = self:IsLocked(copyCfg)

        item:SetData(copyID, lock, self:GetCurCopyID() == copyID, self.m_detailItemBounds)
    end
end

function UIShenbingCopyView:OnEnterCopyFailed(result)
    if result == 9 then
        UILogicUtil.FloatAlert(Language.GetString(2624))
    end
    self.m_autoFightRoot:SetActive(false)
    self.m_uiData.isAutoFight = false
    self.m_countDownTime = 0
    self.m_autoFightSelect:SetActive(false)
    self.m_uiData.curAutoFightTimes = 0
end

function UIShenbingCopyView:GetCurCopyID()
    return self.m_curCopyID
end

function UIShenbingCopyView:SetCurCopyID(copyID)
    self.m_curCopyID = copyID
end

function UIShenbingCopyView:UpdateLeftTimes()
    local left = self.m_sbCopyMgr:GetLeftTimes()
    if left == 0 then
        self.m_leftTimesText.text = string_format(Language.GetString(2820), left)
    else
        self.m_leftTimesText.text = string_format(Language.GetString(2804), left)
    end
end

return UIShenbingCopyView